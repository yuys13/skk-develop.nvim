# skk-develop.nvim

skk-develop.nvim provides skk-get for neovim

## Requirements

- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- curl, tar, gzip(or powershell.exe)

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'yuys13/skk-develop.nvim',
  dependencies = {
    { 'nvim-lua/plenary.nvim' },
  },
},
```

## Usage

```lua
local skk_get = require('skk-develop').skk_get
skk_get('/path/to/destination/directory')
```

## Details

```lua
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
```
