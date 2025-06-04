local M = {}

-- Function to open Xcode in current working directory
M.open_xcode = function()
	local cwd = vim.fn.getcwd()
	-- Use zsh to ensure your shell script "q" is available
	local cmd = string.format("zsh -c 'cd %s && open %s'", vim.fn.shellescape(cwd), "Notability.xcworkspace")

	-- Get current git branch
	local branch = vim.fn.system("git branch --show-current 2>/dev/null"):gsub("\n", "")
	local branch_info = ""
	if branch ~= "" then
		branch_info = " [" .. branch .. "]"
	end

	-- Run the command in the background
	vim.fn.system(cmd .. " &")

	-- Print confirmation message with branch info
	print("Opening Xcode in: " .. cwd .. branch_info)
end

return M
