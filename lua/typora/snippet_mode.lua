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
	-- Add a space to the bottom of the snippet.
	if type(text) == 'string' then text = {text} end
	text[#text+1] = ''

	vim.fn.append(vim.fn.line('.'), text)

	local CURRENT_WINDOW = 0
	local current_position = vim.api.nvim_win_get_cursor(CURRENT_WINDOW)
	vim.api.nvim_win_set_cursor(CURRENT_WINDOW, {current_position[1]+(#text or 1), current_position[2]})
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
--[[ RETURNS:
	* A function which can be called to create a mermaid template.
]]
-----------------------------------------------
local function _paste_mermaid(syntax, template)
	return function() _paste_code('mermaid', syntax, '\t'..template) end
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
	['classDiagram']    = _paste_mermaid('classDiagram', 'Animal <|-- Duck'),
	['code']            = _paste_code,
	['erDiagram']       = _paste_mermaid('erDiagram', 'FOO o|--|{ BAR : example'),
	['graph']           = _paste_mermaid('graph LR', 'A --> B'),
	['sequenceDiagram'] = _paste_mermaid('sequenceDiagram', 'Alice->>John: Example text'),
	['table']           = _paste_table
}

return libmodal.Prompt.new(
	'TYPORA', -- The name of the prompt
	function() -- The function for the prompt.
		local input = vim.g.typoraModeInput

		if action_tree[input] then action_tree[input]()
		else libmodal.utils.show_error('Invalid selection')
		end
	end,
	-- The autocompletion for the prompt.
	vim.fn.sort(vim.tbl_keys(action_tree))
)
