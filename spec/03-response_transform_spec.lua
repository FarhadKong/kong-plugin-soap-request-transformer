local helpers = require "spec.helpers"

local cjson = require("cjson")
local pcall = pcall

local PLUGIN_NAME = "soap-request-transformer"

local kong = kong
local request_transformer = require "kong.plugins.soap-request-transformer.access"
local response_transformer = require "kong.plugins.soap-request-transformer.handler"


  describe(PLUGIN_NAME, function()

    describe("response", function()
      it("converts soap xml response back to json", function()

        local config = {}
        config.method = "RxScriptDetail"
        config.namespace = "DefaultNamespace"
        config.remove_attr_tags = false
        config.soap_prefix = "soapenv"
        config.soap_version = "1.2"

        local responseXML = [[<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"><SOAP-ENV:Header/><SOAP-ENV:Body><ns2:getCountryResponse xmlns:ns2="http://spring.io/guides/gs-producing-web-service"><ns2:country><ns2:name>United Kingdom</ns2:name><ns2:population>63705000</ns2:population><ns2:capital>London</ns2:capital><ns2:currency>GBP</ns2:currency></ns2:country></ns2:getCountryResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>]]

        -- local _,txbody = request_transformer.transform_body(config, json, "application/json")

        local json = response_transformer.convertXMLtoJSON(responseXML, config)
        print("Response json: "..json)
        local status, res = pcall(cjson.decode, json)

        assert.equal("London", res["ns2:getCountryResponse"]["ns2:country"]["ns2:capital"])


      end)
    end)
  end)