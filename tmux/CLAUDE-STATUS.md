# Claude Code status indicators in tmux + sesh

Live indicators for Claude Code instances:

- **tmux status-line** — pill in the status-right showing per-status counts
  across every Claude owned by the current tmux server (e.g. `◐ 2 ⏳ 1 ✓ 1`,
  or `∅` when nothing is running).
- **sesh picker** — per-row glyph next to each tmux session in the
  `prefix-K` / `prefix-R` picker. Running rows animate; idle/done rows are
  static.

No new dependencies on the picker side — the only new runtime is
`fswatch` (Homebrew) used by the background daemon.

## Components

```
~/.dotfiles/
├── tmux/
│   ├── claude-status-daemon       # fswatch-driven cache refresher
│   ├── CLAUDE-STATUS.md           # this file
│   ├── theme.tmux                 # injects daemon spawn + status-right pill
│   └── .tmux.conf                 # binds prefix-K / prefix-R to sesh-pick
├── config/bin/
│   ├── claude-status-pids         # canonical primitive: per-PID Claude state
│   ├── claude-status-map          # project per-PID -> per-tmux-session
│   ├── claude-status-summary      # status-line pill (counts by status)
│   ├── claude-pick-tick           # one tick of the sesh-pick reload loop
│   ├── sesh-list-status           # decorate `sesh list` rows with glyphs
│   └── sesh-pick                  # picker entrypoint (fzf wrapper)
└── tests/bin/
    ├── claude-status-summary.bats
    ├── claude-status-pids.bats
    ├── claude-status-map.bats
    ├── sesh-list-status.bats
    └── claude-status-daemon.bats
```

### Single canonical walk

Detection lives in one place: **`claude-status-pids`** is the only script
that walks live `claude` processes and classifies their jsonls. It emits
TSV rows of `<pid>\t<ppid>\t<cwd>\t<jsonl>\t<status>`, which the daemon
caches at `/tmp/claude-status.cache`. Both consumers project from this
primitive — no parallel walks, no duplicated jsonl parsing.

```
                    ┌─────────────────────┐
                    │  claude-status-pids │  (canonical primitive)
                    └──────────┬──────────┘
                               │
              fswatch ─────────┴────────── daemon (refreshes cache)
                               │
                  /tmp/claude-status.cache
                       │              │
                       ▼              ▼
        claude-status-summary    claude-status-map
        (counts by status,        (joins to tmux
         filters by tmux           sessions, picks
         server ancestor)          best status per
                                   session)
                       │              │
                       ▼              ▼
              tmux status-line    sesh picker rows
```

Each consumer is just `read cache + project`:

| Consumer                | Operation                                                 |
| ----------------------- | --------------------------------------------------------- |
| `claude-status-summary` | filter PIDs by ancestor of `tmux #{pid}`, group by status |
| `claude-status-map`     | group by encoded(cwd), join to `tmux list-sessions`       |

## Status vocabulary and priority

Status values flow from a single classifier and are shared across
components. The picker shows one glyph per row, so when a tmux session
contains multiple Claude threads the highest-priority status wins.

| Status        | Glyph | Meaning                                           |
| ------------- | ----- | ------------------------------------------------- |
| `running`     | `●`   | Active turn (text, thinking, or tool_use <3s old) |
| `waiting`     | `◐`   | tool_use with no growth for ≥3s (permission?)     |
| `interrupted` | `⚠`   | User pressed Esc / Ctrl-C                         |
| `done`        | `✓`   | `stop_reason: end_turn`                           |
| `stale`       | `✗`   | running/waiting with no growth for ≥15s           |
| `idle`        | ` `   | No recent jsonl, or no project dir                |

Aggregation order: **running > waiting > interrupted > done > stale > idle**.
The animated running glyph in the picker is a braille spinner whose frame
advances each tick.

## Tmux setup

Two integration points in `theme.tmux`:

