require'nvim-treesitter.configs'.setup {
    ensure_installed = {
        "go",
        "html",
        "javascript",
        "json",
        "markdown",
        "python",
        "rust",
        "swift",
        "tsx",
        "typescript",
        "verilog",
    },
    sync_install = false,

    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
}
