" SUMMARY: Open a file with Typora.
" ARGS: The name of the file to open, or the current file by default.
function! typora#open(...) abort
	call luaeval('require("typora").open(_A)', get(a:000, 0, v:null))
endfunction

" SUMMARY: Enter `snippet_mode` for Typora.
function! typora#snippet_mode() abort
	lua require('typora').snippet_mode:enter()
endfunction
