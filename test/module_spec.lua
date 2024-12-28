local skk_develop = require('skk-develop')

describe('module', function()
	it('has skk_get', function()
		assert.is_function(skk_develop.skk_get)
	end)
end)

describe('skk_get', function()
	local tempdir = vim.fn.tempname()

	after_each(function()
		for _, file in ipairs(vim.fn.glob(tempdir .. '/*', nil, true)) do
			os.remove(file)
		end
		vim.fn.delete(tempdir, 'd')
	end)

	it('get default dics', function()
		local expected = {
			'SKK-JISYO.JIS2',
			'SKK-JISYO.geo',
			'SKK-JISYO.JIS2004',
			'SKK-JISYO.JIS3_4',
			'SKK-JISYO.L',
			'SKK-JISYO.assoc',
			'SKK-JISYO.edict',
			'SKK-JISYO.edict.tar.gz',
			'SKK-JISYO.fullname',
			'SKK-JISYO.itaiji',
			'SKK-JISYO.jinmei',
			'SKK-JISYO.law',
			'SKK-JISYO.lisp',
			'SKK-JISYO.mazegaki',
			'SKK-JISYO.office.zipcode',
			'SKK-JISYO.okinawa',
			'SKK-JISYO.propernoun',
			'SKK-JISYO.pubdic+',
			'SKK-JISYO.station',
			'SKK-JISYO.zipcode',
			'edict_doc.html',
			'zipcode.tar.gz',
		}
		skk_develop.skk_get(tempdir)
		local actual = {}
		for _, file in ipairs(vim.fn.glob(tempdir .. '/*', nil, true)) do
			table.insert(actual, vim.fn.fnamemodify(file, ':t'))
		end
		table.sort(expected)
		table.sort(actual)
		assert.are_same(expected, actual)
	end)
end)
