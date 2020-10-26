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
                },
            },
        },
    }
}