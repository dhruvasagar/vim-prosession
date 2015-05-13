function! prosession#ExecInDir(dir, cmd) "{{{1
  return system('cd ' . fnameescape(a:dir) . '; ' . a:cmd)
endfunction

function! prosession#GetCurrBranch(dir) "{{{1
  let branch = prosession#ExecInDir(a:dir, g:prosession_branch_cmd)
  if branch =~# "\n$" | let branch = branch[:-2] | endif
  return branch
endfunction

function! prosession#ProsessionComplete(ArgLead, Cmdline, Cursor) "{{{1
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
