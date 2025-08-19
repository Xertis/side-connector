local Avatar = {}
local max_id = 0
Avatar.__index = Avatar

function Avatar.new(pid, name, pos, rot, cheats)
    local self = setmetatable({}, Avatar)

    self.pid = pid
    self.name = name
    self.invid = player.get_inventory(pid)
    self.inv = {}
    self.slot = 0
    self.region = {x = 0, z = 0}
    self.pos = pos or {x = 0, y = -10, z = 0}
    self.rot = rot or {yaw = 0, pitch = 0}
    self.cheats = cheats or {noclip = false, flight = false}
    self.active = true
    self.ping = {
        ping = -1,
        last_upd = 0
    }

    self.id = max_id

    self.changed_flags = {
        pos = false,
        rot = false,
        cheats = false,
        inv = false,
        slot = false,
        region = false
    }

    max_id = max_id + 1

    return self
end

function Avatar:is_active()
    return self.active
end

function Avatar:set_pos(pos, set_flag)
    if pos == nil then return end

    self.pos = {x = pos.x, y = pos.y, z = pos.z}
    player.set_pos(self.pid, pos.x, pos.y, pos.z)

    self.region = {
        x = math.floor(pos.x / 32),
        z = math.floor(pos.z / 32)
    }

    if set_flag then self.changed_flags.pos = true self.changed_flags.region = true end
end

function Avatar:set_rot(rot, set_flag)
    if rot == nil then return end

    self.rot = {yaw = rot.yaw, pitch = rot.pitch}
    player.set_rot(self.pid, rot.yaw, rot.pitch, 0)

    if set_flag then self.changed_flags.rot = true end
end

function Avatar:set_cheats(cheats, set_flag)
    if cheats == nil then return end

    self.cheats = {noclip = cheats.noclip, flight = cheats.flight}
    player.set_flight(self.pid, cheats.flight)
    player.set_noclip(self.pid, cheats.noclip)

    if set_flag then self.changed_flags.cheats = true end
end

function Avatar:set_inventory(inv, set_flag)
    if inv == nil then return end
    self.inv = inv
    inventory.set_inv(self.invid, inv)

    if set_flag then self.changed_flags.inv = true end
end

function Avatar:set_slot(slot_id, set_flag)
    if slot_id == nil then return end
    self.slot = slot_id
    player.set_selected_slot(self.pid, slot_id)

    if set_flag then self.changed_flags.slot = true end
end

function Avatar:despawn()
    player.delete(self.pid)
    self.active = false
end

return Avatar