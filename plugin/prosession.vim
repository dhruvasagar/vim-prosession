" Guards {{{1
if exists('g:loaded_prosession')
  finish
endif
let g:loaded_prosession = 1

let s:read_from_stdin = 0

if !exists(':Obsession')
  echo "vim-prosession depends on tpope/vim-obsession, kindly install that first."
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

if !isdirectory(fnamemodify(g:prosession_dir, ':p'))
  call mkdir(fnamemodify(g:prosession_dir, ':p'), 'p')
endif

function! s:undofile(cwd) "{{{1
  return substitute(a:cwd, '/', '%', 'g')
endfunction

function! s:StripTrailingSlash(name) "{{{1
  return a:name =~# '/$' ? a:name[:-2] : a:name
endfunction

function! s:GetDirName(...) "{{{1
  let cwd = a:0 ? a:1 : getcwd()
  let cwd = s:StripTrailingSlash(cwd)
  if g:prosession_per_branch
    let cwd .= '_' . prosession#GetCurrBranch(cwd)
  endif
  return s:undofile(cwd)
endfunction

function! s:GetSessionFileName(...) "{{{1
  if a:0 && a:1 =~# '\.vim$'
    let l:fname = a:1
    return fnamemodify(l:fname, ':t:r')
  endif
  let l:fname =  call('s:GetDirName', a:000)
  return s:StripTrailingSlash(l:fname)
endfunction

function! s:GetSessionFile(...) "{{{1
  return fnamemodify(g:prosession_dir, ':p') . call('s:GetSessionFileName', a:000) . '.vim'
endfunction

function! s:SetTmuxWindowName(name) "{{{1
  if g:prosession_tmux_title
    let sfname = fnamemodify(s:GetSessionFileName(a:name), ':r')
    let sfname = sfname[strridx(sfname,'%')+1:]
    call system('tmux rename-window "vim - ' . sfname . '"')
    augroup ProsessionTmux
      autocmd!

      autocmd VimLeavePre * call system('tmux set-window-option -t ' . $TMUX_PANE . ' automatic-rename on')
    augroup END
  endif
endfunction

function! s:Prosession(name) "{{{1
  if s:read_from_stdin
    return
  endif
  if !empty(get(g:, 'this_obsession', ''))
    silent Obsession " Stop current session
  endif
  silent! noautocmd bufdo bw
  let sname = s:GetSessionFile(expand(a:name))
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
  silent execute 'Obsession' fnameescape(sname)
endfunction

function! s:ProsessionComplete(ArgLead, Cmdline, Cursor) "{{{1
  let fldr = fnamemodify(expand(a:ArgLead), ':h')
  if !empty(a:ArgLead) && fldr != '.' && isdirectory(fldr)
    let flist = glob(a:ArgLead . '*', 0, 1)
  else
    let flead = empty(a:ArgLead) ? '' : '*' . a:ArgLead
    let flist = glob(fnamemodify(g:prosession_dir, ':p') . flead . '*.vim', 0, 1)
    let flist = map(flist, "fnamemodify(v:val, ':t:r')")
  endif
  let flist = map(flist, "substitute(v:val, '%', '/', 'g')")
  return flist
endfunction

" Start / Load session {{{1
if !argc() && g:prosession_on_startup
  augroup Prosession
    au!

    autocmd StdInReadPost * nested let s:read_from_stdin=1
    autocmd VimEnter * nested call s:Prosession(s:GetSessionFile())
  augroup END
endif

" Command Prosession {{{1
command! -bar -nargs=1 -complete=customlist,s:ProsessionComplete Prosession call s:Prosession(<q-args>)
