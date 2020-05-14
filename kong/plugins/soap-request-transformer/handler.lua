local access = require("kong.plugins.soap-request-transformer.access")
local handler = require("kong.plugins.soap-request-transformer.tree")
local xml2lua = require("kong.plugins.soap-request-transformer.xml2lua")
local concat = table.concat
local cjson = require("cjson")
local kong = kong
local inspect = require "inspect"

local SoapTransformerHandler = {
    VERSION = "0.0.1",
    PRIORITY = 801,
}

local function remove_attr_tags(e)
    if type(e) == "table" then
        for k, v in pairs(e) do
            if k == '_attr' then
                e[k] = nil
            end
            remove_attr_tags(v)
        end
    end
end

function SoapTransformerHandler:access(conf)
    access.execute(conf)
end

function SoapTransformerHandler:header_filter(conf)
    kong.response.clear_header("Content-Length")
    kong.response.set_header("Content-Type", "application/json")
end

function SoapTransformerHandler:body_filter(conf)
    local ctx = ngx.ctx
    local chunk, eof = ngx.arg[1], ngx.arg[2]

    ctx.rt_body_chunks = ctx.rt_body_chunks or {}
    ctx.rt_body_chunk_number = ctx.rt_body_chunk_number or 1

    -- if eof wasn't received keep buffering
    if not eof then
        ctx.rt_body_chunks[ctx.rt_body_chunk_number] = chunk
        ctx.rt_body_chunk_number = ctx.rt_body_chunk_number + 1
        ngx.arg[1] = nil
        return
    end

    -- last piece of body is ready; do the thing
    local resp_body = concat(ctx.rt_body_chunks)

    print("=====resp_body=======",resp_body)
    --handler:new()
    print("=====handler======",inspect(handler))
    local parser = xml2lua.parser(handler)
    parser:parse(resp_body)
    local t = handler.root["SOAP-ENV:Envelope"]["SOAP-ENV:Body"]
    if conf.remove_attr_tags then
        remove_attr_tags(t)
    end

    --print("=====response======", cjson.encode(t))

    ngx.arg[1] = cjson.encode(t)

end


return SoapTransformerHandler