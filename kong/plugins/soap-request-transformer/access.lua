local cjson = require("cjson")
local soap = require("kong.plugins.soap-request-transformer.soap")
local kong = kong
local inspect = require("inspect")
local get_raw_body = kong.request.get_raw_body
local set_raw_body = kong.service.request.set_raw_body
local pcall = pcall
local str_find = string.find
local get_header = kong.request.get_header
local set_header = kong.service.request.set_header
local CONTENT_TYPE = "content-type"
local CONTENT_LENGTH = "content-length"
local JSON, MULTI, ENCODED = "json", "multi_part", "form_encoded"
local insert = table.insert
local _M = {}

local function parse_json(body)
    if body then
        local status, res = pcall(cjson.decode, body)
        if status then
            return res
        end
    end
end

local function get_content_type(content_type)
    if content_type == nil then
        return
    end
    if str_find(content_type:lower(), "application/json", nil, true) then
        return JSON
    elseif str_find(content_type:lower(), "multipart/form-data", nil, true) then
        return MULTI
    elseif str_find(content_type:lower(), "application/x-www-form-urlencoded", nil, true) then
        return ENCODED
    end
end


local function parse_entries(e, parent)
    if type(e) == "table" then
        for k, v in pairs(e) do
            local el = { ['tag'] = k }
            insert(parent, el)
            parse_entries(v, el)
        end
    else
        insert(parent, e)
    end
end

local function transform_json_body_into_soap(conf, body, content_length)
    local parameters = parse_json(body)
    local content_length = (body and #body) or 0
    if parameters == nil then
        return false, nil
    end

    local body = parameters.body[conf.method]
    local encode_args = {}
    local root = {}
    parse_entries(body, root)

    encode_args.namespace = conf.namespace
    encode_args.method = conf.method
    encode_args.entries = root

    local soap_doc = soap.encode(encode_args)
    kong.log.debug("Transformed request: "..soap_doc)
    return true, soap_doc
end

local function transform_body(conf)
    local body = get_raw_body()
    local content_length = (body and #body) or 0
    local is_body_transformed = false
    local content_type_value = get_header(CONTENT_TYPE)

    local content_type = get_content_type(content_type_value)

    if content_type == ENCODED then
        --        is_body_transformed, body = transform_url_encoded_body(conf, body, content_length)
    elseif content_type == MULTI then
        --        is_body_transformed, body = transform_multipart_body(conf, body, content_length, content_type_value)
    elseif content_type == JSON then
        is_body_transformed, body = transform_json_body_into_soap(conf, body, content_length)
    end

    if is_body_transformed then
        set_raw_body(body)
        set_header(CONTENT_LENGTH, #body)
        set_header("content-type", "text/xml;charset=UTF-8")
    end
end

function _M.execute(conf)
    transform_body(conf)
end

return _M
