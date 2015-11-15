--[[
author: jie123108@163.com
date: 20150901
]]

local chash = require "resty.chash"

local root_dir = chash:new()

local _M = {}
_M.root_dirs = nil

function _M.init(root_dirs, cache_dir)
    _M.root_dirs = root_dirs
    _M.cache_dir = cache_dir
    if type(_M.root_dirs) == 'table' then
        for k, v in pairs(_M.root_dirs) do
            local dir = nil
            local weight = 1
            if type(k) == 'number' then
                dir = v 
            else 
                dir = k 
                weight = v
            end
            ngx.log(ngx.INFO, "######## dir:", dir, " weight:", weight)
            root_dir:add(dir, weight)
        end
    else
        ngx.log(ngx.ERR, "root_dirs must be a 'table'")
        return false
    end
    return true
end

-- 获取文件存储路径。(不包含.dl,.mt后缀)
function _M.get_path(url)
    local root = nil
    if type(_M.root_dirs) == 'table' and root_dir:count() > 0 then
        root = root_dir:get(url) 
    else
        root = "html"
    end
    
    return root
end

-- 获取所有存储路径
function _M.get_paths()
    return root_dir:items()
end

function _M.cache_file_exist(filename)
    -- TODO: 缓存结果，避免每次都进行access调用。

    local function lua_exist(filename)
        local file = io.open(filename, "rb")
        if file then file:close() end
        return file ~= nil
    end
    local exist = lua_exist(filename)
    ngx.log(ngx.INFO, "Test Exist(", filename, "): ", exist)
    return exist
end

function _M.get_path_by_uri(uri)
    local root_dir, x_cache = nil
    if _M.cache_dir and type(_M.cache_dir) == 'string' then
        local filename = _M.cache_dir .. uri
        if _M.cache_file_exist(filename) then
            root_dir = _M.cache_dir
            x_cache = "hit"
        end
    end

    if root_dir == nil then
        root_dir = _M.get_path(uri)
        x_cache = "mis"
    end
    return root_dir, x_cache
end

--[[Usage:

local multidir = require "resty.multidir"
local root_dir, x_cache = multidir.get_path_by_uri(ngx.var.uri)
ngx.header["X-Cache"] = x_cache
ngx.log(ngx.INFO, "set root_dir:", root_dir)
return root_dir

]]

return _M