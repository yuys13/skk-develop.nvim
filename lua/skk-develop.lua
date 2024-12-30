local M = {}

local path = {}

path.separator = vim.fn.expand('/')

function path.join(...)
	return table.concat({ ... }, path.separator)
end

--- @type string[]
local skk_get_files = {
	'SKK-JISYO.JIS2.gz',
	'SKK-JISYO.JIS2004.gz',
	'SKK-JISYO.JIS3_4.gz',
	'SKK-JISYO.L.gz',
	'SKK-JISYO.assoc.gz',
	'SKK-JISYO.edict.tar.gz',
	'SKK-JISYO.fullname.gz',
	'SKK-JISYO.geo.gz',
	'SKK-JISYO.itaiji.gz',
	'SKK-JISYO.jinmei.gz',
	'SKK-JISYO.law.gz',
	'SKK-JISYO.lisp.gz',
	'SKK-JISYO.mazegaki.gz',
	'SKK-JISYO.okinawa.gz',
	'SKK-JISYO.propernoun.gz',
	'SKK-JISYO.pubdic+.gz',
	'SKK-JISYO.station.gz',
	'zipcode.tar.gz',
}

---@param dir string The destination directory for downloads
---@param dicts string[] The list of SKK dictionaries to download
local function skk_clear_target_dir(dir, dicts)
	for _, file in ipairs(dicts) do
		local fullpath = path.join(dir, file)
		os.remove(fullpath)
		os.remove(fullpath:gsub('%.gz$', ''))
		os.remove(fullpath:gsub('%.tar.gz$', ''))

		if file == 'SKK-JISYO.edict.tar.gz' then
			os.remove(path.join(dir, 'edict_doc.html'))
		end

		if file == 'zipcode.tar.gz' then
			os.remove(path.join(dir, 'SKK-JISYO.zipcode'))
			os.remove(path.join(dir, 'SKK-JISYO.office.zipcode'))
		end
	end
end

---@param dir string The destination directory for downloads
---@param dicts string[] The list of SKK dictionaries to download
local function skk_create_target_dir(dir, dicts)
	if vim.fn.isdirectory(dir) == 0 then
		vim.fn.mkdir(dir, 'p')
	else
		skk_clear_target_dir(dir, dicts)
	end
end

---@param dir string The destination directory for downloads
---@param dicts string[] The list of SKK dictionaries to download
---@return vim.SystemCompleted[]|nil errors
local function skk_get_dictionary(dir, dicts)
	---@type vim.SystemObj[]
	local jobs = {}
	for _, file in ipairs(dicts) do
		local job = vim.system({ 'curl', '-fsSLO', 'https://skk-dev.github.io/dict/' .. file }, {
			cwd = dir,
			text = true,
		})
		table.insert(jobs, job)
	end

	---@type vim.SystemCompleted[]
	local errors = {}
	for _, job in ipairs(jobs) do
		local comp = job:wait()
		if comp.code ~= 0 then
			table.insert(errors, comp)
		end
	end

	if #errors ~= 0 then
		return errors
	end

	return nil
end

---@param target string
---@return vim.SystemObj
local function skk_gzip_d(target)
	local job = vim.system { 'gzip', '-d', target }
	return job
end

---@return string
local function get_degzip_path()
	local script_path = debug.getinfo(1, 'S').source:sub(2)
	local plugin_dir = vim.fn.fnamemodify(script_path, ':p:h:h')
	return path.join(plugin_dir, 'powershell', 'degzip.ps1')
end

---@param dir string The destination directory for downloads
---@param dicts string[] The list of SKK dictionaries to download
---@return vim.SystemCompleted[]|nil errors
local function skk_extract(dir, dicts)
	---@type vim.SystemObj[]
	local jobs = {}

	for _, file in ipairs(dicts) do
		if string.sub(file, -7) == '.tar.gz' then
			local job = vim.system({ 'tar', 'zxf', file }, { text = true, cwd = dir })
			table.insert(jobs, job)
		elseif string.sub(file, -3) == '.gz' then
			if vim.fn.executable('gzip') == 0 and vim.fn.executable('powershell.exe') == 1 then
				local job = vim.system({
					'powershell.exe',
					'-noprofile',
					'-executionpolicy',
					'remotesigned',
					'-file',
					get_degzip_path(),
					path.join(dir, file),
				}, { text = true })
				table.insert(jobs, job)
			else
				local job = skk_gzip_d(path.join(dir, file))
				table.insert(jobs, job)
			end
		end
	end

	---@type vim.SystemCompleted[]
	local errors = {}
	for _, job in ipairs(jobs) do
		local comp = job:wait()
		if comp.code ~= 0 then
			table.insert(errors, comp)
		end
	end

	if #errors ~= 0 then
		return errors
	end

	if vim.fn.isdirectory(path.join(dir, 'zipcode')) == 1 then
		os.rename(path.join(dir, 'zipcode', 'SKK-JISYO.zipcode'), path.join(dir, 'SKK-JISYO.zipcode'))
		os.rename(path.join(dir, 'zipcode', 'SKK-JISYO.office.zipcode'), path.join(dir, 'SKK-JISYO.office.zipcode'))
		vim.fn.delete(path.join(dir, 'zipcode'), 'rf')
	end

	return nil
end

--
--- `skk_get` downloads SKK dictionaries from https://skk-dev.github.io/dict/.
--- The destination directory can be specified with the `dir` parameter. If omitted,
--- it defaults to stdpath('data') .. '/skk-get-jisyo'. The location of stdpath('data')
--- can be confirmed with :echo stdpath('data').
--- The dictionaries to download can be specified with the `dicts` parameter. If
--- omitted, the following dictionaries will be downloaded, following DDSKK:
--- - 'SKK-JISYO.JIS2.gz',
--- - 'SKK-JISYO.JIS2004.gz',
--- - 'SKK-JISYO.JIS3_4.gz',
--- - 'SKK-JISYO.L.gz',
--- - 'SKK-JISYO.assoc.gz',
--- - 'SKK-JISYO.edict.tar.gz',
--- - 'SKK-JISYO.fullname.gz',
--- - 'SKK-JISYO.geo.gz',
--- - 'SKK-JISYO.itaiji.gz',
--- - 'SKK-JISYO.jinmei.gz',
--- - 'SKK-JISYO.law.gz',
--- - 'SKK-JISYO.lisp.gz',
--- - 'SKK-JISYO.mazegaki.gz',
--- - 'SKK-JISYO.okinawa.gz',
--- - 'SKK-JISYO.propernoun.gz',
--- - 'SKK-JISYO.pubdic+.gz',
--- - 'SKK-JISYO.station.gz',
--- - 'zipcode.tar.gz',
---@param dir string|nil The destination directory for downloads (default is stdpath('data') .. '/skk-get-jisyo').
---@param dicts string[]|nil The list of SKK dictionaries to download (default is the same as DDSKK).
---@return boolean ok
local function skk_get(dir, dicts)
	dir = dir or path.join(vim.fn.stdpath('data'), 'skk-get-jisyo')
	dicts = dicts or skk_get_files
	skk_create_target_dir(dir, dicts)
	local errors
	errors = skk_get_dictionary(dir, dicts)
	if errors then
		vim.print(errors)
		vim.cmd([[echoerr 'failed to download JISYO']])
		return false
	end
	errors = skk_extract(dir, dicts)
	if errors then
		vim.print(errors)
		vim.cmd([[echoerr 'failed to extract JISYO']])
		return false
	end

	return true
end

M.skk_get = skk_get

return M
