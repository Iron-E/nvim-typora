" Open the typora editor

if !exists(':Typora')
	command! -nargs=? -complete=file Typora silent call typora#open(<q-args>)
endif

if !exists(':TyporaMode')
	command! TyporaMode call typora#snippet_mode()
endif
