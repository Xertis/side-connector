local Player = {}
Player.__index = Player

function Player.new(username)
    local self = setmetatable({}, Player)

    self.username = username or "root"
    self.active = false
    self.entity_id = nil
    self.pid = nil
    self.world = nil
    self.is_teleported = false
    self.region_pos = {x = 0, z = 0}
    self.invid = 0

    return self
end

return Player