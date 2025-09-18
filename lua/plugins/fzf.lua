local function config()
	require("fzf-lua").setup {
		"telescope",
		winopts = {
			preview = {
				layout = "vertical",
			},
		},
		files = {
			fd_opts = [[--color=never --hidden --type f --type l -E .git -E .cache -E Intermediate -E Binaries -E target]]
		}
	}
end

return {
	"ibhagwan/fzf-lua",
	config = config,
}
