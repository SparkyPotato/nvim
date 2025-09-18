local map = vim.keymap.set
local cmd = vim.cmd

local function set()
	map({ "n", "v" }, "<leader>", "<Nop>", { desc = "Leader", silent = true })

	-- General
	map("n", "<C-s>", cmd.w, { desc = "Save" })

	-- Undotree
	map("n", "<leader>tu", cmd.UndotreeToggle, { desc = "Toggle [u]ndotree" })

	-- Bufferline
	map("n", "<Tab>", cmd.BufferLineCycleNext, { desc = "Next Buffer" })
	map("n", "<S-Tab>", cmd.BufferLineCyclePrev, { desc = "Prev Buffer" })
	map("n", "<leader>w", cmd.bd, { desc = "[w] Close Buffer" })

	-- UFO
	local ufo = require("ufo")
	map("n", "zO", ufo.openAllFolds, { desc = "[O]pen all folds" })
	map("n", "zC", ufo.closeAllFolds, { desc = "[C]lose all folds" })

	-- Comment
	map("n", "<leader>//", function()
		require("Comment.api").toggle.linewise.current()
	end, { desc = "[//] Comment current line" })
	map("v", "<leader>//", "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>")

	-- Diagnostic keymaps
	map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous [d]iagnostic" })
	map("n", "]d", vim.diagnostic.goto_next, { desc = "Next [d]iagnostic message" })
	map("n", "<leader>e", vim.diagnostic.open_float, { desc = "[e] Open diagnostic" })
	map("n", "<leader>d", vim.diagnostic.setloclist, { desc = "Open [d]iagnostics list" })

	-- Which key
	local key = require("which-key")
	key.add({
		{ "<leader>g",  group = "[g]it" },
		{ "<leader>g_", hidden = true },
		{ "<leader>l",  group = "[L]SP" },
		{ "<leader>l_", hidden = true },
		{ "<leader>s",  group = "[s]earch" },
		{ "<leader>s_", hidden = true },
		{ "<leader>t",  group = "[t]oggle" },
		{ "<leader>t_", hidden = true },
	})
	key.add({
		{ "<leader>", group = "VISUAL <leader>", mode = "v" },
	})

	-- FZF
	local f = require("fzf-lua")
	map("n", "<leader>/", f.blines, { desc = "[/] Fuzzily search in current buffer" })
	map("n", "<leader>?", f.oldfiles, { desc = "[?] Find recently opened files" })
	map("n", "<leader><space>", f.buffers, { desc = "[ ] Find existing buffers" })

	map("n", "<leader>sf", f.files, { desc = "[s]earch [f]iles" })
	map("n", "<leader>sg", f.live_grep, { desc = "[s]earch by [g]rep" })
	map("n", "<leader>sr", f.resume, { desc = "[s]earch [r]esume" })
	map("n", "<leader>ss", f.lsp_live_workspace_symbols, { desc = "[s]earch workspace [s]ymbols" })
	
	-- P4
	map("n", "<leader>pa", ":P4Add<CR>", { noremap = true, silent = true, desc = "[p]4 [a]dd" })
	map("n", "<leader>pc", ":P4Checkout<CR>", { noremap = true, silent = true, desc = "[p]4 [c]heckout" })

	-- Treesitter
	local ts_repeat_move = require "nvim-treesitter.textobjects.repeatable_move"
	map({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
	map({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)

	vim.api.nvim_create_user_command("Format", function(args)
		local range = nil
		if args.count ~= -1 then
			local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
			range = {
				start = { args.line1, 0 },
				["end"] = { args.line2, end_line:len() },
			}
		end
		require("conform").format({ async = true, lsp_fallback = true, range = range })
	end, { range = true })

	-- Highlight on yank
	local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
	vim.api.nvim_create_autocmd("TextYankPost", {
		callback = function()
			vim.highlight.on_yank()
		end,
		group = highlight_group,
		pattern = "*",
	})
end

local function git_mapping(bufnr)
	local function bmap(mode, l, r, opts)
		opts = opts or {}
		opts.buffer = bufnr
		map(mode, l, r, opts)
	end

	local gs = package.loaded.gitsigns
	bmap("v", "<leader>gr", function()
		gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
	end, { desc = "[r]eset hunk" })

	bmap("n", "<leader>gr", gs.reset_hunk, { desc = "[r]eset hunk" })
	bmap("n", "<leader>gR", gs.reset_buffer, { desc = "[R]eset buffer" })
	bmap("n", "<leader>gb", function()
		gs.blame_line({ full = false })
	end, { desc = "[b]lame line" })
	bmap("n", "<leader>gd", function()
		gs.diffthis("~")
	end, { desc = "[d]iff against last commit" })
end

local function cmp_mapping()
	local cmp = require("cmp")
	local luasnip = require("luasnip")
	return cmp.mapping.preset.insert({
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete({}),
		["<CR>"] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Replace,
			select = true,
		}),
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_locally_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.locally_jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
	})
end

local function lsp_mapping(_, bufnr)
	local nmap = function(keys, func, desc)
		vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
	end

	-- vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })

	nmap("<leader>ln", vim.lsp.buf.rename, "Re[n]ame")
	nmap("<leader>la", vim.lsp.buf.code_action, "Code [a]ction")

	-- FZF
	local f = require("fzf-lua")
	nmap("gd", f.lsp_definitions, "[g]oto [d]efinition")
	nmap("gr", f.lsp_references, "[g]oto [r]eferences")
	nmap("gi", f.lsp_implementations, "[g]oto [i]mplementation")
	nmap("gD", f.lsp_typedefs, "[g]oto type [D]efinition")
	nmap("<leader>sd", f.lsp_document_symbols, "[S]earch [d]ocument symbols")

	-- See `:help K` for why this keymap
	nmap("K", vim.lsp.buf.hover, "Hover Documentation")
	nmap("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")
