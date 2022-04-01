-- Default config
local config = {
	-- Prompt title
	title = "Links: ",
	-- Default picker to display links with
	-- Options: "default" (vim.ui.select) or "telescope"
	default_picker = "default",
	-- Command or method to open links with
	-- Options: "netrw", "auto" (default OS browser); or "firefox", "chromium" etc.
	navigate_method = "netrw",
	-- Logs user warnings
	debug = true,
}

return config
