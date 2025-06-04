return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      ensure_installed = {
        "bash",
        "c",
        "diff",
        "html",
        "lua",
        "luadoc",
        "markdown",
        "swift",
        "vim",
        "vimdoc",
        "json",
        "yaml",
        "gitignore",
      },
      -- Autoinstall languages that are not installed
      auto_install = true,
      highlight = { enable = true, },
      indent = { enable = true },
      incremental_selection = {
        enable = false,
        keymaps = {
          scope_incremental = "a",
          node_decremental = "z",
        },
      },
    },
    config = function(_, opts)
      -- Prefer git instead of curl in order to improve connectivity in some environments
      require("nvim-treesitter.install").prefer_git = true
      ---@diagnostic disable-next-line: missing-fields
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
}
