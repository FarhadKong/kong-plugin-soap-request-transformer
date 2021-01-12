# Kong SOAP Transformer Plugin

This plugin transformers a JSON request into a SOAP XML request, and then transforms corresponding SOAP XML response
into a JSON response. 

## Supported Kong Releases
Kong >= 1.3.x

## Installation

The .rock file is a self contained package that can be installed locally or from a remote server.

If the luarocks utility is installed in your system (this is likely the case if you used one of the official installation packages), you can install the ‘rock’ in your LuaRocks tree (a directory in which LuaRocks installs Lua modules).

It can be installed by doing:

<code>luarocks install <rock-filename></code>

The filename can be a local name, or any of the supported methods, eg. http://myrepository.lan/rocks/my-plugin-0.1.0-1.all.rock

Next you need to change your Kong configuration [`plugins` configuration option](https://docs.konghq.com/1.3.x/configuration/#plugins) to include this plugin:

```
plugins = bundled,soap-request-transformer
```

Then reload kong:

```
kong reload
```

For further information refer to the following link:
https://docs.konghq.com/enterprise/1.5.x/plugin-development/distribution/

## Configuration

### Enabling on a Service

```bash
$ curl -X POST http://kong:8001/{service id}/plugins \
    --data "name=soap-request-transformer" \
    --data "config.method=RxScriptDetail" \
    --data "config.namespace=DefaultNamespace" \
    --data "config.remove_attr_tags=false" \
    --data "config.soap_prefix=soapenv"
```

### Parameters

Here's a list of all the parameters which can be used in this plugin's configuration:

| Form Parameter | default | description |
|----------------|---------|-------------|
| `name`|| The name of the plugin to use, in this case: `soap-request-transformer`.|
| `service_id`|| The id of the Service which this plugin will target.|
| `route_id` || The id of the Route which this plugin will target.|
| `enabled` | `true` | Whether this plugin will be applied.|
| `config.method` || SOAP Method for the SOAP request, e.g. `RxScriptDetail`|
| `config.namespace` || The SOAP Namespace, e.g. `DefaultNamespace`|
| `config.remove_attr_tags` | `false` | Remove SOAP response XML Attributes|
| `config.soap_prefix` | `soap` | Set the soap prefix for picky parsers|


