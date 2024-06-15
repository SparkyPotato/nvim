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
		incremental_selection = {
			enable = true,
			keymaps = {
				init_selection = map.init_selection,
				node_incremental = map.node_incremental,
				scope_incremental = false,
				node_decremental = map.node_decremental,
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
	config = config,
}
