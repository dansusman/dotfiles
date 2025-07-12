#!/usr/bin/env bats

setup() {
    load '../test_helper/bats-support/load'
    load '../test_helper/bats-assert/load'
    PATH="$BATS_TEST_DIRNAME/../../config/bin:$PATH"
    
    # Enable mock mode for testing
    export TOGGLEWIFI_MOCK=1
    export TOGGLEWIFI_MOCK_FILE="$BATS_TMPDIR/togglewifi_state"
    
    # Clean up any existing mock file
    rm -f "$TOGGLEWIFI_MOCK_FILE"
}

@test "togglewifi executes without errors in mock mode" {
    run togglewifi
    assert_success
    assert_output --partial "mock mode"
}

@test "togglewifi toggles state correctly" {
    # First run should turn on (default is off)
    run togglewifi
    assert_success
    assert_output "WiFi turned on (mock mode)"
    
    # Second run should turn off
    run togglewifi
    assert_success
    assert_output "WiFi turned off (mock mode)"
    
    # Third run should turn on again
    run togglewifi
    assert_success
    assert_output "WiFi turned on (mock mode)"
}

@test "togglewifi creates and maintains state file" {
    # Run once to create state file
    run togglewifi
    assert_success
    assert [ -f "$TOGGLEWIFI_MOCK_FILE" ]
    
    # Check state is saved
    run cat "$TOGGLEWIFI_MOCK_FILE"
    assert_output "on"
}

@test "togglewifi script contains expected AppleScript commands" {
    # Verify the script file contains the expected networksetup commands
    run grep -q "networksetup -getairportpower en0" "$BATS_TEST_DIRNAME/../../config/bin/togglewifi"
    assert_success
    
    run grep -q "networksetup -setairportpower en0 off" "$BATS_TEST_DIRNAME/../../config/bin/togglewifi"
    assert_success
    
    run grep -q "networksetup -setairportpower en0 on" "$BATS_TEST_DIRNAME/../../config/bin/togglewifi"
    assert_success
}