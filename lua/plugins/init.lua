local plugins = {
	"github/copilot.vim",
	"tpope/vim-fugitive",
	"tpope/vim-rhubarb",
	"tpope/vim-sleuth",
	"numToStr/Comment.nvim",
	"mbbill/undotree",
	"folke/which-key.nvim",
	require("plugins.lsp"),
	require("plugins.cmp"),
	require("plugins.conform"),
	require("plugins.gitsigns"),
	require("plugins.onedark"),
	require("plugins.lualine"),
	require("plugins.indent"),
	require("plugins.telescope"),
	require("plugins.treesitter"),
	require("plugins.nvimtree"),
	require("plugins.ufo"),
	require("plugins.bufferline"),
}

require("lazy").setup(plugins, {})

