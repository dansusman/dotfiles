return {
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
    },
    config = function()
      local gitsigns = require('gitsigns')
      gitsigns.setup()
      -- Navigation
      vim.keymap.set('n', '<leader>hw', function() gitsigns.nav_hunk('next') end,
        { desc = "Git: Next [H]unk" })
      vim.keymap.set('n', '<leader>he', function() gitsigns.nav_hunk('prev') end,
        { desc = "Git: pr[E]vious [H]unk" })
      -- Actions
      vim.keymap.set('n', '<leader>hs', gitsigns.stage_hunk, { desc = "Git: [S]tage [H]unk" })
      vim.keymap.set('n', '<leader>hr', gitsigns.reset_hunk, { desc = "Git: [R]eset [H]unk" })
      vim.keymap.set('v', '<leader>hs',
        function() gitsigns.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end,
        { desc = "Git: [S]tage [H]unk" })
      vim.keymap.set('v', '<leader>hr',
        function() gitsigns.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end,
        { desc = "Git: [R]eset [H]unk" })
      vim.keymap.set('n', '<leader>hsb', gitsigns.stage_buffer, { desc = "Git: [S]tage [B]uffer" })
      vim.keymap.set('n', '<leader>hu', gitsigns.undo_stage_hunk, { desc = "Git: [U]ndo [H]unk" })
      vim.keymap.set('n', '<leader>hrb', gitsigns.reset_buffer, { desc = "Git: [R]eset [B]uffer" })
      vim.keymap.set('n', '<leader>hP', gitsigns.preview_hunk, { desc = "Git: [P]review [H]unk" })
      vim.keymap.set('n', '<leader>hl', function() gitsigns.blame_line { full = true } end,
        { desc = "Git: blame [L]ine" })
      vim.keymap.set('n', '<leader>ht', gitsigns.toggle_current_line_blame,
        { desc = "Git: [T]oggle line blame" })
      vim.keymap.set('n', '<leader>hd', gitsigns.toggle_deleted, { desc = "Git: toggle [D]eleted" })
      -- Text object
      vim.keymap.set({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>',
        { desc = "Git: Select Hunk" })
    end,
  },
}
