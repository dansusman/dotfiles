#!/usr/bin/env bats

setup() {
    load '../test_helper/bats-support/load'
    load '../test_helper/bats-assert/load'
    PATH="$BATS_TEST_DIRNAME/../../config/bin:$PATH"
    
    # Enable mock mode for testing
    export AUDIO_SWITCH_MOCK=1
    export AUDIO_SWITCH_MOCK_FILE="$BATS_TMPDIR/audio_switch_state"
    
    # Clean up any existing mock file
    rm -f "$AUDIO_SWITCH_MOCK_FILE"
}

@test "audio-switch with headphone argument uses correct device" {
    run audio-switch headphone
    assert_success
    assert_output "Audio switched to headphones (mock mode)"
    
    # Check state file was created with correct device
    run cat "$AUDIO_SWITCH_MOCK_FILE"
    assert_output "BuiltInHeadphoneOutputDevice"
}

@test "audio-switch with no argument uses LG display" {
    run audio-switch
    assert_success
    assert_output "Audio switched to LG display (mock mode)"
    
    # Check state file was created with correct device
    run cat "$AUDIO_SWITCH_MOCK_FILE"
    assert_output "LG UltraFine Display Audio"
}

@test "audio-switch with non-headphone argument uses LG display" {
    run audio-switch speakers
    assert_success
    assert_output "Audio switched to LG display (mock mode)"
    
    # Check state file was created with correct device
    run cat "$AUDIO_SWITCH_MOCK_FILE"
    assert_output "LG UltraFine Display Audio"
}

@test "audio-switch script has correct SwitchAudioSource path" {
    run grep -q "/opt/homebrew/bin/SwitchAudioSource" "$BATS_TEST_DIRNAME/../../config/bin/audio-switch"
    assert_success
}