# Change Log

## Version 0.4.0:
* Added `g:prosession_default_session` option to allow using of a default
  session instead of always creating a new one for a new directory.

## Version 0.3.0
* Merged pull request #2. Handling case if using vim with stdin.

## Version 0.2.2
* Updated augroup definition for loading session during vim startup

## Version 0.2.1
* Fixed guard condition for existing vim session while switching to another

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
