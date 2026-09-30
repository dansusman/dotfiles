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

    cat > "$SHIM_DIR/tmux" <<'SH'
#!/usr/bin/env bash
case "$1" in
  list-sessions) cat "$TMUX_SESSIONS_FIXTURE" 2>/dev/null ;;
esac
SH
    chmod +x "$SHIM_DIR/tmux"

    SESH_MOCK_OUTPUT="$(mktemp -t sesh-mock.XXXXXX)"
    MAP_FILE="$(mktemp -t map.XXXXXX)"
    TMUX_SESSIONS_FIXTURE="$(mktemp -t tmuxsess.XXXXXX)"

    export SESH_MOCK_OUTPUT MAP_FILE TMUX_SESSIONS_FIXTURE
    export CLAUDE_STATUS_MAP="$MAP_FILE"
    export PATH="$SHIM_DIR:$REAL_BIN:$PATH"
}

teardown() {
    rm -rf "$SHIM_DIR" "$SESH_MOCK_OUTPUT" "$MAP_FILE" "$TMUX_SESSIONS_FIXTURE"
}

add_session() { printf '%s\t%s\n' "$1" "$2" >> "$TMUX_SESSIONS_FIXTURE"; }

make_repo() {
    local dir; dir="$(mktemp -d -t repo.XXXXXX)"
    git -C "$dir" init -q -b "$1"
    git -C "$dir" -c user.name=t -c user.email=t@t commit -q --allow-empty -m init
    echo "$dir"
}

# Real sesh output: <icon><space><name>. Use * as the icon stand-in.
# Rows out: <glyph> <icon>\t<name>\t<branch>
@test "row matching status=running gets spinner glyph (default frame)" {
    printf '* alpha\n* beta\n' > "$SESH_MOCK_OUTPUT"
    printf 'alpha\trunning\n' > "$MAP_FILE"
    run sesh-list-status --icons
    assert_success
    # Default frame index = 0 = ⠋
    assert_line --partial $'⠋ *\talpha\t'
    assert_line --partial $'\xc2\xa0 *\tbeta\t'
}

@test "spinner frame advances with CLAUDE_FRAME_FILE" {
    printf '* alpha\n' > "$SESH_MOCK_OUTPUT"
    printf 'alpha\trunning\n' > "$MAP_FILE"
    F=$(mktemp); echo 3 > "$F"
    CLAUDE_FRAME_FILE=$F run sesh-list-status --icons
    rm -f "$F"
    assert_success
    # Index 3 = ⠸
    assert_line --partial $'⠸ *\talpha\t'
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
    assert_line --partial $'◐ *\ta\t'
    assert_line --partial $'✓ *\tb\t'
    assert_line --partial $'⚠ *\tc\t'
    assert_line --partial $'✗ *\td\t'
    # idle => NBSP glyph (non-collapsing filler so fzf field-splitting is stable)
    assert_line --partial $'\xc2\xa0 *\te\t'
}

@test "row with no map entry gets blank glyph" {
    printf '* ghost\n' > "$SESH_MOCK_OUTPUT"
    : > "$MAP_FILE"
    run sesh-list-status --icons
    assert_success
    assert_line --partial $'\xc2\xa0 *\tghost\t'
}

@test "ANSI escapes in sesh output don't break glyph mapping" {
    printf '\033[34m*\033[39m alpha\n' > "$SESH_MOCK_OUTPUT"
    printf 'alpha\tdone\n' > "$MAP_FILE"
    run sesh-list-status --icons
    assert_success
    assert_line --partial "✓"
    assert_line --partial "alpha"
}

@test "tmux session rows get their git branch, padded to a column" {
    printf '* alpha\n* longer-name\n* other\n' > "$SESH_MOCK_OUTPUT"
    : > "$MAP_FILE"
    repo_a="$(make_repo feature/x)"
    repo_b="$(make_repo main)"
    add_session alpha "$repo_a"
    add_session longer-name "$repo_b"
    run sesh-list-status --icons
    rm -rf "$repo_a" "$repo_b"
    assert_success
    assert_line --index 0 $'\xc2\xa0 *\talpha       \t\033[2mfeature/x\033[22m'
    assert_line --index 1 $'\xc2\xa0 *\tlonger-name \t\033[2mmain\033[22m'
    assert_line --index 2 $'\xc2\xa0 *\tother\t'
}

@test "tmux session outside a git repo gets no branch" {
    printf '* alpha\n' > "$SESH_MOCK_OUTPUT"
    : > "$MAP_FILE"
    dir="$(mktemp -d -t norepo.XXXXXX)"
    add_session alpha "$dir"
    run sesh-list-status --icons
    rm -rf "$dir"
    assert_success
    assert_line --index 0 $'\xc2\xa0 *\talpha\t'
}
