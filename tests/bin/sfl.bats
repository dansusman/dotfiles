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
}

@test "sfl executes without errors" {
    run sfl
    assert_success
}

@test "sfl script calls xcrun with correct arguments" {
    # Test that the script contains the expected xcrun command
    run grep -q "xcrun simctl listapps booted" "$BATS_TEST_DIRNAME/../../config/bin/sfl"
    assert_success
}

@test "sfl filters for FileProvider.LocalStorage" {
    run sfl
    assert_success
    # The script should grep for the specific group identifier
    run grep -q "group.com.apple.FileProvider.LocalStorage" "$BATS_TEST_DIRNAME/../../config/bin/sfl"
    assert_success
}

@test "sfl script is executable" {
    run test -x "$BATS_TEST_DIRNAME/../../config/bin/sfl"
    assert_success
}

@test "sfl script uses correct shebang" {
    run head -n 1 "$BATS_TEST_DIRNAME/../../config/bin/sfl"
    assert_output "#!/usr/bin/env bash"
}