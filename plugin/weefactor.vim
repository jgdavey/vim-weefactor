" weefactor.vim - Micro Ruby refactorings
" Author:      Joshua Davey <http://joshuadavey.com/>
" Version:     1.0

if exists('g:loaded_weefactor') && g:loaded_weefactor
  finish
endif
let g:loaded_weefactor = 1

function! s:extract_to_rspec_let()
  let pos = getpos('.')
  let l = getline('.')
  if empty(matchstr(l, " = ")) == 1
    echo "Can't find an assignment"
    return
  endif
  let aline = search('^\s*\<\(describe\|context\)\>', 'bWn')

  if aline
    let letline = substitute(l, '\v([a-z_][a-zA-Z0-9_]*) +\= +(.+)', 'let(:\1) { \2 }', '')
    normal! 0
    normal! "_dd
    call append(aline, split(letline, "\n"))
    exec 'normal '.aline.'Gj'
    normal V=
  endif

  let pos[1] = pos[1] + 1
  call setpos('.', pos)
  echo ''
endfunction

function! s:convert_struct_to_class()
  let pos = getpos('.')
  let l = getline('.')
  let matches = matchlist(l, '\v(class|)\s*<([A-Z]\w*)>\s*[\=\<]\s*Struct\.new[ \(]\s*(%(:\h\w*%(,\s*)?)+)\)?\s*(do)?')
  if empty(matches) == 1
    echo "Can't find struct"
    return
  endif
  let classname = matches[2]
  let vars = join(split(matches[3], '\s*,\s*'), ', ')
  let ivars = substitute(vars, ":", "@", "g")
  let lvars = substitute(vars, ":", "", "g")
  let oneline = 0
  if empty(matches[1]) && empty(matches[4])
    let oneline = 1
  endif

  let newline = "class " . classname . "\n  attr_reader " . vars . "\n  "
  let newline = newline . "def initialize(" . lvars . ")\n    "
  let newline = newline . ivars . " = " . lvars . "\n  end\n"
  if oneline
    let newline = newline . "end"
  else
    let newline = newline . "\n"
  endif

  if append(pos[1], split(newline, "\n")) == 0
    normal! "_dd
    normal! ^
    normal =%
    exec "normal \<Esc>"
  endif

  call setpos('.', pos)
endfunction

command! ConvertStructToClass call <SID>convert_struct_to_class()
command! ExtractRspecLet call <SID>extract_to_rspec_let()

nnoremap <silent> <Plug>ConvertStructToClass :call <SID>convert_struct_to_class()<CR>
nnoremap <silent> <Plug>ExtractRspecLet :call <SID>extract_to_rspec_let()<CR>

" vim:set ft=vim ff=unix ts=4 sw=2 sts=2:
