if exists('g:loaded_prosession') "{{{1
  finish
endif
let g:loaded_prosession = 1

if !exists(':Obsession') "{{{1
  echo "vim-prosession depends on tpope/vim-obsession, kindly install that for this to work"
  finish
endif

function! s:SetGlobalOptDefault(opt, val) "{{{1
  if !exists('g:' . a:opt) | let g:{a:opt} = a:val | endif
endfunction

" Set Global Defaults {{{1
call s:SetGlobalOptDefault('prosession_dir', expand('~/.vim/sessions/'))
call s:SetGlobalOptDefault('prosession_tmux_title', 0)
call s:SetGlobalOptDefault('prosession_load_on_startup', 1)

function! s:GetCurrDir() "{{{1
  return fnamemodify(getcwd(), ':t')
endfunction

function! s:GetSessionFileName(...) "{{{1
  let fname = a:0 ? a:1 : s:GetCurrDir()
  if fname =~# '/$' | let fname = fname[:-2] | endif
  return fnamemodify(fname, ':t:r')
endfunction

function! s:GetSessionFile(...) "{{{1
  return fnamemodify(g:prosession_dir, ':p') . call('s:GetSessionFileName', a:000) . '.vim'
endfunction

" Start / Load session {{{1
if !argc() && g:prosession_load_on_startup
  if filereadable(s:GetSessionFile())
    silent execute 'source' s:GetSessionFile()
    if g:prosession_tmux_title
      call system('tmux rename-window "vim - ' . s:GetSessionFileName() . '"')
    endif
  endif
  silent execute 'Obsession' s:GetSessionFile()
endif

function! s:Prosession(name) "{{{1
  silent Obsession
  silent noautocmd bufdo bw
  let sname = s:GetSessionFile(expand(a:name))
  if filereadable(sname)
    silent execute 'source' sname
  elseif isdirectory(expand(a:name))
    execute 'cd' expand(a:name)
  else
    let sname = s:GetSessionFile()
  endif
  if g:prosession_tmux_title
    call system('tmux rename-window "vim - ' . s:GetSessionFileName(a:name) . '"')
  endif
  silent execute 'Obsession' sname
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
  return flist
endfunction

" Command Prosession {{{1
command! -bar -nargs=1 -complete=customlist,s:ProsessionComplete Prosession call s:Prosession(<q-args>)
