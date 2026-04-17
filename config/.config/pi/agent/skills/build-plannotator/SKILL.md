---
name: build-local
description: Build and install Plannotator locally as a compiled binary. Use when the user says "update plannotator", "rebuild plannotator", "install plannotator locally", "build the binary", or similar. Rebuilds the review app, hook, and compiles to ~/.local/bin/plannotator.
---

# Build & Install Plannotator Locally

Run the full build sequence in order — review app first (hook copies its HTML), then hook, then compile:

```bash
bun run --cwd apps/review build && bun run build:hook && bun build apps/hook/server/index.ts --compile --outfile ~/.local/bin/plannotator
```

**Order matters:**
1. `bun run --cwd apps/review build` — builds review editor HTML into `apps/review/dist/`
2. `bun run build:hook` — builds plan editor HTML and copies review HTML from step 1
3. `bun build ... --compile --outfile` — compiles single binary to `~/.local/bin/plannotator`

Skipping step 1 after review-editor changes will bake stale HTML into the binary.
