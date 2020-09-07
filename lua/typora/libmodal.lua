--[[
	/*
	 * IMPORTS
	 */
--]]
local vim = vim
local libmodal = require('libmodal')

--[[
	/*
	 * MODULE
	 */
--]]

---------------------------
--[[ SUMMARY:
	* Paste `lines` of text.
]]
--[[ PARAMS:
	* `lines` => the lines of text.
]]
---------------------------
local function _paste(text)
	vim.fn.append(vim.fn.line('.'), text)

	local CURRENT_WINDOW = 0
	local current_position = vim.api.nvim_win_get_cursor(CURRENT_WINDOW)
	vim.api.nvim_win_set_cursor(CURRENT_WINDOW, {current_position[1]+2, current_position[2]})
end

-----------------------------------------------------
--[[ SUMMARY:
	* Create a table given a certain number of user input columns.
]]
--[[ PARAMS:
	* `language` => the language of the code block.
	* `title` => the title of the code block.
	* `template` => example code for the code block.
]]
-----------------------------------------------------
local function _paste_code(language, title, template)
	if not language then
		language = vim.fn.input("\nWhich language?\n> ")
	end

	-- This is the delimiter for a markdown codeblock.
	local delimiter = "```"

	local to_paste = {delimiter..language, "", delimiter}

	if title or template then
		to_paste[4] = to_paste[3]
		to_paste[2] = title or ""
		to_paste[3] = template or ""
	end

	_paste(to_paste)

end

-----------------------------------------------
--[[ SUMMARY:
	* Create a mermaid diagram.
]]
--[[ PARAMS:
	* `syntax` => what kind of mermaid diagram this is.
	* `template` => a reminder of how to format this kind of diagram.
]]
-----------------------------------------------
local function _paste_mermaid(syntax, template)
	_paste_code('mermaid', syntax, '\t'..template)
end


----------------------------
--[[ SUMMARY:
	* Create a table given a certain number of user input columns.
]]
-----------------------------
local function _paste_table()
	-- Get the number of columns.
	local columns = vim.fn.input('\nHow many columns?\n> ')

	-- Create the text for the table.
	local table_text = {'|', '|'}
	for _ = 1, columns do
		table_text[1] = (table_text[1] or '')..' Placeholder |'
		table_text[2] = (table_text[2] or '')..':--:|'
	end

	-- Paste the table.
	_paste(table_text)

	-- Format the just-pasted table.
	-- This might have to be adjusted to =2
	if vim.fn.exists(':TableFormat') > 1 then
		vim.cmd('TableFormat')
	end
end

--[[
	/*
	 * PUBLICIZE MODULE
	 */
--]]
local action_tree = {
	['classDiagram']    = function() _paste_mermaid('classDiagram', 'Animal <|-- Duck') end,
	['code']            = _paste_code,
	['erDiagram']       = function() _paste_mermaid('erDiagram', 'FOO o|--|{ BAR : example') end,
	['graph']           = function() _paste_mermaid('graph LR', 'A --> B') end,
	['sequenceDiagram'] = function() _paste_mermaid('sequenceDiagram', 'Alice->>John: Example text') end,
	['table']           = _paste_table
}

return libmodal.Prompt.new(
	'Typora',
	function()
		local input = vim.g.typoraModeInput

		if action_tree[input] then action_tree[input]()
		else libmodal.utils.show_error('Invalid selection')
		end
	end,
	{
		'classDiagram',
		'code',
		'erDiagram',
		'graph',
		'sequenceDiagram',
		'table',
	}
)
