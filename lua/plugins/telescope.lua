local function find_git_root()
	local current_file = vim.api.nvim_buf_get_name(0)
	local current_dir
	local cwd = vim.fn.getcwd()
	if current_file == "" then
		current_dir = cwd
	else
		current_dir = vim.fn.fnamemodify(current_file, ':h')
	end

	local git_root = vim.fn.systemlist("git -C " .. vim.fn.escape(current_dir, " ") .. " rev-parse --show-toplevel")[1]
	if vim.v.shell_error ~= 0 then
		print "Not a git repository. Searching on current working directory"
		return cwd
	end
	return git_root
end

local function live_grep_git_root()
	local git_root = find_git_root()
	if git_root then
		require("telescope.builtin").live_grep {
			search_dirs = { git_root },
		}
	end
end

local function telescope_live_grep_open_files()
	require("telescope.builtin").live_grep {
		grep_open_files = true,
		prompt_title = "Live Grep in Open Files",
	}
end

local function config()
	local telescope = require("telescope")
	telescope.setup {
		defaults = {
			layout_strategy="vertical",
			mappings = {
				i = {
					["<C-u>"] = false,
					["<C-d>"] = false,
				},
			},
		},
	}
	require("telescope").load_extension("fzf")

	vim.api.nvim_create_user_command("LiveGrepGitRoot", live_grep_git_root, {})
	vim.api.nvim_create_user_command("LiveGrepOpenFiles", telescope_live_grep_open_files, {})
end

return {
	"nvim-telescope/telescope.nvim",
	branch = '0.1.x',
	dependencies = {
		"nvim-lua/plenary.nvim",
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build =
			'cmake -S. -Bbuild -DCMAKE_POLICY_VERSION_MINIMUM="3.5" -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build'
		},
	},
	config = config,
}