1. **Daemon spawn**, near the top of the file:
   ```bash
   ( "$HOME/.dotfiles/tmux/claude-status-daemon" </dev/null >/dev/null 2>&1 & ) 2>/dev/null
   ```
   Idempotent — the daemon's pidfile prevents duplicates. Spawned every
   time tmux re-reads the theme, which is fine.

2. **Status-right pill** uses the `claude_status` placeholder:
   ```bash
   claude_status='#($HOME/.dotfiles/config/bin/claude-status-summary)'
   tmux set-option -gq status-right "$(make_bubble " $claude_status " "$color_active" "$color_dark") $(make_activatable_bubble "$git")"
   ```

`status-interval` controls refresh rate. With the daemon in place
1Hz is essentially free — `claude-status-summary` does its own process walk
but each call is <100ms.

## Sesh picker

`prefix-K` (global) and `prefix-R` (root path) both invoke `sesh-pick`:

```tmux
bind-key "K" run-shell "~/.dotfiles/config/bin/sesh-pick"
bind-key "R" run-shell "~/.dotfiles/config/bin/sesh-pick root"
```

### Animation mechanism

`sesh-pick` perpetuates an fzf reload chain so spinner frames advance:

```
fzf --bind 'load:reload-sync(claude-pick-tick STATE MAP FRAME)'
```

