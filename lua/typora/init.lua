--[[
	/*
	 * MODULE
	 */
--]]
local typora = {
	['open'] = function(file)
		vim.cmd(table.concat({'!typora', file or '%', '&'}, ' '))
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
