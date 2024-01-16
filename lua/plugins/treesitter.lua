local function config()
	local map = require("mappings").ts
	require("nvim-treesitter.configs").setup {
		ensure_installed = { "c", "cpp", "lua", "python", "rust", "tsx", "javascript", "typescript", "vimdoc", "vim", "bash" },
		auto_install = true,
		sync_install = false,
		ignore_install = {},
		modules = {},
		highlight = { enable = true },
		indent = { enable = true },
		textobjects = {
			move = {
				enable = true,
				set_jumps = true, -- whether to set jumps in the jumplist
				goto_next_start = map.go_next_start,
				goto_next_end = map.go_next_end,
				goto_previous_start = map.go_previous_start,
				goto_previous_end = map.go_previous_end,
			},
		},
	}
end

return {
	"nvim-treesitter/nvim-treesitter",
	dependencies = {
		"nvim-treesitter/nvim-treesitter-textobjects",
	},
	build = ":TSUpdate",
	config = function ()
		vim.defer_fn(config, 0)
	end
}

