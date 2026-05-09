#!/usr/bin/env bats
#
# Tests for claude-status-summary, primarily its --classify mode which
# operates on a synthetic jsonl file. Pill-rendering is exercised via the
# --classify path; the live process-walking branch is harder to mock and
# is only smoke-tested here.

setup() {
    load '../test_helper/bats-support/load'
    load '../test_helper/bats-assert/load'
    PATH="$BATS_TEST_DIRNAME/../../config/bin:$PATH"

    FIXTURE_DIR="$(mktemp -d -t claude-stat.XXXXXX)"
    export FIXTURE_DIR
}

teardown() {
    rm -rf "$FIXTURE_DIR"
}

# Helper: write lines to a fixture jsonl and (optionally) backdate its mtime
# by N seconds. Usage: write_jsonl <name> <age_seconds> <line>...
write_jsonl() {
    local name=$1 age=$2; shift 2
    local f="$FIXTURE_DIR/$name"
    : > "$f"
    for line in "$@"; do
        printf '%s\n' "$line" >> "$f"
    done
    if [ "$age" -gt 0 ]; then
        # macOS touch -t accepts [[CC]YY]MMDDhhmm[.ss]; compute target.
        local t
        t=$(date -r "$(($(date +%s) - age))" +%Y%m%d%H%M.%S)
        touch -t "$t" "$f"
    fi
    printf '%s' "$f"
}

@test "classify: assistant end_turn => done" {
    f=$(write_jsonl end_turn.jsonl 0 \
        '{"type":"assistant","message":{"role":"assistant","stop_reason":"end_turn","content":[{"type":"text","text":"all done"}]}}')
    run claude-status-summary --classify "$f"
    assert_success
    assert_output "done"
}

@test "classify: user request interrupted => interrupted" {
    f=$(write_jsonl interrupt.jsonl 0 \
        '{"type":"user","message":{"role":"user","content":[{"type":"text","text":"[Request interrupted by user for tool use]"}]}}')
    run claude-status-summary --classify "$f"
    assert_success
    assert_output "interrupted"
}

@test "classify: assistant tool_use, fresh => running" {
    f=$(write_jsonl tool_use_fresh.jsonl 0 \
        '{"type":"assistant","message":{"role":"assistant","stop_reason":"tool_use","content":[{"type":"tool_use","id":"t1","name":"Bash"}]}}')
    run claude-status-summary --classify "$f"
    assert_success
    assert_output "running"
}

@test "classify: assistant tool_use, age >= 3s => waiting" {
    f=$(write_jsonl tool_use_waiting.jsonl 5 \
        '{"type":"assistant","message":{"role":"assistant","stop_reason":"tool_use","content":[{"type":"tool_use","id":"t1","name":"Bash"}]}}')
    run claude-status-summary --classify "$f"
    assert_success
    assert_output "waiting"
}

@test "classify: assistant tool_use, age >= 15s => none (stale)" {
    f=$(write_jsonl tool_use_stale.jsonl 30 \
        '{"type":"assistant","message":{"role":"assistant","stop_reason":"tool_use","content":[{"type":"tool_use","id":"t1","name":"Bash"}]}}')
    run claude-status-summary --classify "$f"
    assert_success
    assert_output "none"
}

@test "classify: assistant thinking, fresh => running" {
    f=$(write_jsonl thinking.jsonl 0 \
        '{"type":"assistant","message":{"role":"assistant","stop_reason":null,"content":[{"type":"thinking","thinking":"hmm"}]}}')
    run claude-status-summary --classify "$f"
    assert_success
    assert_output "running"
}

@test "classify: assistant streaming text (stop_reason null), fresh => running" {
    f=$(write_jsonl streaming.jsonl 0 \
        '{"type":"assistant","message":{"role":"assistant","stop_reason":null,"content":[{"type":"text","text":"partial"}]}}')
    run claude-status-summary --classify "$f"
    assert_success
    assert_output "running"
}

@test "classify: file older than 5 minutes => none" {
    f=$(write_jsonl ancient.jsonl 600 \
        '{"type":"assistant","message":{"role":"assistant","stop_reason":"end_turn","content":[{"type":"text","text":"old"}]}}')
    run claude-status-summary --classify "$f"
    assert_success
    assert_output "none"
}

@test "classify: missing file => none" {
    run claude-status-summary --classify "$FIXTURE_DIR/does-not-exist.jsonl"
    assert_success
    assert_output "none"
}

