local account = {}
account.__index = account

function account.new(username)
    local self = setmetatable({}, account)

    self.username = username or "root"
    self.active = true
    self.is_logged = true
    self.role = "owner"
    self.password = nil

    return self
end

return account
