local PLUGIN_NAME = "soap-request-transformer"


-- helper function to validate data against a schema
local validate do
  local validate_entity = require("spec.helpers").validate_plugin_config_schema
  local plugin_schema = require("kong.plugins."..PLUGIN_NAME..".schema")

  function validate(data)
    return validate_entity(data, plugin_schema)
  end
end


describe(PLUGIN_NAME .. ": (schema)", function()


  it("accepts method, namespace, remove_attr_tags", function()
    local ok, err = validate({
        method = "mySoapMethod",
        namespace = "mysoapnamespace",
        remove_attr_tags = true,
        soap_version = "1.1",
        soap_prefix = "soapenv"
      })
    assert.is_nil(err)
    assert.is_truthy(ok)
  end)


end)
