# Change Log

## Version 0.2
* Switchined to using VimEnter autocmd for loading autocmd to do it more
  gracefully, otherwise there were side effects like skipping of -c commands.
* Changed variable name `g:prosession_load_on_startup` to
  `g:prosession_on_startup`.
* Added a guard condition within s:Prosession to ensure we stop a session only
  if it's already started to avoid side effects.

## Version 0.1.3
* Updated `g:prosession_dir` default to `~/.vim/session/` in favor of
  common vim convention.

## Version 0.1.2
* Fixed #1

## Version 0.1.1
* Added `g:prosession_load_on_startup` to configure whether
  to load session on startup if vim is launch without any
  arguments.

## Version 0.1
* First working version
