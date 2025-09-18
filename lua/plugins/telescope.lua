local function config()
	local telescope = require("telescope")
	telescope.setup {
		defaults = {
			layout_strategy = "vertical",
			mappings = {
				i = {
					["<C-u>"] = false,
					["<C-d>"] = false,
				},
			},
			history = {
				path = '~/AppData/Local/nvim-data/telescope_history.sqlite3',
				limit = 500,
			},
		},
	}
	telescope.load_extension("fzf")
	telescope.load_extension('smart_history')
end

return {
	"nvim-telescope/telescope.nvim",
	branch = '0.1.x',
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope-smart-history.nvim",
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build =
			'cmake -S. -Bbuild -DCMAKE_POLICY_VERSION_MINIMUM="3.5" -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build'
		},
	},
	config = config,
}

