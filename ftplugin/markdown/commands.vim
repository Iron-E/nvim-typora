" Open the typora editor

if !exists(':Typora')
	command! -nargs=? -complete=file Typora silent call luaeval('require("typora").open(_A)', <q-args>)
endif

if !exists(':TyporaMode')
	command! TyporaMode lua require('typora').snippet_mode:enter()
endif
