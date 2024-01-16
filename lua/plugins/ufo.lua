local function config()
	vim.o.foldcolumn = "1"
	vim.o.foldlevel = 99
	vim.o.foldlevelstart = 99
	vim.o.foldenable = true

	require("ufo").setup()
end

return {
	"kevinhwang91/nvim-ufo",
	dependencies = {
		"kevinhwang91/promise-async",
		"neovim/nvim-lspconfig",
	},
	config = config
}

