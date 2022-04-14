return require("telescope").register_extension({
  exports = {
    urlview = function(opts)
      opts.picker = "telescope"
      return require("urlview").search(opts.ctx, opts)
    end,
  },
})
