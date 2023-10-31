# VIM ProSession v0.7.3

A VIM plugin to handle sessions like a pro.

It leverages vim-obsession and allows switching between multiple sessions
cleanly, the idea is to maintain one session per project (directory) and
switch between them when we need to switch context, automatically loading
along with it the various files, settings etc ensuring compete isolation
between projects. Now there's little need to launch multiple vim instances for
separate sessions (projects), you can simply switch between them with ease.

ProSession uses a file name format similar to the `undofile` name format.
`:Prosession` provides existing session paths from the sessions directory from
`g:prosession_dir` (set to `~/.vim/session/` by default) or also completes
paths from the file system which you can use to start new sessions for them.
For more details check `:help prosession`.

Prosession also provides a telescope extension, to list and switch to other
sessions with Telescope, you can use `Telescope prosession` and that launches
telescope picker with list of all existing sessions that you can find through
and select to switch to it

## Change Log

See [CHANGELOG.md](https://github.com/dhruvasagar/vim-prosession/blob/master/CHANGELOG.md)

## Requirements

Vim ProSession depends on
[tpope/vim-obsession](https://github.com/tpope/vim-obsession)

## Installation

1. With [NeoBundle](https://github.com/Shougo/neobundle.vim):

```vim
NeoBundle 'dhruvasagar/vim-prosession', {'depends': 'tpope/vim-obsession'}
```

2. With [Vundle](https://github.com/gmarik/Vundle.vim)

```vim
Plugin 'tpope/vim-obsession'
Plugin 'dhruvasagar/vim-prosession'
```

3. With [Pathogen](https://github.com/tpope/vim-pathogen)

```
cd ~/.vim/bundle
git clone git://github.com/tpope/vim-obsession.git
git clone git://github.com/dhruvasagar/vim-prosession.git
```

4. With [Lazy](https://github.com/folke/lazy.nvim)

Standalone

```lua
{
  "dhruvasagar/vim-prosession",
  dependencies = {
    "tpope/vim-obsession",
  },
}
```

Or, directly use with telescope as an extension

```lua
{
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "tpope/vim-obsession",
    "dhruvasagar/vim-prosession",
  },
  config = function()
    local telescope = require("telescope")

    telescope.load_extension("prosession")
    vim.keymap.set("n", "<leader>fp", "<cmd>Telescope prosession<cr>", { desc = "Find projects" })
  end
}
```
