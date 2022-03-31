-- Default config
local config = {
	title = "Links: ", -- prompt title
	default_picker = "default", -- "default" (vim.ui.select) or "telescope"
	use_netrw = true, -- use netrw to open urls, if false use xdg-open/open system command
	debug = true, -- logs user errors
}

return config
