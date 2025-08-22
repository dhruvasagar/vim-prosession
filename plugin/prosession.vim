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

let s:default_branch_cmd = 'git rev-parse --abbrev-ref HEAD 2>/dev/null'

if has('win64') || has('win32')
  let s:default_branch_cmd = 'git rev-parse --abbrev-ref HEAD 2>nul'
endif

call s:SetGlobalOptDefault('prosession_dir', expand('~/.vim/session/'))
call s:SetGlobalOptDefault('prosession_tmux_title', 0)
call s:SetGlobalOptDefault('prosession_on_startup', 1)
call s:SetGlobalOptDefault('prosession_default_session', 0)
call s:SetGlobalOptDefault('prosession_per_branch', 0)
call s:SetGlobalOptDefault('prosession_branch_cmd', s:default_branch_cmd)
call s:SetGlobalOptDefault('prosession_tmux_title_format', 'vim - @@@')
call s:SetGlobalOptDefault('prosession_last_session_dir', '')
call s:SetGlobalOptDefault('prosession_ignore_dirs', [])
call s:SetGlobalOptDefault('Prosession_ignore_expr', {->v:false})
call s:SetGlobalOptDefault('prosession_viminfo_per_session', v:false)

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
  let dir = s:StripTrailingSlash(fnamemodify(dir, ':p'))
  if !isdirectory(dir)
    call s:throw('Directory ' . dir . ' does not exist')
  endif
  if g:prosession_per_branch
    let dir .= '_' . prosession#GetCurrBranch(dir)
  endif
  return s:undofile(dir)
endfunction

function! s:GetSessionFileName(...) "{{{1
  let fname = a:0 && a:1 =~# '\.vim$' && !isdirectory(a:1) ? a:1 : call('s:GetDirName', a:000)
  let fname = s:StripTrailingSlash(fname)
  return fname =~# '\.vim$' ? fnamemodify(fname, ':t:r') : fnamemodify(fname, ':t')
endfunction

function! s:GetSessionFile(...) "{{{1
  let sname = call('s:GetSessionFileName', a:000) . '.vim'
  return fnamemodify(g:prosession_dir, ':p') . sname
endfunction

function! s:GetVimInfoFile(...) "{{{1
  let sname = call('s:GetSessionFileName', a:000) . '.viminfo'
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
  if exists("g:prosession_last_session_file") && g:prosession_last_session_file == sname && g:this_obsession == sname
    call s:error('Deleting active session')
    " Prevent saving the last session
    let s:save_last_on_leave = 0
    execute 'Obsession!'
  endif

  call delete(sname)

  if exists('#User#ProsessionDeletePost')
    execute 'doautocmd '.(v:version >= 704 || (v:version == 703 && has('patch442')) ? '<nomodeline> ' : '').'User ProsessionDeletePost'
  endif
endfunction

function! s:ProsessionIgnoreCWD() "{{{1
  if empty(g:prosession_ignore_dirs) | return v:false | end
  let cdir = s:GetCWD()
  for idir in g:prosession_ignore_dirs
    let idir = expand(idir)
    if isdirectory(idir) && cdir == idir
      return v:true
    endif
  endfor
  return v:false
endfunction

function! s:Prosession(...) "{{{1
  if s:read_from_stdin
        \ || s:ProsessionIgnoreCWD() == v:true
        \ || g:Prosession_ignore_expr() == v:true
    return
  endif
  let aname = a:0 && !empty(a:1) ? a:1 : s:GetCWD()
  try
    let sname = s:GetSessionFile(expand(aname))
  catch /^prosession/
    call s:error(v:errmsg)
    return
  endtry
  if exists('#User#ProsessionPre')
    execute 'doautocmd '.(v:version >= 704 || (v:version == 703 && has('patch442')) ? '<nomodeline> ' : '').'User ProsessionPre'
  endif
  if !empty(get(g:, 'this_obsession', ''))
    silent Obsession " Stop current session
    " Remove all current buffers.
    silent! %bwipe!
  endif
  if filereadable(sname)
    silent execute 'source' fnameescape(sname)
  elseif isdirectory(expand(aname))
    execute 'cd' expand(aname)
  else
    if g:prosession_default_session
      let sname = s:GetSessionFile('default')
      silent execute 'source' fnameescape(sname)
    else
      let sname = s:GetSessionFile()
    endif
  endif
  call s:SetTmuxWindowName(aname)
  if !s:IsLastSessionDir()
    let g:prosession_last_session_file = sname
  endif
  silent execute 'Obsession' fnameescape(sname)
  if g:prosession_viminfo_per_session
    exec 'set viminfofile=' . s:GetVimInfoFile()
  endif
  " Restore last session saving
  let s:save_last_on_leave = g:prosession_on_startup
  if exists('#User#ProsessionPost')
    execute 'doautocmd '.(v:version >= 704 || (v:version == 703 && has('patch442')) ? '<nomodeline> ' : '').'User ProsessionPost'
  endif
endfunction

function! s:GetLastSessionFile()
  try
    return g:prosession_dir . trim(readfile(s:LastSession())[0])
  catch
    return ""
  endtry
endfunction

function! s:LastSession()
  return expand(g:prosession_dir . "last_session.txt")
endfunction

function! s:save_last_session()
  if s:save_last_on_leave && exists("g:this_obsession")
    call writefile([fnamemodify(g:this_obsession, ":t")], s:LastSession())
  endif
endfunction

" Start / Load session {{{1
if !argc() && index(get(v:, 'argv', []), '-q') == -1 && g:prosession_on_startup
  augroup Prosession
    au!

    autocmd StdInReadPost * nested let s:read_from_stdin=1
    autocmd VimEnter * nested call s:AutoStart()
    autocmd VimLeave * call s:save_last_session()
  augroup END
endif

function! s:AutoStart()
  let sname = ""
  if s:IsLastSessionDir()
    let sname = s:GetLastSessionFile()
  endif
  if empty(sname)
    let sname = s:GetSessionFile()
  endif
  call s:Prosession(sname)
endfunction

function! s:AutoSwitch()
  if g:prosession_per_branch && exists('*FugitiveResult')
    let fresult = FugitiveResult()
    if !empty(fresult)
          \ && has_key(fresult, 'args')
          \ && !empty(fresult['args'])
          \ && (fresult['args'][0] ==? 'checkout' || fresult['args'][0] ==? 'switch')
          \ && len(fresult['args']) > 1
      call s:AutoStart()
    endif
  endif
endfunction

augroup ProsessionGit
  au!

  autocmd User FugitiveChanged call s:AutoSwitch()
augroup END

" Command Prosession {{{1
command! -bar -nargs=? -complete=customlist,prosession#ProsessionComplete Prosession call s:Prosession(<q-args>)
"
" Command Prosession Delete{{{1
command! -bar -nargs=? -complete=customlist,prosession#ProsessionComplete ProsessionDelete call s:ProsessionDelete(<q-args>)

command! ProsessionClean call prosession#Clean()