@test "classify: noise lines (system-reminder, slash-command) are skipped" {
    # Last meaningful line should be the assistant end_turn, not the noise.
    f=$(write_jsonl noise.jsonl 0 \
        '{"type":"assistant","message":{"role":"assistant","stop_reason":"end_turn","content":[{"type":"text","text":"hi"}]}}' \
        '{"type":"user","message":{"role":"user","content":[{"type":"text","text":"<system-reminder>nudge</system-reminder>"}]}}' \
        '{"type":"user","message":{"role":"user","content":[{"type":"text","text":"<command-name>/clear</command-name>"}]}}' \
        '{"type":"user","message":{"role":"user","content":[{"type":"text","text":"<bash-input>ls</bash-input>"}]}}')
    run claude-status-summary --classify "$f"
    assert_success
    assert_output "done"
}

@test "classify: end_turn wins even when file is fresh and previous noise lines exist" {
    f=$(write_jsonl end_turn_with_noise.jsonl 0 \
        '{"type":"assistant","message":{"role":"assistant","stop_reason":"tool_use","content":[{"type":"tool_use","id":"t1"}]}}' \
        '{"type":"user","message":{"role":"user","content":[{"type":"tool_result","tool_use_id":"t1"}]}}' \
        '{"type":"assistant","message":{"role":"assistant","stop_reason":"end_turn","content":[{"type":"text","text":"finished"}]}}')
    run claude-status-summary --classify "$f"
    assert_success
    assert_output "done"
}

@test "classify: empty file => none" {
    f=$(write_jsonl empty.jsonl 0)
    run claude-status-summary --classify "$f"
    assert_success
    assert_output "none"
}

@test "classify: malformed json line is tolerated, falls through to none" {
    f=$(write_jsonl malformed.jsonl 0 \
        'this is not json at all' \
        'still not json {')
    run claude-status-summary --classify "$f"
    assert_success
    assert_output "none"
}

@test "summary smoke: with no live claude processes pid prints empty pill" {
    run claude-status-summary
    assert_success
    [ -n "$output" ]
}

# --- pill rendering via the per-PID cache ----------------------------------
# We mock the cache directly. claude-status-summary's ancestor check is
# bypassed by giving every fake PID a ppid of 1 (or simply not setting
# TMUX_PID, so the script doesn't filter).

setup_pill_test() {
    SHIM_DIR="$(mktemp -d -t shim.XXXXXX)"
    CACHE="$(mktemp -t cache.XXXXXX)"

    # Mock tmux: emit no PID so the ancestor filter is skipped.
    cat > "$SHIM_DIR/tmux" <<'SH'
#!/usr/bin/env bash
# Empty output -> $TMUX_PID is empty -> no ancestor filtering.
exit 0
SH
    chmod +x "$SHIM_DIR/tmux"

    export PATH="$SHIM_DIR:$PATH"
    export CLAUDE_STATUS_CACHE="$CACHE"
}

teardown_pill_test() {
    rm -rf "$SHIM_DIR" "$CACHE"
}

@test "pill: 1 running => '◐ 1'" {
    setup_pill_test
    printf '100\t1\t/c\t/j\trunning\n' > "$CACHE"
    run claude-status-summary
    teardown_pill_test
    assert_success
    assert_output "◐ 1"
}

@test "pill: 2 running, 1 waiting, 1 done => '◐ 2 ⏳ 1 ✓ 1'" {
    setup_pill_test
    cat > "$CACHE" <<EOF
100	1	/a	/ja	running
101	1	/b	/jb	running
102	1	/c	/jc	waiting
103	1	/d	/jd	done
EOF
    run claude-status-summary
    teardown_pill_test
    assert_success
    assert_output "◐ 2 ⏳ 1 ✓ 1"
}

@test "pill: only interrupted => '✗ 1'" {
    setup_pill_test
    printf '100\t1\t/c\t/j\tinterrupted\n' > "$CACHE"
    run claude-status-summary
    teardown_pill_test
    assert_success
    assert_output "✗ 1"
}

@test "pill: empty cache => '∅'" {
    setup_pill_test
    : > "$CACHE"
    run claude-status-summary
    teardown_pill_test
    assert_success
    assert_output "∅"
}

@test "pill: status=none rows are not counted" {
    setup_pill_test
    cat > "$CACHE" <<EOF
100	1	/a	/ja	running
101	1	/b	/jb	none
102	1	/c	/jc	none
EOF
    run claude-status-summary
    teardown_pill_test
    assert_success
    assert_output "◐ 1"
}
