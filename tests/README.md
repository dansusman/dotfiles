# Dotfiles Testing

This directory contains unit tests for dotfiles using the [bats-core](https://github.com/bats-core/bats-core) testing framework.

## Dependencies

The test suite relies on three git submodules:
- `bats/` - Main bats-core testing framework
- `test_helper/bats-support/` - Support functions for test setup
- `test_helper/bats-assert/` - Assertion helpers for cleaner test syntax

## Setup on New Machines

When cloning dotfiles on a new machine, submodules need to be initialized:

### Option 1: Clone with submodules
```bash
git clone --recurse-submodules https://github.com/your-username/dotfiles.git
```

### Option 2: Initialize after cloning
```bash
git clone https://github.com/your-username/dotfiles.git
cd dotfiles
git submodule update --init --recursive
```

## Running Tests

### Run all tests
```bash
./tests/bats/bin/bats tests/
```

### Run specific test file
```bash
./tests/bats/bin/bats tests/bin/test_kth.bats
```

### Run with verbose output
```bash
./tests/bats/bin/bats --verbose-run tests/bin/test_kth.bats
```

## Updating Submodules

To update bats-core and helpers to latest versions:

```bash
# Update all submodules to latest
git submodule update --remote

# Or update specific submodule
git submodule update --remote tests/bats

# Commit the updates
git add .gitmodules tests/
git commit -m "Update bats-core submodules"
```

## Test Structure

```
tests/
├── README.md                    # This file
├── bats/                        # bats-core submodule
├── test_helper/
│   ├── bats-support/           # bats-support submodule  
│   └── bats-assert/            # bats-assert submodule
└── bin/
    └── test_kth.bats           # Tests for bin/kth script
```

## Writing New Tests

### Basic test structure:
```bash
#!/usr/bin/env bats

setup() {
    load '../test_helper/bats-support/load'
    load '../test_helper/bats-assert/load'
    # Add your bin scripts to PATH
    PATH="$BATS_TEST_DIRNAME/../config/bin:$PATH"
}

@test "test description" {
    run your_script arg1 arg2
    assert_success
    assert_output "expected output"
}
```

### Useful assertions:
- `assert_success` - Exit code 0
- `assert_failure` - Non-zero exit code  
- `assert_output "text"` - Exact output match
- `assert_output --partial "text"` - Partial output match
- `assert_line "text"` - Check specific line in output

## Test Categories

### bin/ tests
Unit tests for custom scripts in `config/bin/`

### Future test categories could include:
- `config/` - Config file syntax validation
- `setup/` - Installation script tests
- `integration/` - End-to-end dotfiles tests

## Troubleshooting

### Submodule issues
```bash
# Reset submodules if corrupted
git submodule deinit --all
git submodule update --init --recursive
```

### PATH issues in tests
Ensure your setup() function correctly adds script directories to PATH:
```bash
PATH="$BATS_TEST_DIRNAME/../../config/bin:$PATH"
```

### Test failures
Run with `--verbose-run` flag to see detailed output and debug failing tests.