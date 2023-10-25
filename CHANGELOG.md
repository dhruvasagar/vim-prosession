# Change Log

## 0.7.3

- Add telescope picker for integration with telescope

## 0.6.3

Switch to `delete()` instead of `system('rm '.sname)`

## 0.6.2

- Add `g:Prosession_ignore_expr` to allow more control over directories to be
  ignored by prosession

## 0.6.1

- Switch `g:prosession_ignore_dirs` to be an array of paths instead of
  a string delimited by a comma

## 0.6.0

- Add `g:prosession_ignore_dirs` to configure a list of comma separated
  directories to be ignored by prosession

## 0.5.6

- Add `g:prosession_last_session_dir` to load last session from that path when
  launching vim

## 0.5.5

- Added check for `g:prosession_dir` to create it if not already present.
- Fix default session loading flow, instead of doing a recursive call
  just source the default session file, rest will work

## 0.5.4

- Added `g:prosession_branch_cmd` to allow working with other vcs, but set to
  use git by default.
- Added a check to ensure `g:prosession_branch_cmd` ignores errors, if any.

## 0.5.3

- Moved optional git functions to an autoload file.

## 0.5.2

- Added support for per git branch sessions

## Version 0.5.1

- Added function for stripping trailing slash for directory names

## Version 0.5.0

- Switched to undofile style naming for the session file

## Version 0.4.1

- Disabled `g:prosession_default_session` by default

## Version 0.4.0:

- Added `g:prosession_default_session` option to allow using of a default
  session instead of always creating a new one for a new directory.

## Version 0.3.0

- Merged pull request #2. Handling case if using vim with stdin.

## Version 0.2.2

- Updated augroup definition for loading session during vim startup

## Version 0.2.1

- Fixed guard condition for existing vim session while switching to another

## Version 0.2

- Switchined to using VimEnter autocmd for loading autocmd to do it more
  gracefully, otherwise there were side effects like skipping of -c commands.
- Changed variable name `g:prosession_load_on_startup` to
  `g:prosession_on_startup`.
- Added a guard condition within s:Prosession to ensure we stop a session only
  if it's already started to avoid side effects.

## Version 0.1.3

- Updated `g:prosession_dir` default to `~/.vim/session/` in favor of
  common vim convention.

## Version 0.1.2

- Fixed #1

## Version 0.1.1

- Added `g:prosession_load_on_startup` to configure whether
  to load session on startup if vim is launch without any
  arguments.

## Version 0.1

- First working version
