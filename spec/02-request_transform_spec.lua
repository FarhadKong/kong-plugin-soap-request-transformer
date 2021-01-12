local helpers = require "spec.helpers"

local PLUGIN_NAME = "soap-request-transformer"

local kong = kong
local request_transformer = require "kong.plugins.soap-request-transformer.access"


  describe(PLUGIN_NAME, function()

    describe("request", function()
      it("converts valid soapy-json", function()

        local config = {}
        config.method = "RxScriptDetail"
        config.namespace = "DefaultNamespace"
        config.remove_attr_tags = false
        config.soap_prefix = "soapenv"
        config.soap_version = "1.2"

        local json = [[{
        "body" : {
            "RxScriptDetail" : {
                "rxScriptDetailReq" : {
                    "rxscdiDos": "2019-08-19",
                    "rxscdiLocn": 5073,
                    "rxscdiRxNbr": 427,
                    "rxscdiUsrid": "PRGJC1"
                }
            }
        }
        }]]

        local _,txbody = request_transformer.transform_body(config, json, "application/json")
        print("Request body XML: "..txbody)




      end)
    end)
  end)