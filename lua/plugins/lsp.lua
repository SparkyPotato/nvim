local function config()
	require("mason").setup({ PATH = "append" })
	require("mason-lspconfig").setup()

	local servers = {
		-- clangd = {},
		-- gopls = {},
		-- pyright = {},
		-- tsserver = {},
		-- html = { filetypes = { 'html', 'twig', 'hbs'} },

		clangd = {},
		rust_analyzer = {},
		lua_ls = {
			Lua = {
				workspace = { checkThirdParty = false },
				telemetry = { enable = false },
			},
		},
	}

	require('neodev').setup()

	local capabilities = vim.lsp.protocol.make_client_capabilities()
	capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
	capabilities.textDocument.foldingRange = {
		dynamicRegistration = false,
		lineFoldingOnly = true,
	}
	local mason_lspconfig = require("mason-lspconfig")

	mason_lspconfig.setup {
		ensure_installed = vim.tbl_keys(servers),
	}

	mason_lspconfig.setup_handlers {
		function(server_name)
			require("lspconfig")[server_name].setup {
				capabilities = capabilities,
				on_attach = require("mappings").lsp,
				settings = servers[server_name],
				filetypes = (servers[server_name] or {}).filetypes,
			}
		end,
	}
end

return {
	"neovim/nvim-lspconfig",
	config = config,
	dependencies = {
		{ "williamboman/mason.nvim", config = true },
		"williamboman/mason-lspconfig.nvim",
		{ "j-hui/fidget.nvim",       opts = {} },
		"folke/neodev.nvim",
	}
}
