" Mappings for this plugin.
if !hasmapto('<leader>t')
	nmap <leader>t <Cmd>call typora#snippet_mode()<CR>
endif

if !hasmapto('<leader>T')
	nmap <leader>t <Cmd>call typora#table_mode()<CR>
endif
