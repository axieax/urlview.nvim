return require("telescope").register_extension({
	exports = {
		urlview = function(opts)
			return require("urlview").search(opts.bufnr, "telescope", opts)
		end,
	},
})
