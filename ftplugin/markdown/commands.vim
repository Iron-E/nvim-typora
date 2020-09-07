" Open the typora editor
command! -nargs=? -complete=file Typora silent execute '!typora '.<q-args>.' &'
command! TyporaMode lua require('typora/libmodal'):enter()
