#!/usr/bin/env bats
#
# Tests for claude-status-daemon. The daemon is a long-running process, so
# we test it as a black box: start it, observe cache writes, signal exit,
# verify cleanup. Mocks claude-status-map and fswatch so the test is
# hermetic and fast.

setup() {
    load '../test_helper/bats-support/load'
    load '../test_helper/bats-assert/load'

    SHIM_DIR="$(mktemp -d -t shim.XXXXXX)"
    DAEMON="$BATS_TEST_DIRNAME/../../tmux/claude-status-daemon"
    TMP="$(mktemp -d -t daemon-test.XXXXXX)"

    # Mock claude-status-pids: emits a marker line so we can detect a write.
    cat > "$SHIM_DIR/claude-status-pids" <<'SH'
#!/usr/bin/env bash
printf '111\t1\t/some/cwd\t/some.jsonl\trunning\n'
SH
    chmod +x "$SHIM_DIR/claude-status-pids"

    # Mock fswatch: never fires. Just blocks on stdin so the daemon's
    # background watcher process doesn't exit (the daemon exits the consumer
    # loop on EOF; we want to keep it alive for the test).
    cat > "$SHIM_DIR/fswatch" <<'SH'
#!/usr/bin/env bash
# Sleep forever so the fswatch process stays alive but emits no events.
sleep 60
SH
    chmod +x "$SHIM_DIR/fswatch"

    export PATH="$SHIM_DIR:$PATH"
    export CLAUDE_STATUS_CACHE="$TMP/cache"
    export CLAUDE_STATUS_LOCK="$TMP/lock.pid"
    export CLAUDE_STATUS_TICK_SECS="1"
    # Force a real but empty $HOME so the projects-dir branch is skipped.
    export HOME="$TMP/home"
    mkdir -p "$HOME"
}

teardown() {
    if [ -f "$CLAUDE_STATUS_LOCK" ]; then
        pid=$(cat "$CLAUDE_STATUS_LOCK" 2>/dev/null || true)
        [ -n "$pid" ] && kill "$pid" 2>/dev/null || true
    fi
    pkill -f "$DAEMON" 2>/dev/null || true
    rm -rf "$TMP" "$SHIM_DIR"
}

# Wait until <file> exists with content, or fail after <timeout>s.
wait_for_file() {
    local f=$1 timeout=${2:-3} elapsed=0
    while [ "$elapsed" -lt "$((timeout * 10))" ]; do
        [ -s "$f" ] && return 0
        sleep 0.1
        elapsed=$((elapsed + 1))
    done
    return 1
}

@test "daemon writes cache on startup" {
    "$DAEMON" </dev/null >/dev/null 2>&1 &
    PID=$!
    run wait_for_file "$CLAUDE_STATUS_CACHE" 3
    assert_success
    [ -s "$CLAUDE_STATUS_CACHE" ]
    grep -q running "$CLAUDE_STATUS_CACHE"
    kill "$PID" 2>/dev/null || true
    wait "$PID" 2>/dev/null || true
}

@test "daemon writes pidfile and removes it on exit" {
    "$DAEMON" </dev/null >/dev/null 2>&1 &
    PID=$!
    run wait_for_file "$CLAUDE_STATUS_LOCK" 3
    assert_success
    pidfile_pid=$(cat "$CLAUDE_STATUS_LOCK")
    [ -n "$pidfile_pid" ]
    kill "$PID" 2>/dev/null
    # Give the trap time to fire
    sleep 0.5
    [ ! -f "$CLAUDE_STATUS_LOCK" ]
}

@test "daemon refuses to start if a live one already holds the lock" {
    # Start one
    "$DAEMON" </dev/null >/dev/null 2>&1 &
    PID=$!
    wait_for_file "$CLAUDE_STATUS_LOCK" 3
    # Start a second; should exit 0 immediately without overwriting the pidfile.
    first_pid=$(cat "$CLAUDE_STATUS_LOCK")
    run "$DAEMON"
    assert_success
    second_pid=$(cat "$CLAUDE_STATUS_LOCK")
    [ "$first_pid" = "$second_pid" ]
    kill "$PID" 2>/dev/null || true
    wait "$PID" 2>/dev/null || true
}

@test "daemon takes over a stale pidfile" {
    # Write a pidfile with a PID that is guaranteed not to exist.
    echo 999999 > "$CLAUDE_STATUS_LOCK"
    "$DAEMON" </dev/null >/dev/null 2>&1 &
    PID=$!
    run wait_for_file "$CLAUDE_STATUS_CACHE" 3
    assert_success
    new_pid=$(cat "$CLAUDE_STATUS_LOCK")
    [ "$new_pid" != "999999" ]
    kill "$PID" 2>/dev/null || true
    wait "$PID" 2>/dev/null || true
}

@test "daemon refreshes cache periodically (ticker)" {
    "$DAEMON" </dev/null >/dev/null 2>&1 &
    PID=$!
    wait_for_file "$CLAUDE_STATUS_CACHE" 3
    mtime1=$(stat -f %m "$CLAUDE_STATUS_CACHE")
    # TICK_SECS=1, so the cache should be re-written within ~2s.
    sleep 2
    mtime2=$(stat -f %m "$CLAUDE_STATUS_CACHE")
    [ "$mtime2" -gt "$mtime1" ]
    kill "$PID" 2>/dev/null || true
    wait "$PID" 2>/dev/null || true
}
