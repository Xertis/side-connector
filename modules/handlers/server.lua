local protocol = require "multiplayer/protocol-kernel/protocol"
local sandbox = require "lib/private/sandbox/sandbox"
local chat = require "multiplayer/server/chat/chat"
local api_events = require "api/v1/events"
local api_env = require "api/v1/env"
local entities_manager = require "lib/private/entities/entities_manager"

local handlers = {}

handlers[protocol.ClientMsg.ChatMessage] = function(packet, client)
    if not client.player then
        return
    end

    local player = sandbox.get_player(client.player)
    local message = string.format("[%s] %s", player.username, packet.message)
    local state = chat.command(packet.message, client)
    if state == false then
        if not client.account.is_logged then return end

        chat.echo_with_mentions(message)
    end
end

handlers[protocol.ClientMsg.PackEvent] = function(packet, client)
    api_events.__emit__(packet.pack, packet.event, packet.bytes, client)
end

handlers[protocol.ClientMsg.PackEnv] = function(packet, client)
    api_env.__env_update__(packet.pack, packet.env, packet.key, packet.value)
end

handlers[protocol.ClientMsg.EntitySpawnTry] = function(packet, client)
    local name = entities.def_name(packet.entity_def)
    local conf = entities_manager.get_reg_config(name) or {}

    if conf.spawn_handler then
        conf.spawn_handler(name, packet.args, client)
    end
end


return handlers
