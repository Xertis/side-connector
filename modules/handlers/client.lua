local protocol = require "multiplayer/protocol-kernel/protocol"
local Player = require "multiplayer/classes/player"

local api_events = require "api/v1/events"
local api_entities = require "api/v1/entities"
local api_env = require "api/v1/env"
local api_particles = require "api/v1/particles"
local api_audio = require "api/v1/audio"
local api_text3d = require "api/v1/text3d"
local api_wraps = require "api/v1/wraps"

local handlers = {}

handlers[protocol.ServerMsg.ChatMessage] = function (packet, server)
    console.chat("| "..packet.message)
end

handlers[protocol.ServerMsg.SynchronizePlayerPosition] = function (packet, server)
    local player_data = packet.data

    CLIENT_PLAYER:set_pos(player_data.pos, false)
    CLIENT_PLAYER:set_rot(player_data.rot, false)
    CLIENT_PLAYER:set_cheats(player_data.cheats, false)

    CACHED_DATA.pos = player_data.pos
    CACHED_DATA.rot = player_data.rot
    CACHED_DATA.cheats = player_data.cheats
end

handlers[ protocol.ServerMsg.PackEvent ] = function (packet, server)
    api_events.__emit__(packet.pack, packet.event, packet.bytes)
end

handlers[ protocol.ServerMsg.PackEnv ] = function (packet, server)
    api_env.__env_update__(packet.pack, packet.env, packet.key, packet.value)
end

handlers[ protocol.ServerMsg.WeatherChanged ] = function (packet, server)
    local name = packet.name
    if name == '' then
        name = nil
    end

    gfx.weather.change(
        packet.weather,
        packet.time,
        name
    )
end

handlers[ protocol.ServerMsg.PlayerFieldsUpdate ] = function (packet, server)
    api_entities.__update_player__(packet.pid, packet.dirty)
end

handlers[ protocol.ServerMsg.EntityUpdate ] = function (packet, server)
    api_entities.__emit__(packet.uid, packet.entity_def, packet.dirty)
end

handlers[ protocol.ServerMsg.EntityDespawn ] = function (packet, server)
    api_entities.__despawn__(packet.uid)
end

handlers[ protocol.ServerMsg.ParticleEmit ] = function (packet, server)
    api_particles.emit(packet.particle)
end

handlers[ protocol.ServerMsg.ParticleStop ] = function (packet, server)
    api_particles.stop(packet.pid)
end

handlers[ protocol.ServerMsg.ParticleOrigin ] = function (packet, server)
    api_particles.set_origin(packet.origin)
end

handlers[ protocol.ServerMsg.AudioEmit ] = function (packet, server)
    api_audio.emit(packet.audio)
end

handlers[ protocol.ServerMsg.AudioStop ] = function (packet, server)
    api_audio.stop(packet.id)
end

handlers[ protocol.ServerMsg.AudioState ] = function (packet, server)
    api_audio.apply(packet.state)
end

handlers[ protocol.ServerMsg.WrapShow ] = function (packet, server)
    api_wraps.show(packet)
end

handlers[ protocol.ServerMsg.WrapHide ] = function (packet, server)
    api_wraps.hide(packet.id)
end

handlers[ protocol.ServerMsg.WrapSetPos ] = function (packet, server)
    api_wraps.set_pos(packet.id, packet.pos)
end

handlers[ protocol.ServerMsg.WrapSetTexture ] = function (packet, server)
    api_wraps.set_texture(packet.id, packet.texture)
end

handlers[ protocol.ServerMsg.Text3DShow ] = function (packet, server)
    api_text3d.show(packet.data)
end

handlers[ protocol.ServerMsg.Text3DHide ] = function (packet, server)
    api_text3d.hide(packet.id)
end

handlers[ protocol.ServerMsg.Text3DState ] = function (packet, server)
    api_text3d.apply(packet.state)
end

handlers[ protocol.ServerMsg.Text3DAxis ] = function (packet, server)
    local state = {
        id = packet.id
    }

    if packet.is_x then
        state.axisX = packet.axis
    else
        state.axisY = packet.axis
    end

    api_text3d.apply(state)
end

handlers[ protocol.ServerMsg.BlockInventory ] = function (packet, server)
    local invid = inventory.get_block(packet.x, packet.y, packet.z)
    inventory.set_inv(invid, packet.inventory)
end

handlers[ protocol.ServerMsg.BlockInventorySlot ] = function (packet, server)
    local invid = inventory.get_block(packet.x, packet.y, packet.z)
    inventory.set(invid, packet.slot_id, packet.item_id, packet.item_count)
end

return handlers