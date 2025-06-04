return {
  {
    "ThePrimeagen/harpoon",
    config = function()
      local harpoon = require("harpoon")
      harpoon.setup({})
      vim.keymap.set('n', "<leader>a", require("harpoon.mark").add_file,
        { desc = "Harpoon: Add file" })
      vim.keymap.set('n', "<C-e>", require("harpoon.ui").toggle_quick_menu,
        { desc = "Harpoon: Toggle file menu" })
      vim.keymap.set('n', "<leader>tc", require("harpoon.cmd-ui").toggle_quick_menu,
        { desc = "Harpoon: Toggle command menu" })
      vim.keymap.set('n', "<C-h>", function() require("harpoon.ui").nav_file(1) end,
        { desc = "Harpoon: Jump to file 1" })
      vim.keymap.set('n', "<C-j>", function() require("harpoon.ui").nav_file(2) end,
        { desc = "Harpoon: Jump to file 2" })
      vim.keymap.set('n', "<C-k>", function() require("harpoon.ui").nav_file(3) end,
        { desc = "Harpoon: Jump to file 3" })
      vim.keymap.set('n', "<C-l>", function() require("harpoon.ui").nav_file(4) end,
        { desc = "Harpoon: Jump to file 4" })
    end,
  },
}
