local Player = {}
Player.__index = Player

function Player.new(username)
    local self = setmetatable({}, Player)

    self.username = username
    self.active = false
    self.entity_id = nil
    self.pid = nil
    self.world = nil
    self.is_teleported = true
    self.region_pos = {x = 0, z = 0}
    self.invid = 0
    self.inv_is_changed = false
    self.temp = {}

    return self
end

function Player:is_active()
    return self.active
end

function Player:abort()
    self.active = false
    self:save()
end

function Player:save()

end

function Player:revive()
    self.active = true
    self:to_load()
    return CODES.players.ReviveSuccess
end

function Player:set(key, val)
    self[key] = val
end

function Player:to_save()
    return {
        username = self.username,
        entity_id = self.entity_id,
        world = self.world,
        pid = self.pid,
        invid = self.invid,
        region_pos = self.region_pos
    }
end

function Player:to_load()
    self.username = "root"
    self.entity_id = 0
    self.world = ""
    self.pid = 0
    self.invid = player.get_inventory(self.pid)
    self.region_pos = {x = 0, y = 0}
end

return Player