local function config()
	local lspconfig = require("lspconfig")
	require("mason").setup({ PATH = "append" })

	local servers = {
		clangd = {},
		rust_analyzer = {
			settings = {
				["rust-analyzer"] = {
					assist = {
						importPrefix = "by_crate",
						termSearch = {
							fuel = 500,
						},
					},
					cargo = {
						allFeatures = true,
						buildScripts = {
							enable = true,
						},
					},
					checkOnSave = {
						command = "check",
					},
					completion = {
						termSearch = {
							fuel = 200,
						},
					},
					imports = {
						granularity = {
							group = "crate",
						},
						prefix = "crate",
					},
					procMacro = {
						enable = true,
					}
				}
			}
		},
		lua_ls = {
			settings = {
				Lua = {
					workspace = { checkThirdParty = false },
					telemetry = { enable = false },
				},
			},
		},
		slangd = {
			cmd = { "slangd" },
			settings = {
				slang = {
					format = {
						clangFormatStyle =
						"{BasedOnStyle: Google, BreakBeforeBraces: Attach, ColumnLimit: 120, UseTab: Always, IndentWidth: 4, TabWidth: 4, PointerAlignment: Left, AllowAllParametersOfDeclarationOnNextLine: true}",
					},
					inlayHints = {
						deducedTypes = true,
						parameterNames = true,
					},
				},
			},
			files = { "slang" },
			root_dir = function(f)
				return lspconfig.util.root_pattern("Cargo.toml")(f) .. "/shaders/"
			end
		},
	}

	local capabilities = vim.lsp.protocol.make_client_capabilities()
	capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
	capabilities.textDocument.foldingRange = {
		dynamicRegistration = false,
		lineFoldingOnly = true,
	}

	local function setup(name)
		lspconfig[name].setup {
			capabilities = capabilities,
			on_attach = require("mappings").lsp,
			settings = servers[name].settings,
			cmd = servers[name].cmd,
			filetypes = servers[name].files,
			root_dir = servers[name].root_dir
		}
	end

	vim.filetype.add({
		extension = {
			slang = "slang"
		}
	})

	for _, method in ipairs({ 'textDocument/diagnostic', 'workspace/diagnostic' }) do
		local default_diagnostic_handler = vim.lsp.handlers[method]
		vim.lsp.handlers[method] = function(err, result, context, config)
			if err ~= nil and err.code == -32802 then
				return
			end
			return default_diagnostic_handler(err, result, context, config)
		end
	end

	setup("rust_analyzer")
	require("mason-lspconfig").setup()
	setup("lua_ls")
	setup("clangd")
	setup("slangd")
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
