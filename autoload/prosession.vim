function! prosession#ExecInDir(dir, cmd) "{{{1
  return system('cd ' . fnameescape(a:dir) . '; ' . a:cmd)
endfunction

function! prosession#GitCurrBranch(dir) "{{{1
  let branch = prosession#ExecInDir(a:dir, 'git rev-parse --abbrev-ref HEAD')
  if branch =~# "\n$" | let branch = branch[:-2] | endif
  echom branch
  return branch
endfunction
