package = "kong-plugin-soap-request-transformer"
version = "0.1.0-0"
source = {
   url = "git://github.com/kong/kong-plugin-soap-request-transformer",
   tag = "0.1.0"
}
description = {
   summary = "This plugin sends request and response logs to Kafka.",
   homepage = "https://github.com/kong/kong-plugin-soap-request-transformer",
}
build = {
   type = "builtin",
   modules = {
      ["kong.plugins.soap-request-transformer.handler"] = "kong/plugins/soap-request-transformer/handler.lua",
      ["kong.plugins.soap-request-transformer.schema"] = "kong/plugins/soap-request-transformer/schema.lua",
      ["kong.plugins.soap-request-transformer.access"] = "kong/plugins/soap-request-transformer/access.lua",
      ["kong.plugins.soap-request-transformer.xml.soap"] = "kong/plugins/soap-request-transformer/xml/soap.lua",
      ["kong.plugins.soap-request-transformer.xml.xml2lua"] = "kong/plugins/soap-request-transformer/xml/xml2lua.lua",
      ["kong.plugins.soap-request-transformer.xml.XmlParser"] = "kong/plugins/soap-request-transformer/xml/XmlParser.lua",
      ["kong.plugins.soap-request-transformer.xml.tree"] = "kong/plugins/soap-request-transformer/xml/tree.lua",
   }
}
