local cjson = require("cjson")
local soap = require("kong.plugins.soap-request-transformer.soap")
local kong = kong
local pcall = pcall
local JSON = "application/json"
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

local function transform_json_body_into_soap(conf, body)
    local parameters = parse_json(body)
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
    encode_args.soap_prefix = conf.soap_prefix
    encode_args.soap_version = conf.soap_version
    local soap_doc = soap.encode(encode_args)
    kong.log.debug("Transformed request: "..soap_doc)
    return true, soap_doc
end

function _M.transform_body(conf, body, content_type)
    local is_body_transformed = false

    if content_type == JSON then
        is_body_transformed, body = transform_json_body_into_soap(conf, body)
    end

    return is_body_transformed, body
end

return _M
