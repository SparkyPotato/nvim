local function config()
	local map = require("mappings").ts
	require("nvim-treesitter.configs").setup {
		textobjects = {
			move = {
				enable = true,
				set_jumps = true,
				goto_next_start = map.goto_next_start,
				goto_next_end = map.goto_next_end,
				goto_previous_start = map.goto_previous_start,
				goto_previous_end = map.goto_previous_end,
				goto_next = map.goto_next,
				goto_previous = map.goto_previous,
			},
			select = {
				enable = true,
				lookahead = true,
				keymaps = map.keymaps,
				selection_modes = map.selection_modes,
			}
		},
	}
end

return {
	"nvim-treesitter/nvim-treesitter-textobjects",
	lazy = true,
	config = config,
}
