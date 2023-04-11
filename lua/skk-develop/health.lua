local M = {}

M.check = function()
	-- check plugins
	vim.health.report_start('Checking for required plugins')

	if pcall(require, 'plenary') then
		vim.health.report_ok('plenary: installed')
	else
		vim.health.report_error('plenary: not available', 'Install https://github.com/nvim-lua/plenary.nvim')
	end

	-- check executable
	vim.health.report_start('Checking external dependencies')

	if vim.fn.executable('curl') == 1 then
		vim.health.report_ok('curl: installed')
	else
		vim.health.report_error('curl: not available')
	end

	if vim.fn.executable('tar') == 1 then
		vim.health.report_ok('tar: installed')
	else
		vim.health.report_error('tar: not available')
	end

	if vim.fn.executable('gzip') == 1 then
		vim.health.report_ok('gzip: installed')
	elseif vim.fn.executable('powershell.exe') == 1 then
		vim.health.report_info('gzip: not available')
		vim.health.report_ok('powershell.exe: installed')
	else
		vim.health.report_error('gzip or powershell.exe: not available')
	end
end

return M
