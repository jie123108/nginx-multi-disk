Name
====

nginx-multi-disk - ��nginx֧�ֶ�Ŀ¼(�����)�����ٻ���Ŀ¼��Ŀ¼ѡ���㷨����һ����Hash��

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
        # ��ȡ�ļ��洢Ŀ¼��д�ļ�������ʱʹ��
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

        # �����ļ�
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
��׼nginxĬ�ϲ�֧�ֶ�Ŀ¼(�����)����Ҫʹ�ô���raid��������ʽ��֧�֡����������nginx֧�ֶ�Ŀ¼������Ŀ¼֧�֡���Ŀ¼ѡ��ʹ��һ����Hash��֧��Ȩ�����á���ģ����Ҫngx_lua֧�֡�

Methods
=======

����ģ��

1. Ҫʹ�øÿ⣬����Ҫ����ngx_lua�Ļ���������

```lua
lua_package_path '/path/to/nginx-multi-disk/?.lua;;';
```

2. ��Ҫʹ��require���ظ�ģ�鵽һ�����ر�����

```lua
local multidir = require("resty.multidir")
```


init
---
* `syntax: multidir.init(multi_dir_table, cachedir)`

��ʼ����Ŀ¼ģ��

* `multi_dir_table` 
ָ���洢Ŀ¼��Ŀ¼Ȩ�ء�Ҳ����ֻ����Ŀ¼����дȨ�ء�
    * ָ��Ȩ�س�ʼ�� `multidir.init({["dir01"]=weight, ["dir02"]=weight})`
    * ��ָ��Ȩ��(��Ȩ�ض�Ϊ1)��ʼ�� `multidir.init({"dir01""dir02"})`
* `cachedir`
ָ�����ٻ���Ŀ¼����Ϊ�ա�ָ����Ŀ¼�󣬻��ѯ�������Ƿ����������ļ�����������᷵�ػ���Ŀ¼�����ӻ���Ŀ¼�ж�ȡ�ļ���

Prerequisites
=============

* [LuaJIT](http://luajit.org) 2.0+
* [ngx_lua](https://github.com/chaoslawful/lua-nginx-module) 0.8.10+

Authors
=======

* liuxiaojie (��С��)  <jie123108@163.com>

[Back to TOC](#table-of-contents)

Copyright & License
===================

This module is licenced under the BSD license.

Copyright (C) 2014, by liuxiaojie (��С��)  <jie123108@163.com>

All rights reserved.
