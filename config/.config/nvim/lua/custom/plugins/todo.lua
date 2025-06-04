return {
  {
    "folke/todo-comments.nvim", -- Highlight todo, notes, etc in comments
    event = "VimEnter",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = false },
  },
}
