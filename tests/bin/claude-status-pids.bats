#!/usr/bin/env bats
#
# Tests for claude-status-pids — the canonical per-PID Claude state walker.
# Mocks ps, lsof, and $HOME so the script reads our fixtures.

setup() {
    load '../test_helper/bats-support/load'
    load '../test_helper/bats-assert/load'

    SHIM_DIR="$(mktemp -d -t shim.XXXXXX)"
    FAKE_HOME="$(mktemp -d -t fakehome.XXXXXX)"
    REAL_BIN="$BATS_TEST_DIRNAME/../../config/bin"

    PROJECTS_DIR="$FAKE_HOME/.claude/projects"
    mkdir -p "$PROJECTS_DIR"

    # Mock ps: emit lines per environment-controlled fixture file.
    # When called as `ps -ax -o pid=,comm=` we cat $PS_FIXTURE.
    # When called as `ps -o ppid= -p <pid>` we look up $PS_PPID_DIR/<pid>.
    cat > "$SHIM_DIR/ps" <<'SH'
#!/usr/bin/env bash
case "$*" in
  *"-o ppid="*"-p "*)
    pid=""
    for ((i=1; i<=$#; i++)); do
      if [ "${!i}" = "-p" ]; then j=$((i+1)); pid="${!j}"; fi
    done
    cat "$PS_PPID_DIR/$pid" 2>/dev/null || echo
    ;;
  *)
    cat "$PS_FIXTURE" 2>/dev/null
    ;;
esac
SH
    chmod +x "$SHIM_DIR/ps"

    # Mock lsof: emit -Fn output for the cwd of a given PID.
    cat > "$SHIM_DIR/lsof" <<'SH'
#!/usr/bin/env bash
pid=""
for ((i=1; i<=$#; i++)); do
  if [ "${!i}" = "-p" ]; then j=$((i+1)); pid="${!j}"; fi
done
cwd_file="$LSOF_CWD_DIR/$pid"
[ -r "$cwd_file" ] && printf 'p%s\nn%s\n' "$pid" "$(cat "$cwd_file")"
SH
    chmod +x "$SHIM_DIR/lsof"

    PS_FIXTURE="$(mktemp -t psfix.XXXXXX)"
    PS_PPID_DIR="$(mktemp -d -t psppid.XXXXXX)"
    LSOF_CWD_DIR="$(mktemp -d -t lsofcwd.XXXXXX)"

    export HOME="$FAKE_HOME"
    export PS_FIXTURE PS_PPID_DIR LSOF_CWD_DIR
    export PATH="$SHIM_DIR:$REAL_BIN:$PATH"
}

teardown() {
    rm -rf "$SHIM_DIR" "$FAKE_HOME" "$PS_PPID_DIR" "$LSOF_CWD_DIR"
    rm -f "$PS_FIXTURE"
}

# Helpers
encode() { printf '%s' "$1" | sed 's:[/._]:-:g'; }

# Set up a Claude PID with cwd, ppid, and a jsonl with given content/age.
register_pid() {
    local pid=$1 ppid=$2 cwd=$3 thread=$4 age=$5; shift 5
    # ps -ax -o pid=,comm= row
    printf '%s claude\n' "$pid" >> "$PS_FIXTURE"
    # ppid lookup
    printf '%s\n' "$ppid" > "$PS_PPID_DIR/$pid"
    # lsof cwd lookup
    printf '%s' "$cwd" > "$LSOF_CWD_DIR/$pid"
    # jsonl
    mkdir -p "$cwd"
    local enc dir f
    enc=$(encode "$cwd")
    dir="$PROJECTS_DIR/$enc"
    mkdir -p "$dir"
    f="$dir/$thread.jsonl"
    : > "$f"
    for line in "$@"; do
        printf '%s\n' "$line" >> "$f"
    done
    if [ "$age" -gt 0 ]; then
        local t
        t=$(date -r "$(($(date +%s) - age))" +%Y%m%d%H%M.%S)
        touch -t "$t" "$f"
    fi
}

@test "no claude processes => empty output" {
    : > "$PS_FIXTURE"
    run claude-status-pids
    assert_success
    assert_output ""
}

@test "single running claude => one row, status=running" {
    register_pid 1001 500 "$FAKE_HOME/p/foo" t1 0 \
        '{"type":"assistant","message":{"role":"assistant","stop_reason":null,"content":[{"type":"thinking","thinking":"..."}]}}'
    run claude-status-pids
    assert_success
    assert_line --partial "1001"
    assert_line --partial "running"
    # Format: pid \t ppid \t cwd \t jsonl \t status
    [[ "$output" == *$'\t'*$'\t'*$'\t'*$'\t'* ]]
}

@test "done status emitted for end_turn" {
    register_pid 1002 500 "$FAKE_HOME/p/bar" t2 0 \
        '{"type":"assistant","message":{"role":"assistant","stop_reason":"end_turn","content":[{"type":"text","text":"ok"}]}}'
    run claude-status-pids
    assert_success
    assert_line --partial $'\tdone'
}

@test "interrupted status emitted for [Request interrupted" {
    register_pid 1003 500 "$FAKE_HOME/p/baz" t3 0 \
        '{"type":"user","message":{"role":"user","content":[{"type":"text","text":"[Request interrupted by user]"}]}}'
    run claude-status-pids
    assert_success
    assert_line --partial $'\tinterrupted'
}

@test "tool_use after 5s => waiting" {
    register_pid 1004 500 "$FAKE_HOME/p/q1" t4 5 \
        '{"type":"assistant","message":{"role":"assistant","stop_reason":"tool_use","content":[{"type":"tool_use","id":"x"}]}}'
    run claude-status-pids
    assert_success
    assert_line --partial $'\twaiting'
}

@test "process with no project dir is skipped" {
    register_pid 1005 500 "$FAKE_HOME/p/exists" t5 0 \
        '{"type":"assistant","message":{"role":"assistant","stop_reason":"end_turn","content":[{"type":"text","text":"ok"}]}}'
    # Add a process whose cwd has no project dir.
    printf '1099 claude\n' >> "$PS_FIXTURE"
    printf '500\n' > "$PS_PPID_DIR/1099"
    printf '%s' "$FAKE_HOME/p/no-such-dir" > "$LSOF_CWD_DIR/1099"

    run claude-status-pids
    assert_success
    # Should only have the registered PID, not the orphan.
    assert_line --partial "1005"
    refute_line --partial "1099"
}

@test "two claudes in same project dir get distinct jsonls" {
    register_pid 2001 500 "$FAKE_HOME/p/shared" tA 0 \
        '{"type":"assistant","message":{"role":"assistant","stop_reason":null,"content":[{"type":"thinking","thinking":"..."}]}}'
    # Add a SECOND PID in the same cwd. Claude-status-pids should pick a
    # different jsonl for it. Make the second jsonl slightly older but
    # still within the 5min window so it's discoverable.
    sleep 1
    printf '2002 claude\n' >> "$PS_FIXTURE"
    printf '500\n' > "$PS_PPID_DIR/2002"
    printf '%s' "$FAKE_HOME/p/shared" > "$LSOF_CWD_DIR/2002"
    enc=$(encode "$FAKE_HOME/p/shared")
    dir="$PROJECTS_DIR/$enc"
    f2="$dir/tB.jsonl"
    printf '%s\n' '{"type":"assistant","message":{"role":"assistant","stop_reason":"end_turn","content":[{"type":"text","text":"x"}]}}' > "$f2"
    # Ensure tA is newer than tB so 2001 picks tA, 2002 gets tB.
    touch "$dir/tA.jsonl"

    run claude-status-pids
    assert_success
    [ "$(echo "$output" | wc -l | tr -d ' ')" = "2" ]
    # First row picks the newer jsonl; second row falls through to the older.
    assert_line --partial "tA.jsonl"
    assert_line --partial "tB.jsonl"
}

@test "stale jsonl (>5min old) classifies as none" {
    register_pid 1006 500 "$FAKE_HOME/p/old" t6 600 \
        '{"type":"assistant","message":{"role":"assistant","stop_reason":null,"content":[{"type":"thinking","thinking":"..."}]}}'
    run claude-status-pids
    assert_success
    assert_line --partial $'\tnone'
}
