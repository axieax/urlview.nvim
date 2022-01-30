# urlview.nvim

A plugin which uses `vim.ui.select` to display all the links in the current buffer. Entries can also be selected to be brought up in your browser.

> Note: currently only URLs beginning with an HTTP(s) or www prefix will be picked up.

## ⚡ Requirements

This plugin requires `Neovim 0.6+`, which supports the `vim.ui.select` function. If necessary, please check out [Alternatives](#Alternatives) for other similar plugins supporting versions prior to 0.6.

## 🚀 Usage

1. Use the command `UrlView` to see all the URLs in the current buffer.

- For your convenience, feel free to set a keybind for this using `vim.api.nvim_set_keymap`.

2. You can optionally select a link to bring it up in your browser.

## 📦 Installation

Free free to install this plugin manually or with your favourite Plugin Manager. As an example, using [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use("axieax/urlview.nvim")
```

## ⚙️ Configuration

Currently just plug-n-play. Custom configuration options coming soon™..

## 🎨 Customisation

You can customise the appearance of `vim.ui.select` with plugins such as [dressing.nvim](https://github.com/stevearc/dressing.nvim). In the demo above, I used the [telescope](https://github.com/nvim-telescope/telescope.nvim) option, which further allows me to filter and fuzzy search through my entries.

## 🛍️ Alternatives

- [urlview-vim](https://github.com/strboul/urlview.vim)

## 🚧 Extras

Feel free to file an issue or create a PR :)
