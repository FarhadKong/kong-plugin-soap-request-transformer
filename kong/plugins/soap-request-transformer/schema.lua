local typedefs = require "kong.db.schema.typedefs"

return {
    name = "soap-request-tranformer",
    fields = {
        {
            consumer = typedefs.no_consumer
        },
        {
            config = {
                type = "record",
                fields = {
                    {
                        method = {
                            type = "string",
                            required = true,
                        },
                    },
                    {
                        namespace = {
                            type = "string",
                            required = true,
                        },
                    },
                    {
                        remove_attr_tags = {
                            type = "boolean",
                            required = false,
                        },
                    },
                    {
                        soap_version = {
                            type = "string",
                            default = "1.1",
                            one_of = {
                                "1.1",
                                "1.2"
                            },
                        },
                    },
                    {
                        soap_prefix = {
                            type = "string",
                            default = "soap",
                        },
                    },
                },
            },
        },
    }
}