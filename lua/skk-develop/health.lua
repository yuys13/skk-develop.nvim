local M = {}

M.check = function()
	-- check executable
	vim.health.start('Checking external dependencies')

	if vim.fn.executable('curl') == 1 then
		vim.health.ok('curl: installed')
	else
		vim.health.error('curl: not available')
	end

	if vim.fn.executable('tar') == 1 then
		vim.health.ok('tar: installed')
	else
		vim.health.error('tar: not available')
	end

	if vim.fn.executable('gzip') == 1 then
		vim.health.ok('gzip: installed')
	elseif vim.fn.executable('powershell.exe') == 1 then
		vim.health.info('gzip: not available')
		vim.health.ok('powershell.exe: installed')
	else
		vim.health.error('gzip or powershell.exe: not available')
	end
end

return M
