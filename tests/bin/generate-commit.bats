#!/usr/bin/env bats

setup() {
    load '../test_helper/bats-support/load'
    load '../test_helper/bats-assert/load'
    PATH="$BATS_TEST_DIRNAME/../../config/bin:$PATH"
    
    # Create a temporary git repo for testing
    cd "$BATS_TMPDIR"
    git init test-repo
    cd test-repo
    git config user.name "Test User"
    git config user.email "test@example.com"
    
    # Mock commands
    git() {
        case "$1" in
            "rev-parse")
                if [[ "$2" == "--git-dir" ]]; then
                    echo ".git"
                    return 0
                fi
                ;;
            "diff")
                if [[ "$2" == "--cached" ]]; then
                    if [[ "$3" == "--quiet" ]]; then
                        return 1  # Simulate staged changes
                    else
                        echo "diff --git a/test.txt b/test.txt"
                        echo "new file mode 100644"
                        echo "index 0000000..d670460"
                        echo "--- /dev/null"
                        echo "+++ b/test.txt"
                        echo "@@ -0,0 +1 @@"
                        echo "+test content"
                    fi
                fi
                ;;
            "branch")
                if [[ "$2" == "--show-current" ]]; then
                    echo "main"
                fi
                ;;
            "log")
                echo "Initial commit"
                echo "Add README"
                ;;
            "config")
                echo "Test User"
                ;;
            *)
                return 0
                ;;
        esac
    }
    export -f git
    
    # Mock gh command
    gh() {
        case "$1" in
            "issue")
                echo "[]"
                ;;
            "pr")
                echo "[]"
                ;;
            "api")
                echo "test-user"
                ;;
            *)
                return 0
                ;;
        esac
    }
    export -f gh
    
    # Mock claude command
    claude() {
        cat << 'EOF'
feat(core): add test functionality

Add new test file with sample content for
development and testing purposes.
EOF
        return 0
    }
    export -f claude
    
    # Mock command -v checks
    command() {
        if [[ "$1" == "-v" ]]; then
            case "$2" in
                "git"|"gh"|"claude")
                    echo "/usr/bin/$2"
                    return 0
                    ;;
            esac
        fi
        return 1
    }
    export -f command
}

@test "generate-commit checks for required dependencies" {
    # Create a version that fails dependency check
    command() {
        if [[ "$1" == "-v" && "$2" == "git" ]]; then
            return 1
        fi
        return 0
    }
    export -f command
    
    run generate-commit
    assert_failure
}

@test "generate-commit script contains dependency checks" {
    run grep -q "command -v git" "$BATS_TEST_DIRNAME/../../config/bin/generate-commit"
    assert_success
    
    run grep -q "command -v gh" "$BATS_TEST_DIRNAME/../../config/bin/generate-commit"
    assert_success
    
    run grep -q "command -v claude" "$BATS_TEST_DIRNAME/../../config/bin/generate-commit"
    assert_success
}

@test "generate-commit checks for git repository" {
    run grep -q "git rev-parse --git-dir" "$BATS_TEST_DIRNAME/../../config/bin/generate-commit"
    assert_success
}

@test "generate-commit checks for staged changes" {
    run grep -q "git diff --cached --quiet" "$BATS_TEST_DIRNAME/../../config/bin/generate-commit"
    assert_success
}

@test "generate-commit script has configuration section" {
    run grep -q "load_config" "$BATS_TEST_DIRNAME/../../config/bin/generate-commit"
    assert_success
    
    run grep -q "types:" "$BATS_TEST_DIRNAME/../../config/bin/generate-commit"
    assert_success
    
    run grep -q "scopes:" "$BATS_TEST_DIRNAME/../../config/bin/generate-commit"
    assert_success
}

@test "generate-commit generates expected output format" {
    run generate-commit
    assert_success
    assert_output --partial "feat(core): add test functionality"
}

@test "generate-commit suppresses stderr output" {
    run grep -q "exec 2>/dev/null" "$BATS_TEST_DIRNAME/../../config/bin/generate-commit"
    assert_success
}