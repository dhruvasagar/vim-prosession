# VIM ProSession v0.1.3

A VIM plugin to handle sessions like a pro.

It leverages vim-obsession and allows switching between multiple sessions
cleanly, the idea is to maintain one session per project (directory) and
switch between them when we need to switch context, automatically loading
along with it the various files, settings etc ensuring compete isolation
between projects. Now there's little need to launch multiple vim instances for
separate sessions (projects), you can simply switch between them with ease.

ProSession provides command `:Prosession` which completes session file names
from the sessions directory configured by `g:prosession_dir` (default
~/.vim/sessions) or completes directory names to start new sessions for. For
more details check `:help procession`.

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

2. With [Vundle](https://github.com/gmarik/Vundle.vim')
```vim
Plugin 'tpope/vim-obsession'
Plugin 'dhruvasagar/vim-prosession'
```

3. With [Pathogen](https://github.com/tpope/vim-pathogen')
```
cd ~/.vim/bundle
git clone git://github.com/tpope/vim-obsession.git
git clone git://github.com/dhruvasagar/vim-prosession.git
```
