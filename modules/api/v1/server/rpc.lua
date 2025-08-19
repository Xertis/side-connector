local events = require "api/v1/server/events"
local bson = require "files/bson"
local db = require "files/bit_buffer"

local module = {
    emitter = {},
    handler = {}
}

function module.emitter.create_tell(pack, event)
    return function (client, ...)
        local buffer = db:new()
        bson.encode(buffer, {...})
        events.tell(pack, event, client, buffer.bytes)
    end
end

function module.emitter.create_echo(pack, event)
    return function (...)
        local buffer = db:new()
        bson.encode(buffer, {...})
        events.echo(pack, event, buffer.bytes)
    end
end

return module