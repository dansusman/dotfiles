#!/usr/bin/env bats

setup() {
    load '../test_helper/bats-support/load'
    load '../test_helper/bats-assert/load'
    PATH="$BATS_TEST_DIRNAME/../../config/bin:$PATH"
    
    # Mock xcrun command
    xcrun() {
        if [[ "$1" == "simctl" && "$2" == "listapps" && "$3" == "booted" ]]; then
            echo 'App[6D6F2F33-4324-4D61-9A0B-123456789ABC] = {
                "ApplicationType" = "User";
                "Bundle" = "com.apple.MobileNotes";
                "CFBundleDisplayName" = "Notes";
                "CFBundleExecutable" = "MobileNotes";
                "CFBundleIdentifier" = "com.apple.MobileNotes";
                "CFBundleName" = "Notes";
                "CFBundleVersion" = "1.0";
                "Entitlements" = {
                    "group.com.apple.FileProvider.LocalStorage" = "file:///Users/test/Library/Developer/CoreSimulator/Devices/12345678-1234-1234-1234-123456789ABC/data/Containers/Shared/AppGroup/ABCDEF12-3456-7890-ABCD-123456789ABC";
                };
                "Path" = "/Applications/MobileNotes.app";
            };'
        fi
        return 0
    }
    export -f xcrun
    
    # Mock sed command
    sed() {
        case "$1" in
            "-n")
                # Mock the sed command output
                echo "/Users/test/Library/Developer/CoreSimulator/Devices/12345678-1234-1234-1234-123456789ABC/data/Containers/Shared/AppGroup/ABCDEF12-3456-7890-ABCD-123456789ABC"
                ;;
            "s|^file://||")
                # Mock stripping file:// prefix
                while read -r line; do
                    echo "${line#file://}"
                done
                ;;
            *)
                /usr/bin/sed "$@"
                ;;
        esac
    }
    export -f sed
}

@test "ui executes without errors" {
    run ui
    assert_success
}

@test "ui script calls xcrun with correct arguments" {
    # Test that the script contains the expected xcrun command
    run grep -q "xcrun simctl listapps booted" "$BATS_TEST_DIRNAME/../../config/bin/ui"
    assert_success
}

@test "ui script contains correct sed patterns" {
    # Test that the script contains the expected sed patterns
    run grep -q 'sed -n.*group.com.apple.FileProvider.LocalStorage' "$BATS_TEST_DIRNAME/../../config/bin/ui"
    assert_success
    
    run grep -q 'sed.*s|^file://||' "$BATS_TEST_DIRNAME/../../config/bin/ui"
    assert_success
}

@test "ui script uses sed to extract and clean paths" {
    run grep -q "sed -n" "$BATS_TEST_DIRNAME/../../config/bin/ui"
    assert_success
    
    run grep -q "sed 's|^file://||'" "$BATS_TEST_DIRNAME/../../config/bin/ui"
    assert_success
}

@test "ui script filters for FileProvider.LocalStorage" {
    run grep -q "group.com.apple.FileProvider.LocalStorage" "$BATS_TEST_DIRNAME/../../config/bin/ui"
    assert_success
}

@test "ui script is a one-liner" {
    # Count non-empty lines in the script
    run grep -c "^[[:space:]]*[^[:space:]#]" "$BATS_TEST_DIRNAME/../../config/bin/ui"
    assert_output "1"
}