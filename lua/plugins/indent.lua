local function config()
	local highlight = {
		"RainbowRed",
		"RainbowYellow",
		"RainbowBlue",
		"RainbowOrange",
		"RainbowGreen",
		"RainbowViolet",
		"RainbowCyan",
	}

	vim.g.rainbow_delimiters = { highlight = highlight }
	require("ibl").setup()
end

return {
	"lukas-reineke/indent-blankline.nvim",
	main = "ibl",
	dependencies = {
		"HiPhish/rainbow-delimiters.nvim",
	},
	config = config,
}
