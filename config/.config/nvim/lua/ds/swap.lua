local M = {}

M.swap_words = function(direction, cursor_pos)
	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2] + 1
	local words = {}
	local positions = {}

	-- Find all word tokens (including punctuation)
	for token, start_pos in line:gmatch("(%S+)()") do
		table.insert(words, token)
		table.insert(positions, start_pos - #token)
	end

	local current_word_idx = nil
	for i, pos in ipairs(positions) do
		if col >= pos and col < pos + #words[i] then
			current_word_idx = i
			break
		end
	end

	if not current_word_idx then return end

	local swap_idx = current_word_idx + direction
	if swap_idx < 1 or swap_idx > #words then return end

	-- Extract just the alphanumeric parts
	local function extract_word(token)
		return token:match("[%w]+") or ""
	end

	-- Extract the core words
	local word1 = extract_word(words[current_word_idx])
	local word2 = extract_word(words[swap_idx])

	-- Replace just the word parts, preserving punctuation structure
	local function replace_word_part(token, new_word)
		return token:gsub("[%w]+", new_word, 1)
	end

	words[current_word_idx] = replace_word_part(words[current_word_idx], word2)
	words[swap_idx] = replace_word_part(words[swap_idx], word1)

	local new_line = line:gsub("%S+", function()
		local word = table.remove(words, 1)
		return word
	end)

	vim.api.nvim_set_current_line(new_line)

	local target_word_idx = cursor_pos == "first" and math.min(current_word_idx, swap_idx) or
	math.max(current_word_idx, swap_idx)
	vim.api.nvim_win_set_cursor(0, { vim.api.nvim_win_get_cursor(0)[1], positions[target_word_idx] - 1 })
end

return M