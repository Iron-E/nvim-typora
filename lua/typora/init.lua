--[[
	/*
	 * IMPORTS
	 */
--]]
local vim = vim

--[[
	/*
	 * MODULE
	 */
--]]
local typora = {
	['open'] = function(file)
		if not file or file == '' then file = vim.fn.expand('%') end
		vim.cmd(table.concat({'!typora', file, '&'}, ' '))
	end
}

--[[
	/*
	 * SUBMODULES
	 */
--]]
typora.snippet_mode = require('typora/snippet_mode')

--[[
	/*
	 * PUBLICIZE MODULE
	 */
--]]
return typora
