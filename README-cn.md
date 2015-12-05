Name
====

nginx-multi-disk - 让nginx支持多目录(多磁盘)及高速缓存目录，目录选择算法采用一致性Hash。

Synopsis
========

```lua
# nginx.conf

http {
    lua_package_path '/path/to/nginx-multi-disk/?.lua;;';

    init_worker_by_lua '
        local multidir = require("resty.multidir")
        multidir.init({["/data/disk01"]=2, ["/data/disk02"]=1}, "/data/cache")
    ';

    server {
        ...
        # 获取文件存储目录，写文件到磁盘时使用
        location = /getsavedir {
            set_by_lua $root_dir '
                if ngx.var.arg_url == nil or ngx.var.arg_url == "" then
                    return ""
                end
                local multidir = require "resty.multidir"
                local url = ngx.var.arg_url or ""
                local root_dir, x_cache = multidir.get_path_by_uri(url)
                ngx.header["X-Cache"] = x_cache
                ngx.log(ngx.INFO, "set root_dir:", root_dir)
                return root_dir                
            ';
            root $root_dir;

            content_by_lua '                
                local url = ngx.var.arg_url or ""
                ngx.say(ngx.var.document_root .. url)
            ';
        }

        # 下载文件
        location / {
            set_by_lua $root_dir '
                local multidir = require "resty.multidir"
                local root_dir, x_cache = multidir.get_path_by_uri(ngx.var.uri)
                ngx.header["X-Cache"] = x_cache
                ngx.log(ngx.INFO, "set root_dir:", root_dir)
                return root_dir                
            ';
            root $root_dir;
        }
    }
}

```

Description
===========
标准nginx默认不支持多目录(多磁盘)，需要使用磁盘raid或其它方式来支持。本库就是让nginx支持多目录及缓存目录支持。多目录选择使用一致性Hash。支持权重设置。本模块需要ngx_lua支持。

Methods
=======

加载模块

1. 要使用该库，首先要设置ngx_lua的环境变量：

```lua
lua_package_path '/path/to/nginx-multi-disk/?.lua;;';
```

2. 需要使用require加载该模块到一个本地变量：

```lua
local multidir = require("resty.multidir")
```


init
---
* `syntax: multidir.init(multi_dir_table, cachedir)`

初始化多目录模块

* `multi_dir_table` 
指定存储目录及目录权重。也可以只给出目录，不写权重。
    * 指定权重初始化 `multidir.init({["dir01"]=weight, ["dir02"]=weight})`
    * 不指定权重(既权重都为1)初始化 `multidir.init({"dir01""dir02"})`
* `cachedir`
指定高速缓存目录，可为空。指定该目录后，会查询缓存中是否包含请求的文件，如果包含会返回缓存目录，并从缓存目录中读取文件。

Prerequisites
=============

* [LuaJIT](http://luajit.org) 2.0+
* [ngx_lua](https://github.com/chaoslawful/lua-nginx-module) 0.8.10+

Authors
=======

* liuxiaojie (刘小杰)  <jie123108@163.com>

[Back to TOC](#table-of-contents)

Copyright & License
===================

This module is licenced under the BSD license.

Copyright (C) 2014, by liuxiaojie (刘小杰)  <jie123108@163.com>

All rights reserved.
