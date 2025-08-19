local account_manager = require "managers/account_manager"
local protocol = require "protocol/protocol"
local lib = require "common/min"
local module = {
    roles = {}
}

function module.get_account_by_name(username)
    return account_manager.by_username.get_account(username)
end

function module.get_client(account)
    return account_manager.get_client(account)
end

function module.get_client_by_name(username)
    return account_manager.by_username.get_client(username)
end

function module.kick(account, message)
    if not account.username then
        error("Invalid account")
    end

    local client = account_manager.get_client(account)

    client:push_packet(protocol.ServerMsg.Disconnect, message or "No reason")

    client:kick()
end

function module.roles.get(account)
    return account_manager.get_role(account)
end

function module.roles.get_rules(account, category)
    return account_manager.get_rules(account, category)
end

function module.roles.is_higher(role1, role2)
    return lib.roles.is_higher(role1, role2)
end

function module.roles.exists(role)
    return lib.roles.exists(role)
end

return module