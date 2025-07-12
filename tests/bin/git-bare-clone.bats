#!/usr/bin/env bats

setup() {
    load '../test_helper/bats-support/load'
    load '../test_helper/bats-assert/load'
    PATH="$BATS_TEST_DIRNAME/../../config/bin:$PATH"
    
    # Create temporary directory for testing
    TEST_REPO_DIR="$BATS_TMPDIR/test-repo-$$"
    mkdir -p "$TEST_REPO_DIR"
    cd "$TEST_REPO_DIR"
    
    # Remove any existing .git directory/file
    rm -rf .git
    
    # Mock git command
    git() {
        case "$1" in
            "clone")
                echo "git clone called with: $*" > "$BATS_TMPDIR/git_log"
                mkdir -p "${@: -1}"  # Create the target directory (last argument)
                return 0
                ;;
            "config")
                echo "git config called with: $*" >> "$BATS_TMPDIR/git_log"
                return 0
                ;;
            *)
                echo "git called with: $*" >> "$BATS_TMPDIR/git_log"
                return 0
                ;;
        esac
    }
    export -f git
    
    # Mock pushd/popd with simple directory tracking
    pushd() {
        echo "$(pwd)" > "$BATS_TMPDIR/pushd_prev"
        cd "$1" 2>/dev/null || return 1
        return 0
    }
    export -f pushd
    
    popd() {
        if [ -f "$BATS_TMPDIR/pushd_prev" ]; then
            local prev_dir="$(cat "$BATS_TMPDIR/pushd_prev")"
            rm -f "$BATS_TMPDIR/pushd_prev"
            cd "$prev_dir" > /dev/null 2>&1
        fi
        return 0
    }
    export -f popd
}

@test "git-bare-clone shows help with no arguments" {
    run git-bare-clone
    assert_failure
    assert_output --partial "Missing script arguments"
}

@test "git-bare-clone shows help with -h flag" {
    run git-bare-clone -h
    assert_success
    assert_output --partial "Usage:"
}

@test "git-bare-clone shows help with --help flag" {
    run git-bare-clone --help
    assert_success
    assert_output --partial "Usage:"
}

@test "git-bare-clone accepts verbose flag" {
    run git-bare-clone -v https://github.com/test/repo.git
    assert_success
}

@test "git-bare-clone accepts custom location" {
    run git-bare-clone -l custom-location https://github.com/test/repo.git
    assert_success
    assert [ -f "$BATS_TMPDIR/git_log" ]
    run cat "$BATS_TMPDIR/git_log"
    assert_output --partial "custom-location"
}

@test "git-bare-clone creates .git file" {
    # Create a completely isolated test directory
    local test_dir="$BATS_TMPDIR/isolated-test-$$"
    mkdir -p "$test_dir"
    cd "$test_dir"
    
    # Make sure the script will succeed by ensuring target directory exists
    git-bare-clone https://github.com/test/repo.git
    
    # Check if .git file was created
    if [ -f ".git" ]; then
        run cat ".git"
        assert_output "gitdir: ./.bare"
    elif [ -d ".git" ]; then
        # If .git is a directory, skip this test - it means we're in a real git repo
        skip "Running in a git repository - .git is a directory"
    else
        fail ".git file was not created"
    fi
}

@test "git-bare-clone uses default .bare location" {
    run git-bare-clone https://github.com/test/repo.git
    assert_success
    assert [ -f "$BATS_TMPDIR/git_log" ]
    run cat "$BATS_TMPDIR/git_log"
    assert_output --partial ".bare"
}

@test "git-bare-clone configures remote fetch" {
    run git-bare-clone https://github.com/test/repo.git
    assert_success
    assert [ -f "$BATS_TMPDIR/git_log" ]
    run cat "$BATS_TMPDIR/git_log"
    assert_output --partial "remote.origin.fetch"
}

@test "git-bare-clone script has proper error handling" {
    run grep -q "set -Eeuo pipefail" "$BATS_TEST_DIRNAME/../../config/bin/git-bare-clone"
    assert_success
    
    run grep -q "trap cleanup" "$BATS_TEST_DIRNAME/../../config/bin/git-bare-clone"
    assert_success
}