`claude-pick-tick`:
1. Bumps the frame counter file.
2. Refreshes the status map (from the daemon's cache when present).
3. Sleeps `0.12s` if anything is `running`/`waiting` (drives ~8fps); `3s`
   otherwise (idle throttle — barely any cost when nothing's happening).
4. Emits decorated rows for the active mode.

After each reload completes, fzf fires `load` again → next reload starts →
loop. Mode (default / tmux / configs / zoxide / find) is held in a state
file so `ctrl-a/t/g/x/f` switches survive the chain.

When fzf exits (selection or escape), the loop dies with it.

### Performance

Steady-state cost (no picker open):
- Daemon: idle on `fswatch` events plus a 2s tick. ~0% CPU.
- Status-line at 1Hz: ~5% one core if you have many Claudes; less in practice.

While picker is open + something running: ~55% one core. Picker is
typically open for a few seconds, so total cost per use is fractions of a
CPU-second.

## Daemon details

`tmux/claude-status-daemon` watches `~/.claude/projects/` and keeps
`/tmp/claude-status.cache` fresh. The cache format matches
`claude-status-map`: tab-separated `<session-name>\t<status>`.

### Architecture

```
fswatch ~/.claude/projects/ ─┐
                             ├──▶ FIFO ──▶ refresh()
2s ticker (mtime promotions) ┘             │
                                           └──▶ claude-status-map > /tmp/claude-status.cache
```

Two producers feed a single FIFO of NUL-delimited "wakeup" markers.
`fswatch` covers writes from Claude itself; the periodic ticker covers
mtime-based status promotions (e.g. running → waiting after 3s of no
growth, which fs events alone won't trigger).

### Single-instance and lifecycle

- PID file: `/tmp/claude-status-daemon.pid` (overridable via
  `$CLAUDE_STATUS_LOCK`).
- On startup: if the pidfile points to a live process, exit 0 silently.
  Stale pidfiles are reclaimed.
- On `INT`/`TERM`: cleanup trap kills watcher + ticker, removes pidfile +
  fifo, exits 0.

### Environment overrides

| Variable                  | Default                            | Purpose                                  |
| ------------------------- | ---------------------------------- | ---------------------------------------- |
| `CLAUDE_STATUS_CACHE`     | `/tmp/claude-status.cache`         | Output cache path                        |
| `CLAUDE_STATUS_LOCK`      | `/tmp/claude-status-daemon.pid`    | PID file path                            |
| `CLAUDE_STATUS_TICK_SECS` | `2`                                | Periodic tick (for mtime promotions)     |

### Manual control

```bash
# Start in foreground for debugging
~/.dotfiles/tmux/claude-status-daemon

# Force restart (after editing the script)
pkill -f claude-status-daemon
tmux source-file ~/.tmux.conf

# Inspect current cache
cat /tmp/claude-status.cache
```

## Testing

Tests use `bats-core`, vendored in `tests/bats/` as a submodule. The four
test files cover the entire status pipeline.

### Run all

```bash
cd ~/.dotfiles
./tests/bats/bin/bats tests/bin/claude-*.bats tests/bin/sesh-*.bats
```

### Run one file

```bash
./tests/bats/bin/bats tests/bin/claude-status-summary.bats
```

### Coverage by file

| File                          | Tests | Focus                                                              |
| ----------------------------- | ----- | ------------------------------------------------------------------ |
| `claude-status-summary.bats`  | 19    | `--classify` over synthetic jsonls + pill rendering from cache     |
| `claude-status-pids.bats`     | 8     | Canonical walker: ps/lsof mocks, status mapping, multi-PID dedup   |
| `claude-status-map.bats`      | 9     | Per-tmux-session projection + priority resolution from cache rows  |
| `sesh-list-status.bats`       | 5     | Row decoration, frame advance, ANSI tolerance                      |
| `claude-status-daemon.bats`   | 5     | Lifecycle: startup, pidfile, single-instance, ticker               |

### Test patterns

- **No live system access.** All tests build hermetic fixtures: fake
  `$HOME`, mocked `tmux`/`sesh`/`claude-status-map`/`fswatch` shimmed onto
  `$PATH`.
- **Time control via `touch -t`.** The mtime-based heuristics (waiting at
  ≥3s, stale at ≥15s, ignore at >5min) are exercised by backdating fixture
  jsonls to a precise age in seconds.
- **Daemon as black box.** `claude-status-daemon.bats` starts the daemon
  with `</dev/null >/dev/null 2>&1` to prevent bats's captured FDs from
  hanging the test on teardown, then watches the cache file for evidence
  of work.

### Adding tests

```bash
#!/usr/bin/env bats
setup() {
    load '../test_helper/bats-support/load'
    load '../test_helper/bats-assert/load'
    PATH="$BATS_TEST_DIRNAME/../../config/bin:$PATH"
}

@test "describe what's being tested" {
    run my-script arg
    assert_success
    assert_output "expected"
}
```

## Dependencies

- **fswatch** (`brew install fswatch`) — required by the daemon.
  Tracked in `brew/Brewfile`.
- **bats-core** — vendored under `tests/bats/` as a submodule.
- **awk, sed, grep, tail, stat, mktemp** — POSIX baseline.
- No `jq` / `python` / `node` runtime dependencies.

## Troubleshooting

**Picker rows aren't getting status glyphs**
- Check the cache: `cat /tmp/claude-status.cache`. Empty or missing?
  Daemon may not be running. `pgrep -fl claude-status-daemon`.
- If running but cache stale, kick it: `pkill -f claude-status-daemon &&
  tmux source-file ~/.tmux.conf`.

**Status-line pill always says `∅`**
- The summary script walks Claude PIDs descended from the tmux server
  PID. If you launched Claude outside tmux it won't count. Confirm with
  `pgrep -x claude` and `tmux display -p '#{pid}'`.

**Daemon won't start**
- `bash ~/.dotfiles/tmux/claude-status-daemon` in a terminal — any error
  about `fswatch` means it isn't installed.
- Stale pidfile pointing at a live unrelated process? Inspect with
  `cat /tmp/claude-status-daemon.pid` and `ps -p <pid>`.

**Spinner frames look frozen**
- Confirm running detection at each layer:
  ```bash
  claude-status-pids   # raw per-PID rows
  claude-status-map    # per-tmux-session projection
  ```
  If a session shows `done` but you expect `running`, multiple Claudes
  may share that project dir — `claude-status-pids | grep <cwd>` to see
  every PID claiming it. The picker shows the highest-priority status
  per session.
