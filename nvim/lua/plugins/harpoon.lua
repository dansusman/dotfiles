return {
  {
    "ThePrimeagen/harpoon",
    config = function()
      local nmap = require("ds.keymap").nmap

      local harpoon = require "harpoon"

      harpoon.setup {}

      nmap { "<leader>a", require("harpoon.mark").add_file }
      nmap { "<C-e>", require("harpoon.ui").toggle_quick_menu }
      nmap { "<leader>tc", require("harpoon.cmd-ui").toggle_quick_menu }

      nmap { "<C-h>", function() require("harpoon.ui").nav_file(1) end }
      nmap { "<C-j>", function() require("harpoon.ui").nav_file(2) end }
      nmap { "<C-k>", function() require("harpoon.ui").nav_file(3) end }
      nmap { "<C-l>", function() require("harpoon.ui").nav_file(4) end }

    end,
  },
}
