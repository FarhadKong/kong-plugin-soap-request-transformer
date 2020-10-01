local access = require("kong.plugins.soap-request-transformer.access")
local handler = require("kong.plugins.soap-request-transformer.xml.tree")
local xml2lua = require("kong.plugins.soap-request-transformer.xml.xml2lua")
local concat = table.concat
local cjson = require("cjson")
local kong = kong

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

    -- if bad gateway status recieved return
    if kong.response.get_status() == 502 then
        return nil
    end

    -- last piece of body is ready
    local resp_body = concat(ctx.rt_body_chunks)

    if not resp_body then
        return
    end

    local parser = xml2lua.parser(handler)
    parser:parse(resp_body)
    local SOAPPrefix = "SOAP-ENV"
    if string.match(resp_body,"soapenv:Envelope") then
        SOAPPrefix = "soapenv"
    end

    local t = handler.root[SOAPPrefix .. ":Envelope"][SOAPPrefix .. ":Body"]
    if conf.remove_attr_tags then
        remove_attr_tags(t)
    end

    ngx.arg[1] = cjson.encode(t)

end


return SoapTransformerHandler