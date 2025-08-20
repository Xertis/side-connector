local protocol = require "protocol/protocol"

local module = {}
local entities_uids = {}
local entities_components = {}
local handlers = {}
local desynced_entities = {}

local PLAYER_ENTITY_ID = nil

local function vec_zero()
    return {0, 0, 0}
end

local original_spawn = entities.spawn

entities.spawn = function(name, ...)
    local source_path = debug.getinfo(2, "S").source or "core:bytearray"
    local prev_source_path = debug.getinfo(3, "S").source or "core:bytearray"

    if prev_source_path == "=[C]" then
        prev_source_path = "core:bytearray"
    end

    local prefix = parse_path(source_path)
    local prev_prefix = parse_path(prev_source_path)
    if desynced_entities[name] or prefix:find("side_connector") or prev_prefix:find("side_connector") then
        return original_spawn(name, ...)
    end

    local entity = original_spawn(name, ...)
    entity:despawn()

    SERVER:push_packet(protocol.ClientMsg.EntitySpawnTry, entity:def_index(), {...})

    return entity
end

function module.desync(name)
    desynced_entities[name] = true
end

function module.sync(name)
    desynced_entities[name] = nil
end

function module.set_handler(triggers, handler)
    for _, trigger in ipairs(triggers) do
        handlers[trigger] = handler
    end
end

function module.__despawn__(uid)
    local cuid = entities_uids[uid]
    if not cuid then return end

    entities_uids[uid] = nil
    local entity = entities.get(cuid)
    if entity then
        entity:despawn()
    end
end

local function call_component(entity, fields)
    for _, comp in pairs(entity.components) do
        if comp.on_custom_field_update then
            for field_key, field_value in pairs(fields) do
                comp.on_custom_field_update(field_key, field_value)
            end
        end
    end
end

local function update(cuid, def, dirty)
    local std_fields = dirty.standart_fields or {}
    local entity = entities.get(cuid)
    if not entity then return end

    call_component(entity, dirty.custom_fields or {})

    if handlers[def] then
        handlers[def](cuid, def, dirty.custom_fields or {})
    end

    if dirty.components then
        for comp_name, enabled in pairs(dirty.components) do
            local comp = entity:get_component(comp_name)
            if not comp then goto continue end

            entities_components[cuid] = entities_components[cuid] or {}
            local comp_cache = entities_components[cuid][comp_name] or {}

            if enabled then
                for fn_name, fn in pairs(comp_cache) do
                    comp[fn_name] = fn
                end
                entities_components[cuid][comp_name] = nil
            else
                entities_components[cuid][comp_name] = {}
                for fn_name, fn in pairs(comp) do
                    if type(fn) == "function" then
                        comp_cache[fn_name] = fn
                        comp[fn_name] = function() end
                    end
                end
            end
            ::continue::
        end
    end

    local skeleton = entity.skeleton
    if skeleton then
        for key, val in pairs(dirty.textures or {}) do
            skeleton:set_texture(key, val)
        end
        for key, val in pairs(dirty.models or {}) do
            skeleton:set_model(tonumber(key), val)
        end
    end


    local transform = entity.transform
    local rigidbody = entity.rigidbody

    if std_fields.tsf_pos then
        local current_pos = transform:get_pos()
        local target_pos = std_fields.tsf_pos
        local direction = vec3.sub(target_pos, current_pos)
        local distance = vec3.length(direction)

        if distance > 10 or distance < 0.01 then
            transform:set_pos(target_pos)
            rigidbody:set_vel(vec_zero())
        elseif rigidbody then
            local time_to_reach = 0.1
            local velocity = vec3.mul(vec3.normalize(direction), distance / time_to_reach)
            rigidbody:set_vel(velocity)
        end
    end

    if std_fields.tsf_rot then transform:set_rot(std_fields.tsf_rot) end
    if std_fields.tsf_scale then transform:set_scale(std_fields.tsf_scale) end
    if std_fields.body_size then rigidbody:set_size(std_fields.body_size) end
end

function module.__get_uids__()
    return entities_uids
end

function module.__update_player__(pid, dirty)
    if not PLAYER_ENTITY_ID then
        local player_entity = entities.get(player.get_entity(hud.get_player()))

        PLAYER_ENTITY_ID = player_entity:def_index()
    end
    update(player.get_entity(pid), PLAYER_ENTITY_ID, dirty)
end

function module.__emit__(uid, def, dirty)
    local std_fields = dirty.standart_fields or {}

    if not entities_uids[uid] then
        local entity_name = entities.def_name(def)
        local new_entity = original_spawn(entity_name, std_fields.tsf_pos or vec_zero())
        entities_uids[uid] = new_entity:get_uid()

        if new_entity.rigidbody then
            new_entity.rigidbody:set_gravity_scale(vec_zero())
        end
    end

    local cuid = entities_uids[uid]
    update(cuid, def, dirty)
end

return module