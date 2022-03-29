return require("telescope").register_extension({
	exports = {
		urlview = function(opts)
			return require("urlview").search("telescope", opts)
		end,
	},
})
