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
dependencies = {
   "xml2lua = 1.4-3",
   "luasoap = 4.0.2-1",
}
build = {
   type = "builtin",
   modules = {
      ["kong.plugins.soap-request-transformer.handler"] = "kong/plugins/soap-request-transformer/handler.lua",
      ["kong.plugins.soap-request-transformer.schema"] = "kong/plugins/soap-request-transformer/schema.lua",
      ["kong.plugins.soap-request-transformer.access"] = "kong/plugins/soap-request-transformer/access.lua",
   }
}
