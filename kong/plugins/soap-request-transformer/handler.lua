local access = require("kong.plugins.soap-request-transformer.access")
local kong = kong
local get_raw_body = kong.request.get_raw_body
local set_raw_body = kong.service.request.set_raw_body
local get_header = kong.request.get_header
local set_header = kong.service.request.set_header
local handler = require("xmlhandler.tree")
local xml2lua = require("xml2lua")
local concat = table.concat
local cjson = require("cjson")

local CONTENT_TYPE = "content-type"
local CONTENT_LENGTH = "content-length"

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



function SoapTransformerHandler.convertXMLtoJSON(xml, conf)
    local xmlHandler = handler:new()
    local parser = xml2lua.parser( xmlHandler )
    parser:parse(xml)
    local SOAPPrefix = "SOAP-ENV"
    if string.match(xml,"soapenv:Envelope") then
        SOAPPrefix = "soapenv"
    end

    local t = xmlHandler.root[SOAPPrefix .. ":Envelope"][SOAPPrefix .. ":Body"]
    if conf.remove_attr_tags then
        remove_attr_tags(t)
    end

    return cjson.encode(t)
end

function SoapTransformerHandler:access(conf)
    local body = get_raw_body()
    -- local content_length = (body and #body) or 0
    local is_body_transformed, body = access.transform_body(conf, body,get_header(CONTENT_TYPE))

    if is_body_transformed then
        set_raw_body(body)
        set_header(CONTENT_LENGTH, #body)
        set_header(CONTENT_TYPE, "text/xml;charset=UTF-8")
    end

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

    if not resp_body or resp_body == '' then
        return nil
    end

    kong.log.debug("Response body XML: "..resp_body)
    ngx.arg[1] = self.convertXMLtoJSON(resp_body, conf)
    kong.log.debug("Response body JSON: "..ngx.arg[1])
end


return SoapTransformerHandler