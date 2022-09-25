# 🔎 urlview.nvim

UrlView is a plugin for the [Neovim](https://neovim.io) text editor which essentially:

1. Finds URLs from a variety of **search contexts** (e.g. from a buffer, file, [packer.nvim](https://github.com/wbthomason/packer.nvim) and [vim-plug](https://github.com/junegunn/vim-plug) plugin URLs)
2. Displays these URLs in a **picker**, such as the built-in `vim.ui.select` or [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
3. Performs **actions** on selected URLs, such as navigating to the URL in your preferred browser, or copying the link to your clipboard.

Additional features or use cases include:

- Easily visualise all the URLs in a buffer or file (e.g. links in your Markdown documents)
- Quickly accessing the webpages for plugins managed by [packer.nvim](https://github.com/wbthomason/packer.nvim) or [vim-plug](https://github.com/junegunn/vim-plug) (life-saver for config updates)
- Ability to register custom searchers (e.g. Jira ticket numbers), pickers and actions
- Jumping to the previous or next URL

> Please note that currently, this plugin only detects URLs beginning with a `http(s)` or `www` prefix for buffer and file search, but there are plans to support a more general pattern (see [🗺️ Roadmap](https://github.com/axieax/urlview.nvim/issues/3)).

## 📸 Screenshots

### 📋 Buffer Links

`:UrlView` or `:UrlView buffer`

![buffer-demo](https://user-images.githubusercontent.com/62098008/161417569-e8103fc4-a009-4c4f-95a7-ea7e22cbb3df.png)

### 🔌 Plugin Links

`:UrlView packer` or `:UrlView vimplug` depending on your plugin manager of choice

![packer-demo](https://user-images.githubusercontent.com/62098008/161417652-fd514310-a926-4ec7-af28-b2cfa3aa4b19.png)

## ⚡ Requirements

This plugin requires **Neovim 0.6+**. If necessary, please check out **Alternatives** for other similar plugins supporting versions prior to 0.6.

## 🚀 Usage

### Searching contexts

1. Use the command `:UrlView` to see all the URLs in the current buffer.

- For your convenience, feel free to setup a keybind for this using `vim.api.nvim_set_keymap` (v0.6+) or `vim.keymap.set` (v0.7+)

  ```lua
  vim.keymap.set("n", "\\u", "<Cmd>UrlView<CR>", { desc = "view buffer URLs" })
  vim.keymap.set("n", "\\U", "<Cmd>UrlView packer<CR>", { desc = "view plugin URLs" })
  ```

- You can also hit `:UrlView <tab>` to see additional contexts that you can search from
  - e.g. `:UrlView packer` to view links for installed [packer.nvim](https://github.com/wbthomason/packer.nvim) plugins

2. You can optionally select a link to bring it up in your browser.

### Buffer URL navigation

1. You can use `[u` and `]u` (default bindings) to jump to the previous and next URL in the buffer respectively.
2. This keymap can be altered under the `jump` config option.

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
  -- By default, this is "netrw", or "system" if netrw is disabled
  default_action = "netrw",
  -- Ensure links shown in the picker are unique (no duplicates)
  unique = true,
  -- Ensure links shown in the picker are sorted alphabetically
  sorted = true,
  -- Minimum log level (recommended at least `vim.log.levels.WARN` for error detection warnings)
  log_level_min = vim.log.levels.INFO,
  -- Keymaps for jumping to previous / next URL in buffer
  jump = {
    prev = "[u",
    next = "]u",
  },
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

You can customise the appearance of `vim.ui.select` with plugins such as [dressing.nvim](https://github.com/stevearc/dressing.nvim) and [telescope-ui-select.nvim](https://github.com/nvim-telescope/telescope-ui-select.nvim). In the demo above, I used [dressing.nvim](https://github.com/stevearc/dressing.nvim)'s Telescope option, which allows me to further filter and fuzzy search through my entries.

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

You can also subscribe to [🙉 Breaking Changes](https://github.com/axieax/urlview.nvim/issues/37) to be updated on breaking changes to this plugin + resolution strategies.
