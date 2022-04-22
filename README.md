# 🔎 urlview.nvim

UrlView is a [Neovim](https://neovim.io) plugin which displays links from a variety of contexts (e.g. from a buffer, file, [packer.nvim](https://github.com/wbthomason/packer.nvim) and [vim-plug](https://github.com/junegunn/vim-plug) plugin URLs), using the built-in `vim.ui.select` or [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) as a picker. These entries can also be selected to be brought up in your browser.

> Please note that currently, this plugin only detects URLs beginning with a HTTP(s) or www prefix, but there are plans to support a more general pattern, see [🗺️ Roadmap](https://github.com/axieax/urlview.nvim/issues/3).

## 📸 Screenshots

### 📋 Buffer Links

`:UrlView` or `:UrlView buffer`

![buffer-demo](https://user-images.githubusercontent.com/62098008/161417569-e8103fc4-a009-4c4f-95a7-ea7e22cbb3df.png)

### 🔌 Packer Plugin Links

`:UrlView packer`

![packer-demo](https://user-images.githubusercontent.com/62098008/161417652-fd514310-a926-4ec7-af28-b2cfa3aa4b19.png)

## ⚡ Requirements

This plugin requires **Neovim 0.6+**. If necessary, please check out **Alternatives** for other similar plugins supporting versions prior to 0.6.

## 🚀 Usage

1. Use the command `:UrlView` to see all the URLs in the current buffer.

- For your convenience, feel free to set a keybind for this using `vim.api.nvim_set_keymap`
- You can also hit `:UrlView <tab>` to see additional contexts that you can search from
  - e.g. `:UrlView packer` to view links for installed [packer.nvim](https://github.com/wbthomason/packer.nvim) plugins

2. You can optionally select a link to bring it up in your browser.

## 📦 Installation

Free free to install this plugin manually or with your favourite plugin manager. As an example, using [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use("axieax/urlview.nvim")
```

## ⚙️ Configuration

This plugin supports plug-n-play, meaning you can get it up and running without any additional setup.

However, you can customise the default behaviour using the `setup` function:

```lua
require("urlview").setup({
  -- Prompt title (`<context> <default_title>`, e.g. `Buffer Links:`)
  default_title = "Links:",
  -- Default picker to display links with
  -- Options: "native" (vim.ui.select) or "telescope"
  default_picker = "native",
  -- Set the default protocol for us to prefix URLs with if they don't start with http/https
  default_prefix = "https://",
  -- Command or method to open links with
  -- Options: "netrw", "system" (default OS browser); or "firefox", "chromium" etc.
  navigate_method = "netrw",
  -- Logs user warnings
  debug = true,
  -- Custom search captures
  -- NOTE: captures follow Lua pattern matching (https://riptutorial.com/lua/example/20315/lua-pattern-matching)
  custom_searches = {
    -- KEY: search source name
    -- VALUE: custom search function or table (map with keys capture, format)
    jira = {
      capture = "AXIE%-%d+",
      format = "https://jira.axieax.com/browse/%s",
    },
  },
})
```

## 🎨 Pickers

### ✔️ Native (vim.ui.select)

You can customise the appearance of `vim.ui.select` with plugins such as [dressing.nvim](https://github.com/stevearc/dressing.nvim). In the demo above, I used the [telescope](https://github.com/nvim-telescope/telescope.nvim) option, which further allows me to filter and fuzzy search through my entries.

### 🔭 Telescope

- Additional requirements: [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- You can use Telescope as your `default_picker` using the `require("urlview").setup` function
- Alternatively, you can specify a picker dynamically with `:UrlView <ctx> picker=telescope`
- If you _really_ want access to `:Telescope urlview`, then add the following line to your config:

```lua
require("telescope").load_extension("urlview")
```

## 🛍️ Alternatives

- [urlview-vim](https://github.com/strboul/urlview.vim)

## 🚧 Extras

More features are continually being added to this plugin (see [🗺️ Roadmap](https://github.com/axieax/urlview.nvim/issues/3)). Feel free to file an issue or create a PR for any features / fixes :)
