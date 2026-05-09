#!/usr/bin/env bats
#
# Tests for sesh-list-status. Mocks `sesh list` output, drives via
# CLAUDE_STATUS_MAP, and verifies the per-row glyph decoration.

setup() {
    load '../test_helper/bats-support/load'
    load '../test_helper/bats-assert/load'

    SHIM_DIR="$(mktemp -d -t shim.XXXXXX)"
    REAL_BIN="$BATS_TEST_DIRNAME/../../config/bin"

    cat > "$SHIM_DIR/sesh" <<'SH'
#!/usr/bin/env bash
# Mock sesh: read $SESH_MOCK_OUTPUT verbatim
[ "$1" = "list" ] && cat "$SESH_MOCK_OUTPUT"
SH
    chmod +x "$SHIM_DIR/sesh"

    SESH_MOCK_OUTPUT="$(mktemp -t sesh-mock.XXXXXX)"
    MAP_FILE="$(mktemp -t map.XXXXXX)"

    export SESH_MOCK_OUTPUT MAP_FILE
    export CLAUDE_STATUS_MAP="$MAP_FILE"
    export PATH="$SHIM_DIR:$REAL_BIN:$PATH"
}

teardown() {
    rm -rf "$SHIM_DIR" "$SESH_MOCK_OUTPUT" "$MAP_FILE"
}

# Real sesh output: <glyph><space><name>. Use * as the icon stand-in.
@test "row matching status=running gets spinner glyph (default frame)" {
    printf '* alpha\n* beta\n' > "$SESH_MOCK_OUTPUT"
    printf 'alpha\trunning\n' > "$MAP_FILE"
    run sesh-list-status --icons
    assert_success
    # Default frame index = 0 = ⠋
    assert_line --partial "⠋ * alpha"
    assert_line --partial "  * beta"
}

@test "spinner frame advances with CLAUDE_FRAME_FILE" {
    printf '* alpha\n' > "$SESH_MOCK_OUTPUT"
    printf 'alpha\trunning\n' > "$MAP_FILE"
    F=$(mktemp); echo 3 > "$F"
    CLAUDE_FRAME_FILE=$F run sesh-list-status --icons
    rm -f "$F"
    assert_success
    # Index 3 = ⠸
    assert_line --partial "⠸ * alpha"
}

@test "all status glyphs map correctly" {
    printf '* a\n* b\n* c\n* d\n* e\n' > "$SESH_MOCK_OUTPUT"
    cat > "$MAP_FILE" <<EOF
a	waiting
b	done
c	interrupted
d	stale
e	idle
EOF
    run sesh-list-status --icons
    assert_success
    assert_line --partial "◐ * a"
    assert_line --partial "✓ * b"
    assert_line --partial "⚠ * c"
    assert_line --partial "✗ * d"
    # idle => blank glyph (single space)
    assert_line --partial "  * e"
}

@test "row with no map entry gets blank glyph" {
    printf '* ghost\n' > "$SESH_MOCK_OUTPUT"
    : > "$MAP_FILE"
    run sesh-list-status --icons
    assert_success
    assert_line --partial "  * ghost"
}

@test "ANSI escapes in sesh output don't break glyph mapping" {
    printf '\033[34m*\033[39m alpha\n' > "$SESH_MOCK_OUTPUT"
    printf 'alpha\tdone\n' > "$MAP_FILE"
    run sesh-list-status --icons
    assert_success
    assert_line --partial "✓"
    assert_line --partial "alpha"
}
