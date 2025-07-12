#!/usr/bin/env bats

setup() {
    load '../test_helper/bats-support/load'
    load '../test_helper/bats-assert/load'
    PATH="$BATS_TEST_DIRNAME/../../config/bin:$PATH"
    
    # Enable mock mode for testing
    export AIRDROP_MOCK=1
    export AIRDROP_MOCK_FILE="$BATS_TMPDIR/airdrop_actions"
    
    # Clean up any existing mock file
    rm -f "$AIRDROP_MOCK_FILE"
}

@test "airdrop executes without errors in mock mode" {
    run airdrop
    assert_success
    assert_output "AirDrop launched (mock mode)"
}

@test "airdrop calls togglewifi and opens app" {
    run airdrop
    assert_success
    
    # Check that actions were recorded
    assert [ -f "$AIRDROP_MOCK_FILE" ]
    
    # Check first action is togglewifi
    run head -n 1 "$AIRDROP_MOCK_FILE"
    assert_output "togglewifi called"
    
    # Check second action is opening app
    run tail -n 1 "$AIRDROP_MOCK_FILE"
    assert_output "Airdrop.app opened"
}

@test "airdrop creates action log file" {
    run airdrop
    assert_success
    assert [ -f "$AIRDROP_MOCK_FILE" ]
    
    # Check file contains both expected actions
    line_count=$(wc -l < "$AIRDROP_MOCK_FILE" | tr -d ' ')
    assert_equal "$line_count" "2"
}

@test "airdrop script calls togglewifi from correct path" {
    # Verify the script references ~/bin/togglewifi
    run grep -q "~/bin/togglewifi" "$BATS_TEST_DIRNAME/../../config/bin/airdrop"
    assert_success
}