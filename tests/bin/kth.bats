#!/usr/bin/env bats

setup() {
    load '../test_helper/bats-support/load'
    load '../test_helper/bats-assert/load'
    PATH="$BATS_TEST_DIRNAME/../../config/bin:$PATH"
}

@test "kth converts ctrl+a correctly" {
    run kth ctrl+a
    assert_success
    assert_output '\x01'
}

@test "kth handles multiple keys" {
    run kth ctrl+a E
    assert_success
    assert_output '\x01\x45'
}

@test "kth converts escape key" {
    run kth escape
    assert_success
    assert_output '\x1b'
}

@test "kth converts single character" {
    run kth s
    assert_success
    assert_output '\x73'
}

@test "kth shows help with no args" {
    run kth
    assert_success
    assert_output --partial "Usage:"
}

@test "kth shows help with -h flag" {
    run kth -h
    assert_success
    assert_output --partial "Usage:"
}

@test "kth handles unknown key gracefully" {
    run kth invalidkey
    assert_success
    assert_output --partial '\x'
}