end

local ts_mapping = {
	goto_next_start = {
		["]f"] = { query = "@function.outer", desc = "Next function start" },
		["]c"] = { query = "@class.outer", desc = "Next class start" },
		["]b"] = { query = "@block.outer", desc = "Next block start" },
		["]p"] = { query = "@parameter.outer", desc = "Next parameter start" },
		["]s"] = { query = "@statement.outer", desc = "Next statement start" },
	},
	goto_next_end = {
		["]F"] = { query = "@function.outer", desc = "Next function end" },
		["]C"] = { query = "@class.outer", desc = "Next class end" },
		["]B"] = { query = "@block.outer", desc = "Next block end" },
		["]P"] = { query = "@parameter.outer", desc = "Next parameter end" },
		["]S"] = { query = "@statement.outer", desc = "Next statement end" },
	},
	goto_previous_start = {
		["[f"] = { query = "@function.outer", desc = "Previous function start" },
		["[c"] = { query = "@class.outer", desc = "Previous class start" },
		["[b"] = { query = "@block.outer", desc = "Previous block start" },
		["[p"] = { query = "@parameter.outer", desc = "Previous parameter start" },
		["[s"] = { query = "@statement.outer", desc = "Previous statement start" },
	},
	goto_previous_end = {
		["[F"] = { query = "@function.outer", desc = "Previous function end" },
		["[C"] = { query = "@class.outer", desc = "Previous class end" },
		["[B"] = { query = "@block.outer", desc = "Previous block end" },
		["[P"] = { query = "@parameter.outer", desc = "Previous parameter end" },
		["[S"] = { query = "@statement.outer", desc = "Previous statement end" },
	},
	goto_next = {},
	goto_previous = {},
	keymaps = {
		["fa"] = { query = "@function.outer", desc = "Select outer function" },
		["fi"] = { query = "@function.inner", desc = "Select inner function" },
		["ca"] = { query = "@class.outer", desc = "Selct outer class" },
		["ci"] = { query = "@class.inner", desc = "Select inner class" },
		["ba"] = { query = "@block.outer", desc = "Select outer block" },
		["bi"] = { query = "@block.inner", desc = "Select inner block" },
		["pa"] = { query = "@parameter.outer", desc = "Select outer parameter" },
		["pi"] = { query = "@parameter.inner", desc = "Select inner parameter" },
		["s"] = { query = "@statement.outer", desc = "Select statement" },
	},
	selection_modes = {
		["@function.outer"] = "V",
		["@class.outer"] = "<c-v>",
		["@block.outer"] = "v",
		["@parameter.outer"] = "v",
		["@statement.outer"] = "V",
	},
	init_selection = "<C-space>",
	node_incremental = "<C-space>",
	scope_incremental = false,
	node_decremental = "<bs>",
}

return {
	set = set,
	cmp = cmp_mapping,
	git = git_mapping,
	lsp = lsp_mapping,
	ts = ts_mapping,
}
