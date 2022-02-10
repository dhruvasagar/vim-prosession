function! prosession#ExecInDir(dir, cmd) "{{{1
  let pipe = has('win64') || has('win32') ? ' & ' : '; '
  return system('cd ' . fnameescape(a:dir) . pipe . a:cmd)
endfunction

function! prosession#GetCurrBranch(dir) "{{{1
  let branch = prosession#ExecInDir(a:dir, g:prosession_branch_cmd)
  if branch =~# "\n$" | let branch = branch[:-2] | endif
  return branch
endfunction

function! prosession#ListSessions(...) "{{{1
  let ArgLead = a:0 >= 1 ? a:1 : ''
  let fldr = fnamemodify(expand(ArgLead), ':h')
  if !empty(ArgLead) && fldr != '.' && isdirectory(fldr)
    let flist = glob(ArgLead . '*', 0, 1)
  else
    let flead = empty(ArgLead) ? '' : '*' . ArgLead
    let flist = glob(fnamemodify(g:prosession_dir, ':p') . flead . '*.vim', 0, 1)
    let flist = map(flist, "fnamemodify(v:val, ':t:r')")
  endif
  let flist = map(flist, "substitute(v:val, '%', '/', 'g')")
  return flist
endfunction

function! prosession#Clean() "{{{1
  let files = glob(fnamemodify(g:prosession_dir, ':p') . '*.vim', 0, 1)
  for file in files
    let dir = substitute(fnamemodify(file, ':t:r'), '%', '/', 'g')
    if !isdirectory(dir) | call delete(file) | endif
  endfor
endfunction

function! prosession#ProsessionComplete(ArgLead, Cmdline, Cursor) "{{{1
  return prosession#ListSessions(a:ArgLead)
endfunction
