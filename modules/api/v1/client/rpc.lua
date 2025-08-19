local events = require "api/v1/client/events"
local bson = require "files/bson"
local db = require "files/bit_buffer"

local module = {
    emitter = {},
    handler = {}
}

function module.emitter.create_send(pack, event)
    return function (...)
        local buffer = db:new()
        bson.encode(buffer, {...})

        events.send(pack, event, buffer.bytes)
    end
end

return module