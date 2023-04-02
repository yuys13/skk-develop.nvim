local M = {}

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

---@param dir string Download destination directory
---@param dicts string[] List of SKK dictionaries to download
local function skk_clear_target_dir(dir, dicts)
	for _, file in ipairs(dicts) do
		local fullpath = dir .. '/' .. file
		os.remove(fullpath)
		os.remove(fullpath:gsub('%.gz$', ''))
		os.remove(fullpath:gsub('%.tar.gz$', ''))

		if file == 'SKK-JISYO.edict.tar.gz' then
			os.remove(dir .. '/edict_doc.html')
		end

		if file == 'zipcode.tar.gz' then
			os.remove(dir .. '/SKK-JISYO.zipcode')
			os.remove(dir .. '/SKK-JISYO.office.zipcode')
		end
	end
end

---@param dir string Download destination directory
---@param dicts string[] List of SKK dictionaries to download
local function skk_create_target_dir(dir, dicts)
	if vim.fn.isdirectory(dir) == 0 then
		vim.fn.mkdir(dir, 'p')
	else
		skk_clear_target_dir(dir, dicts)
	end
end

---@param dir string Download destination directory
---@param dicts string[] List of SKK dictionaries to download
local function skk_get_dictionary(dir, dicts)
	local curl = require('plenary.curl')
	local done = 0
	local errors = {}
	for _, file in ipairs(dicts) do
		curl.get('https://skk-dev.github.io/dict/' .. file, {
			output = dir .. '/' .. file,
			callback = function(out)
				done = done + 1
				if out.status ~= 200 then
					table.insert(errors, out)
				end
			end,
		})
	end

	vim.wait(3 * 1000 * 60, function()
		return done == #skk_get_files
	end)

	if 0 < #errors then
		return errors
	end

	return nil
end

---@param target string
---@return Job
local function skk_gzip_d(target)
	local Job = require('plenary.job')
	local job = Job:new {
		command = 'gzip',
		args = { '-d', target },
	}
	return job
end

---@return string
local function get_degzip_path()
	local script_path = debug.getinfo(2, 'S').source:sub(2)
	local plugin_dir = script_path:match('(.*/).*/')
	return plugin_dir .. 'powershell/degzip.ps1'
end

---@param target string
---@return Job
local function skk_degzip_ps1(target)
	local degzip = get_degzip_path()
	local Job = require('plenary.job')
	local job = Job:new {
		command = 'powershell.exe',
		args = { '-executionpolicy', 'remotesigned', '-file', degzip, target },
	}
	return job
end

local function skk_extract(dir, dicts)
	local Job = require('plenary.job')
	---@type Job[]
	local jobs = {}

	for _, file in ipairs(dicts) do
		if string.sub(file, -7) == '.tar.gz' then
			local j = Job:new {
				command = 'tar',
				args = { 'zxf', file },
				cwd = dir,
			}
			table.insert(jobs, j)
			j:start()
		elseif string.sub(file, -3) == '.gz' then
			local ungzip = nil
			if vim.fn.executable('gzip') == 0 and vim.fn.executable('powershell.exe') == 1 then
				ungzip = skk_degzip_ps1
			else
				ungzip = skk_gzip_d
			end
			local j = ungzip(dir .. '/' .. file)
			table.insert(jobs, j)
			j:start()
		end
	end

	local errors = {}
	for _, job in ipairs(jobs) do
		job:wait()
		if job.code ~= 0 then
			table.insert(errors, job)
		end
	end

	if #errors ~= 0 then
		return errors
	end

	if vim.fn.isdirectory(dir .. '/zipcode') == 1 then
		os.rename(dir .. '/zipcode/' .. 'SKK-JISYO.zipcode', dir .. '/SKK-JISYO.zipcode')
		os.rename(dir .. '/zipcode/' .. 'SKK-JISYO.office.zipcode', dir .. '/SKK-JISYO.office.zipcode')
		vim.fn.delete(dir .. '/zipcode', 'rf')
	end

	return nil
end

--- `skk_get`はhttps://skk-dev.github.io/dict/からSKK辞書をダウンロードします。
--- ダウンロード先は`dir`で指定可能です。
--- 省略した場合はstdpath('data') .. '/skk-get-jisyo'です。
--- stdpath('data')の場所は`:echo stdpath('data')`で確認できます。
--- ダウンロードする辞書は`dicts`で指定可能です。
--- 省略した場合はDDSKKに倣って以下の辞書をダウンロードします。
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
---@param dir string|nil Download destination directory(default: stdpath('data') .. '/skk-get-jisyo')
---@param dicts string[]|nil List of SKK dictionaries to download(default: same as ddskk)
---@return boolean ok
local function skk_get(dir, dicts)
	dir = dir or vim.fn.stdpath('data') .. '/skk-get-jisyo'
	dicts = dicts or skk_get_files
	skk_create_target_dir(dir, dicts)
	local errors
	errors = skk_get_dictionary(dir, dicts)
	if errors then
		vim.pretty_print(errors)
		vim.cmd([[echoerr 'failed to download JISYO']])
		return false
	end
	errors = skk_extract(dir, dicts)
	if errors then
		vim.pretty_print(errors)
		vim.cmd([[echoerr 'failed to extract JISYO']])
		return false
	end

	return true
end

M.skk_get = skk_get

return M
