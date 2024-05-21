return {
	"akinsho/bufferline.nvim",
	commit = "73540cb95f8d95aa1af3ed57713c6720c78af915",
	opts = {
		options = {
			mode = "tabs",
			diagnostics_indicator = function(count, level, diagnostics_dict, context)
				local s = " "
				for e, n in pairs(diagnostics_dict) do
					local sym = e == "error" and " "
						or (e == "warning" and " " or "")
					s = s .. n .. sym
				end
				return s
			end,
			themable = true,
			offsets = {
				{ filetype = "NvimTree", highlight = "NvimTreeNormal" }
			}
		}
	}
}

