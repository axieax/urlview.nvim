# 🔎 urlview.nvim

A [Neovim](https://neovim.io) plugin which displays all URLs in the current buffer, using the built-in `vim.ui.select` or [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) as a picker. These entries can also be selected to be brought up in your browser.

> Please note that currently, this plugin only detects URLs beginning with a HTTP(s) or www prefix.

![demo](https://user-images.githubusercontent.com/62098008/160542972-68278a4a-badd-4672-9d6b-ae9a3a669fd2.png)

## ⚡ Requirements

This plugin requires **Neovim 0.6+**. If necessary, please check out **Alternatives** for other similar plugins supporting versions prior to 0.6.

## 🚀 Usage

1. Use the command `:UrlView` to see all the URLs in the current buffer.

- Use `:UrlView <tab>` to view available pickers to display the URLs with
- For your convenience, feel free to set a keybind for this using `vim.api.nvim_set_keymap`

2. You can optionally select a link to bring it up in your browser.

## 📦 Installation

Free free to install this plugin manually or with your favourite Plugin Manager. As an example, using [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use("axieax/urlview.nvim")
```

## ⚙️ Configuration

This plugin supports plug-n-play, meaning you can get it up and running without any additional setup.

However, you can customise the default behaviour using the `setup` function:

```lua
require("urlview").setup({
  picker = "default" -- "default" (vim.ui.select), "telescope" (telescope.nvim)
	title = "URLs: ", -- prompt title
	debug = true, -- logs user errors
})
```

## 🎨 Pickers

### Default (vim.ui.select)

You can customise the appearance of `vim.ui.select` with plugins such as [dressing.nvim](https://github.com/stevearc/dressing.nvim). In the demo above, I used the [telescope](https://github.com/nvim-telescope/telescope.nvim) option, which further allows me to filter and fuzzy search through my entries.

### Telescope

`:UrlView telescope` works out of the box (defaulting back to `vim.ui.select` if [telescope](https://github.com/nvim-telescope/telescope.nvim) is not installed). If you set "telescope" as your default picker in `setup`, then `:UrlView` will automatically use telescope as your default picker.

Additionally, you can use `:Telescope urlview` if you add the following to your config:

```lua
require("telescope").load_extension("urlview")
```

## 🛍️ Alternatives

- [urlview-vim](https://github.com/strboul/urlview.vim)

## 🚧 Extras

More features are continually being added to this plugin (see [Roadmap](https://github.com/axieax/urlview.nvim/issues/3)). Feel free to file an issue or create a PR for any features / fixes :)
