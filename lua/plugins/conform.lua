return {
	"stevearc/conform.nvim",
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			rust = { "rustfmt" },
			cpp = { "clang_format" },
		},
		formatters = {
			stylua = {
				prepend_args = { "--search-parent-directories" },
			},
		},
		format_on_save = {
			timeout_ms = 500,
			lsp_fallback = true,
		}
	},
}

