local function config()
	local lspconfig = require("lspconfig")
	require("mason").setup({ PATH = "append" })

	local servers = {
		clangd = {},
		rust_analyzer = {
			["rust-analyzer"] = {
				checkOnSave = {
					command = "check"
				}
			}
		},
		lua_ls = {
			Lua = {
				workspace = { checkThirdParty = false },
				telemetry = { enable = false },
			}
		},
	}

	local capabilities = vim.lsp.protocol.make_client_capabilities()
	capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
	capabilities.textDocument.foldingRange = {
		dynamicRegistration = false,
		lineFoldingOnly = true,
	}

	local function setup_server(server_name)
		lspconfig[server_name].setup {
			capabilities = capabilities,
			on_attach = require("mappings").lsp,
			settings = servers[server_name],
			filetypes = (servers[server_name] or {}).filetypes,
		}
	end

	setup_server("rust_analyzer")
	local mason_lspconfig = require("mason-lspconfig")
	mason_lspconfig.setup_handlers {
		setup_server,
	}
end

return {
	"neovim/nvim-lspconfig",
	config = config,
	dependencies = {
		{ "williamboman/mason.nvim", config = true },
		"williamboman/mason-lspconfig.nvim",
		{ "j-hui/fidget.nvim",       opts = {} },
		"folke/lazydev.nvim",
	}
}
