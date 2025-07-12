#!/usr/bin/env bats

setup() {
    load '../test_helper/bats-support/load'
    load '../test_helper/bats-assert/load'
    PATH="$BATS_TEST_DIRNAME/../../config/bin:$PATH"
    
    # Mock tmux command
    tmux() {
        case "$1" in
            "list-sessions")
                echo "session1" > "$BATS_TMPDIR/tmux_log"
                echo "session2" >> "$BATS_TMPDIR/tmux_log"
                if [[ "$2" == "-F" && "$3" == "#S" ]]; then
                    echo "session1"
                    echo "session2"
                fi
                return 0
                ;;
            "new")
                echo "tmux new called with: $*" > "$BATS_TMPDIR/tmux_log"
                return 0
                ;;
            "attach-session")
                echo "tmux attach-session called with: $*" > "$BATS_TMPDIR/tmux_log"
                return 0
                ;;
            *)
                echo "tmux called with: $*" > "$BATS_TMPDIR/tmux_log"
                return 0
                ;;
        esac
    }
    export -f tmux
    
    # Mock read command for input
    read() {
        if [[ "$1" == "-rp" ]]; then
            echo "test-session" > "$BATS_TMPDIR/read_log"
            export SESSION_NAME="test-session"
        fi
        return 0
    }
    export -f read
    
    # Ensure we're not in a TMUX session
    unset TMUX
}

@test "tm exits early when already in TMUX session" {
    export TMUX="some-session"
    run tm
    assert_success
    # Should exit without doing anything
}

@test "tm script contains expected tmux commands" {
    run grep -q "tmux list-sessions" "$BATS_TEST_DIRNAME/../../config/bin/tm"
    assert_success
    
    run grep -q "tmux new" "$BATS_TEST_DIRNAME/../../config/bin/tm"
    assert_success
    
    run grep -q "tmux attach-session" "$BATS_TEST_DIRNAME/../../config/bin/tm"
    assert_success
}

@test "tm script checks for TMUX environment variable" {
    run grep -q 'TMUX.*exit' "$BATS_TEST_DIRNAME/../../config/bin/tm"
    assert_success
}

@test "tm script contains PS3 prompt" {
    run grep -q 'PS3=' "$BATS_TEST_DIRNAME/../../config/bin/tm"
    assert_success
}

@test "tm script uses select statement" {
    run grep -q 'select opt' "$BATS_TEST_DIRNAME/../../config/bin/tm"
    assert_success
}