return
{
	['open'] = function(file)
		if not file or file == '' then
			file = vim.fn.expand '%'
		end

		os.execute('typora '..file..' &')
	end,
	['snippet_mode'] = require 'typora/snippet_mode',
	['table_mode'] = require 'typora/table_mode'
}
