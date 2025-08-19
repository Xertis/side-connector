local protocol = require "multiplayer/protocol-kernel/protocol"
local server_echo = start_require("multiplayer/server/server_echo")

local module = {}
local handlers = {}

function module.tell(pack, event, client, bytes)
    client:push_packet(protocol.ServerMsg.PackEvent, pack, event, bytes)
end

function module.echo(pack, event, bytes)
    server_echo.put_event(function(client)
        client:push_packet(protocol.ServerMsg.PackEvent, pack, event, bytes)
    end)
end

function module.on(pack, event, func)
    local pack_handlers = table.set_default(handlers, pack, {})
    local pack_handler_events = table.set_default(pack_handlers, event, {})

    table.insert(pack_handler_events, func)
end

function module.__emit__(pack, event, bytes, client)
    table.set_default(handlers, pack, {})
    table.set_default(handlers[pack], event, {})

    for _, func in ipairs(handlers[pack][event]) do
        func(client, bytes)
    end
end

return module
