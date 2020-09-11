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
local _ESC = string.char(libmodal.globals.ESC_NR)


----------------------------
--[[ SUMMARY:
	* Get the column that the user's cursor is on.
]]
--[[ RETURNS:
	* The column that the user's cursor is on.
]]
----------------------------
local function _get_cursor_column()
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
	vim.wo.colorcolumn = tostring(_get_cursor_column())
end

------------------------------
--[[ SUMMARY:
	* Move the cursor to the first column.
]]
------------------------------
local function _first_column()
	_move_cursor('0')
end

-----------------------------
--[[ SUMMARY:
	* Move the cursor to the previous column.
]]
-----------------------------
local function _prev_column()
	_move_cursor('F|')
end

-----------------------------
--[[ SUMMARY:
	* Move the cursor to the next column.
]]
-----------------------------
local function _next_column()
	_move_cursor('f|')
end

-----------------------------
--[[ SUMMARY:
	* Move the cursor to the last column.
]]
-----------------------------
local function _last_column()
	_move_cursor('$')
end

------------------------------
--[[ SUMMARY:
	* Resets the cursor to the top of the table, at the original column the user was on.
]]
------------------------------
local function _reset_cursor(previous_column)
	-- Make sure there is a value for the parameter.
	if not previous_column then previous_column = _get_cursor_column() end
	-- Move the cursor back to that column.
	_move_cursor('{j'..(previous_column - 1)..'l')
	-- Make sure the cursor is centered on a column near to the cursor.
	_next_column(); _prev_column()
end

------------------------------
--[[ SUMMARY:
	* Format a table that the user's cursor is on, if the command exists.
]]
------------------------------
local function _format_table(previous_column)
	if vim.fn.exists(_FMT_COMMAND) > 1 then
		vim.cmd(_FMT_COMMAND)
	end
	_reset_cursor(previous_column)
end

----------------------------
--[[ SUMMARY:
	* Convert some `val` into a character code.
	* Only necessary when the `val` is a complex character, like '<C-v>'.
]]
--[[ PARAMS:
	* `val` => the character to convert into a code.
]]
--[[ RETURNS:
	* The converted character code.
]]
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
	local column = _get_cursor_column()
	-- Begin visual block mode, select the whole table, then go up one row and in however many columns the user was.
	_norm(_to_char("<C-v>")..'}k'..column..'l')
end

----------------------------
--[[ SUMMARY:
	* Add a column to the table at the current cursor position.
]]
----------------------------
local function _add_column()
	-- Get the column that the cursor is on, before any actions are performed
	local cursor_column = _get_cursor_column()

	-- Select the column, and insert a new column next to it.
	_select_column()
	_norm('I|'.._ESC..'a '.._input_column_name()..' ')
	_prev_column()
	_norm('ja:---:')

	-- Reformat the table, and center the cursor back on the column.
	_format_table(cursor_column)
end

------------------------------------------
--[[ SUMMARY:
	* Move the column that the user's cursor is currently centered on.
]]
--[[ PARAMS:
	* `movement_func` => A function that moves the user's cursor to the desired column to insert next to.
]]
------------------------------------------
local function _move_column(movement_func)
	-- Get the column that the cursor is on, before any actions are performed
	local cursor_column = _get_cursor_column()

	-- Select the column, and then grab everything up to the next one.
	_select_column()
	_next_column()
	_norm('hx')

	-- Move according to the movement function, and then paste the selection.
	movement_func()
	_norm('P')

	-- Reformat the table, and center the cursor back on the column.
	_format_table(cursor_column)
end

-- The list of commands for the mode.
local _commands = {
	-- First column
	['0'] = _first_column,
	-- Previous column
	['h'] = _prev_column,
	-- Next column
	['l'] = _next_column,
	-- Last column
	['$'] = _last_column,
	-- Insert column behind
	['i'] = _add_column,
	-- Append column ahead
	['a'] = function() _next_column(); _add_column() end,
	-- Insert column at the beginning
	['I'] = function() _first_column(); _add_column() end,
	-- Append column at the end
	['A'] = function() _last_column(); _add_column() end,
	-- Append a row to the bottom.
	['r'] = function()
		local current_line = vim.fn.line('.')
		local current_column = _get_cursor_column()
		local column_names = vim.fn.split(vim.api.nvim_buf_get_lines(0, current_line-1, current_line, true)[1], '|')
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
		_format_table(current_column)
	end,
	-- Sort the rows.
	['s'] = function()
		local cursor_column = _get_cursor_column()
		-- Move down to the rows, select every row, then `:sort` them>
		_norm('2j'.._to_char('<S-v>')..'}k:sort'.._to_char('<CR>'))
		_format_table(cursor_column)
	end,
	-- Undo
	['u'] = function() _norm('u') end,
	-- Move the current column to the left.
	['<'] = function() _move_column(_prev_column) end,
	-- Move the current column to the right.
	['>'] = function() _move_column(_next_column) end,
	-- Move the current column to the beginning.
	['{'] = function() _move_column(_first_column) end,
	-- Move the current column to the end.
	['}'] = function() _move_column(_last_column) end,
}

-- Link certain instructions with already-defined instructions.
_commands['_'] = _commands['0']
_commands['^'] = _commands['0']
_commands['H'] = _commands['0']
_commands['L'] = _commands['$']
_commands[_to_char('<Left>')]    = _commands['h']
_commands[_to_char('<Right>')]   = _commands['l']
_commands[_to_char('<S-Left>')]  = _commands['<']
_commands[_to_char('<S-Right>')] = _commands['>']

--[[
	/*
	 * PUBLICIZE MODULE
	 */
--]]
return function()
	-- Store what the value of colorcolumn was before entering the mode
	local old_colorcolumn = vim.wo.colorcolumn

	-- Put the cursor at the start of the table.
	_reset_cursor()

	-- Enter the mode.
	libmodal.mode.enter('TABLES', _commands)

	-- Restore colorcolumn
	vim.wo.colorcolumn = old_colorcolumn
end
