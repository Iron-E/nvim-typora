--[[
	/*
	 * IMPORTS
	 */
--]]
local vim = vim
local api = vim.api
local libmodal = require('libmodal')

--[[
	/*
	 * MODULE
	 */
--]]
local _FMT_COMMAND = ':TableFormat'


------------------------------
--[[ SUMMARY:
	* Format a table that the user's cursor is on, if the command exists.
]]
------------------------------
local function _format_table()
	if vim.fn.exists(_FMT_COMMAND) > 1 then
		vim.cmd(_FMT_COMMAND)
	end
end

----------------------------
--[[ SUMMARY:
	* Get the column that the user's cursor is on.
]]
--[[ RETURNS:
	* The column that the user's cursor is on.
]]
----------------------------
local function _get_column()
	return vim.fn.col('.')
end

-----------------------------------
--[[ SUMMARY:
	* Prompt the user for the name of a column that they wish to insert.
]]
--[[ RETURNS:
	* The name a new column that the user wishes to create.
]]
-----------------------------------
local function _input_column_name()
	return vim.fn.input('What is the name for this new column?\n> ')
end

----------------------------
--[[ SUMMARY:
	* Execute some `inputs` using `:norm!`.
]]
--[[ PARAMS:
	* `inputs` => the characters to emulate inputting using `:norm!`
]]
----------------------------
local function _norm(inputs)
	vim.cmd('norm! '..inputs)
end

-----------------------------------
--[[ SUMMARY:
	* Move the user's cursor to some other column using a `motion`.
	* Sets the 'colorcolumn' value depending on where the cursor ends up.
]]
--[[ PARAMS:
	* `motion` => the motion used to move the cursor, e.g. 'w' or 'l'.
]]
-----------------------------------
local function _move_cursor(motion)
	_norm(motion)
	vim.wo.colorcolumn = tostring(_get_column())
end

----------------------------
----------------------------
local function _to_char(val)
	return api.nvim_eval('"\\'..val..'"')
end

-------------------------------
--[[ SUMMARY:
	* Select the entirety of the column that the user's cursor is on.
]]
-------------------------------
local function _select_column()
	-- Get the column that the user was on, and subtract one (because we don't need that many motions to return there)
	local column = _get_column() - 1
	-- Begin visual block mode, select the whole table, then go up one row and in however many columns the user was.
	_norm(_to_char("<C-v>")..'}k'..column..'l')
end

----------------------------
--[[ SUMMARY:
	* Add a column to the table at the current cursor position.
]]
--[[ PARAMS:
	* `should_append` => Whether or not to append the new column
		* `true` => `A`ppend the new column.
		* `false` => `I`nsert the new column.
]]
----------------------------
local function _add_column(should_append)
	_select_column()
	_norm((should_append and 'A' or 'I')..'|')
	_norm('a '.._input_column_name()..' ')
	_norm('F|ja:---:')
	_format_table()
end

-- The list of commands for the mode.
local _instruction = {
	-- First column
	['0'] = function() _move_cursor('0') end,
	-- Previous column
	['h'] = function() _move_cursor('F|') end,
	-- Next column
	['l'] = function() _move_cursor('f|') end,
	-- Last column
	['$'] = function() _move_cursor('$') end,
	-- Insert column behind
	['i'] = function() _add_column(false) end,
	-- Append column ahead
	['a'] = function() _add_column(true) end,
	-- Insert column at the beginning
	['I'] = function()
		_move_cursor('0')
		_add_column(false)
	end,
	-- Append column at the end
	['A'] = function()
		_move_cursor('$')
		_add_column(true)
	end,
	-- Append a row to the bottom.
	['r'] = function()
		local current_line = vim.fn.line('.')
		local column_names = vim.fn.split(
			vim.api.nvim_buf_get_lines(0, current_line-1, current_line, true)[1], '|'
		)
		current_line = nil

		-- Start a new column.
		_norm('jo| ')
		-- Append to each column the value that is inputted.
		for _, column_name in ipairs(column_names) do _norm(
				'a'
				..vim.fn.input('What is the value for '..vim.trim(column_name)..'?\n> ')
				..' |'
		) end

		-- Format the table.
		_format_table()
	end,
	-- Sort the rows.
	['s'] = function()
		-- Move down to the rows, then select every row.
		_norm('2j'.._to_char('<S-v>')..'}k')
		-- Sort the rows.
		vim.cmd('sort')
	end,
	-- Move the current column to the left.
	['<'] = function() end,
	-- Move the current column to the right.
	['>'] = function() end,
}

-- Link certain instructions with already-defined instructions.
_instruction['_'] = _instruction['0']
_instruction['^'] = _instruction['0']
_instruction['H'] = _instruction['0']
_instruction['L'] = _instruction['$']
_instruction[_to_char('<Left>')]    = _instruction['h']
_instruction[_to_char('<Right>')]   = _instruction['l']
_instruction[_to_char('<S-Left>')]  = _instruction['<']
_instruction[_to_char('<S-Right>')] = _instruction['>']

--[[
	/*
	 * PUBLICIZE MODULE
	 */
--]]
return function()
	-- Store what the value of colorcolumn was before entering the mode
	local old_colorcolumn = vim.wo.colorcolumn

	-- Go to one row above the top of the table, and then back down a row.
	_move_cursor('{j')

	-- Enter the mode
	libmodal.mode.enter('TABLES', _instruction)

	-- Restore colorcolumn
	vim.wo.colorcolumn = old_colorcolumn
end
