" Guards {{{1
if exists('g:loaded_prosession')
  finish
endif
let g:loaded_prosession = 1

let s:read_from_stdin = 0

if !exists(':Obsession')
  echom 'vim-prosession depends on tpope/vim-obsession, please install/load that first.'
  finish
endif

" Set Global Defaults {{{1
function! s:SetGlobalOptDefault(opt, val)
  if !exists('g:' . a:opt) | let g:{a:opt} = a:val | endif
endfunction

call s:SetGlobalOptDefault('prosession_dir', expand('~/.vim/session/'))
call s:SetGlobalOptDefault('prosession_tmux_title', 0)
call s:SetGlobalOptDefault('prosession_on_startup', 1)
call s:SetGlobalOptDefault('prosession_default_session', 0)
call s:SetGlobalOptDefault('prosession_per_branch', 0)
call s:SetGlobalOptDefault('prosession_branch_cmd', 'git rev-parse --abbrev-ref HEAD 2>/dev/null')
call s:SetGlobalOptDefault('prosession_tmux_title_format', 'vim - @@@')
call s:SetGlobalOptDefault('prosession_last_session_dir', '')

let s:save_last_on_leave = g:prosession_on_startup

if !isdirectory(fnamemodify(g:prosession_dir, ':p'))
  call mkdir(fnamemodify(g:prosession_dir, ':p'), 'p')
endif

function! s:undofile(cwd) "{{{1
  if exists('+shellslash') && !&shellslash
    return substitute(a:cwd, '\', '%', 'g')
  else
    return substitute(a:cwd, '/', '%', 'g')
  endif
endfunction

function! s:StripTrailingSlash(name) "{{{1
  return a:name =~# '[\/]$' ? a:name[:-2] : a:name
endfunction

function! s:GetCWD()
  return exists('*ProjectRootGuess') ? ProjectRootGuess() : getcwd()
endfunction

function! s:IsLastSessionDir()
  return s:GetCWD() ==# expand(g:prosession_last_session_dir)
endfunction

function! s:throw(string) abort
  let v:errmsg = a:string
  throw 'prosession: '.v:errmsg
endfunction

function! s:error(str) abort
  echohl ErrorMsg
  echomsg a:str
  echohl None
endfunction

function! s:GetDirName(...) "{{{1
  let dir = a:0 && a:1 !=# '.' ? a:1 : s:GetCWD()
  let dir = s:StripTrailingSlash(dir)
  if !isdirectory(dir)
    call s:throw('Directory ' . dir . ' does not exist')
  endif
  if g:prosession_per_branch
    let dir .= '_' . prosession#GetCurrBranch(dir)
  endif
  return s:undofile(dir)
endfunction

function! s:GetSessionFileName(...) "{{{1
  let fname = a:0 && a:1 =~# '\.vim$' ? a:1 : call('s:GetDirName', a:000)
  let fname = s:StripTrailingSlash(fname)
  return fname =~# '\.vim$' ? fnamemodify(fname, ':t:r') : fnamemodify(fname, ':t')
endfunction

function! s:GetSessionFile(...) "{{{1
  let sname = ''
  if !a:0 && s:IsLastSessionDir()
    let sname = 'last_session.vim'
  endif
  if empty(sname)
    let sname = call('s:GetSessionFileName', a:000) . '.vim'
  endif
  " return fnamemodify(g:prosession_dir, ':p') . call('s:GetSessionFileName', a:000) . '.vim'
  return fnamemodify(g:prosession_dir, ':p') . sname
endfunction

function! s:SetTmuxWindowName(name) "{{{1
  if g:prosession_tmux_title
    let sfname = s:GetSessionFileName(a:name)
    let sfname = sfname[strridx(sfname,'%')+1:]
    let title = substitute(g:prosession_tmux_title_format, '@@@', sfname, 'g')
    let title = substitute(title, '"', '\\"', 'g')
    call system('tmux rename-window -t ' . $TMUX_PANE . ' "' . title . '"')
    augroup ProsessionTmux
      autocmd!

      autocmd VimLeavePre * call system('tmux set-window-option -t ' . $TMUX_PANE . ' automatic-rename on')
    augroup END
  endif
endfunction

function! s:ProsessionDelete(...) "{{{1
  let name = a:0 >= 1 ? a:1 : ''

  if empty(name)
    let sname = g:prosession_last_session_file
  else
    try
      let sname = s:GetSessionFile(expand(name))
    catch /^prosession/
      call s:error(v:errmsg)
      return
    endtry
  endif

  if exists('#User#ProsessionDeletePre')
    execute 'doautocmd '.(v:version >= 704 || (v:version == 703 && has('patch442')) ? '<nomodeline> ' : '').'User ProsessionDeletePre'
  endif
  if g:prosession_last_session_file == sname && g:this_obsession == sname
    call s:error('Deleting active session')
    " Prevent saving the last session
    let s:save_last_on_leave = 0
    execute 'Obsession!'
  endif

  call system('rm '.sname)

  if exists('#User#ProsessionDeletePost')
    execute 'doautocmd '.(v:version >= 704 || (v:version == 703 && has('patch442')) ? '<nomodeline> ' : '').'User ProsessionDeletePost'
  endif
endfunction

function! s:Prosession(name) "{{{1
  if s:read_from_stdin
    return
  endif
  try
    let sname = s:GetSessionFile(expand(a:name))
  catch /^prosession/
    call s:error(v:errmsg)
    return
  endtry
  if exists('#User#ProsessionPre')
    execute 'doautocmd '.(v:version >= 704 || (v:version == 703 && has('patch442')) ? '<nomodeline> ' : '').'User ProsessionPre'
  endif
  if !empty(get(g:, 'this_obsession', ''))
    silent Obsession " Stop current session
  endif
  " Remove all current buffers.
  silent! %bwipe!
  if filereadable(sname)
    silent execute 'source' fnameescape(sname)
  elseif isdirectory(expand(a:name))
    execute 'cd' expand(a:name)
  else
    if g:prosession_default_session
      let sname = s:GetSessionFile('default')
      silent execute 'source' fnameescape(sname)
    else
      let sname = s:GetSessionFile()
    endif
  endif
  call s:SetTmuxWindowName(a:name)
  if !s:IsLastSessionDir()
    let g:prosession_last_session_file = sname
  endif
  silent execute 'Obsession' fnameescape(sname)
  " Restore last session saving
  let s:save_last_on_leave = g:prosession_on_startup
  if exists('#User#ProsessionPost')
    execute 'doautocmd '.(v:version >= 704 || (v:version == 703 && has('patch442')) ? '<nomodeline> ' : '').'User ProsessionPost'
  endif
endfunction

function! s:save_last_session()
  if s:save_last_on_leave
    exec 'mksession!' g:prosession_dir . 'last_session.vim'
  endif
endfunction

" Start / Load session {{{1
if !argc() && g:prosession_on_startup
  augroup Prosession
    au!

    autocmd StdInReadPost * nested let s:read_from_stdin=1
    autocmd VimEnter * nested call s:Prosession(s:GetSessionFile())
    autocmd VimLeave * call s:save_last_session()
  augroup END
endif

" Command Prosession {{{1
command! -bar -nargs=1 -complete=customlist,prosession#ProsessionComplete Prosession call s:Prosession(<q-args>)
"
" Command Prosession Delete{{{1
command! -bar -nargs=? -complete=customlist,prosession#ProsessionComplete ProsessionDelete call s:ProsessionDelete(<q-args>)
