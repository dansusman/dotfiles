#!/usr/bin/env bats
#
# Tests for claude-status-map. Mocks tmux + the daemon cache to verify
# per-tmux-session aggregation with priority resolution.

setup() {
    load '../test_helper/bats-support/load'
    load '../test_helper/bats-assert/load'

    SHIM_DIR="$(mktemp -d -t shim.XXXXXX)"
    REAL_BIN="$BATS_TEST_DIRNAME/../../config/bin"

    # Mock tmux: emit fixture sessions on `tmux list-sessions -F '#S\t#{session_path}'`.
    cat > "$SHIM_DIR/tmux" <<'SH'
#!/usr/bin/env bash
case "$1" in
  list-sessions) cat "$TMUX_SESSIONS_FIXTURE" 2>/dev/null ;;
esac
SH
    chmod +x "$SHIM_DIR/tmux"

    TMUX_SESSIONS_FIXTURE="$(mktemp -t tmuxsess.XXXXXX)"
    CACHE="$(mktemp -t cache.XXXXXX)"

    export TMUX_SESSIONS_FIXTURE CACHE
    export CLAUDE_STATUS_CACHE="$CACHE"
    export PATH="$SHIM_DIR:$REAL_BIN:$PATH"
}

teardown() {
    rm -rf "$SHIM_DIR" "$TMUX_SESSIONS_FIXTURE" "$CACHE"
}

# Add a tmux session named $1 with session_path $2.
add_session() { printf '%s\t%s\n' "$1" "$2" >> "$TMUX_SESSIONS_FIXTURE"; }

# Add a cache row: pid \t ppid \t cwd \t jsonl \t status
add_pid() {
    printf '%s\t1\t%s\t/some.jsonl\t%s\n' "$1" "$2" "$3" >> "$CACHE"
}

@test "session whose cwd has a running claude => running" {
    add_session sA /work/proj
    add_pid 100 /work/proj running
    run claude-status-map
    assert_success
    assert_output --partial "sA	running"
}

@test "session matched only by encoded path equivalence" {
    # cwd = /work/proj.foo, session_path = /work/proj.foo
    # Both encode to -work-proj-foo. They should match.
    add_session sX /work/proj.foo
    add_pid 100 /work/proj.foo running
    run claude-status-map
    assert_success
    assert_output --partial "sX	running"
}

@test "session with no matching pid => omitted" {
    add_session sB /no/match
    add_pid 100 /work/other running
    run claude-status-map
    assert_success
    refute_output --partial "sB"
}

@test "priority: running beats waiting beats interrupted beats done" {
    add_session sC /work/multi
    add_pid 100 /work/multi done
    add_pid 101 /work/multi interrupted
    add_pid 102 /work/multi waiting
    add_pid 103 /work/multi running
    run claude-status-map
    assert_success
    assert_output "sC	running"
}

@test "priority: waiting beats interrupted beats done when no running" {
    add_session sD /work/wint
    add_pid 100 /work/wint done
    add_pid 101 /work/wint interrupted
    add_pid 102 /work/wint waiting
    run claude-status-map
    assert_success
    assert_output "sD	waiting"
}

@test "priority: interrupted beats done" {
    add_session sE /work/idn
    add_pid 100 /work/idn done
    add_pid 101 /work/idn interrupted
    run claude-status-map
    assert_success
    assert_output "sE	interrupted"
}

@test "rows with status=none are filtered out" {
    add_session sF /work/none
    add_pid 100 /work/none none
    run claude-status-map
    assert_success
    refute_output --partial "sF"
}

@test "empty cache => empty output" {
    add_session sG /work/empty
    : > "$CACHE"
    run claude-status-map
    assert_success
    assert_output ""
}

@test "multiple sessions emit one row each" {
    add_session sH /work/h
    add_session sI /work/i
    add_pid 100 /work/h running
    add_pid 200 /work/i done
    run claude-status-map
    assert_success
    assert_line "sH	running"
    assert_line "sI	done"
}
