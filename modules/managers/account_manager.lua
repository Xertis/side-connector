local Account = require "classes/account"
local sandbox = require "managers/sandbox"
local container = require "common/container"
local module = {
    by_username = {}
}

function module.login(username)
    logger.log(string.format('account "%s" is logging in...', username))

    if table.has(table.freeze_unpack(RESERVED_USERNAMES), username:lower()) then
        logger.log(string.format('The username "%s" is reserved for the system and cannot be used by a client.', username))
        return
    end

    local account = Account.new(username) or container.get_all(username).account
    local status = account:revive()

    if status == CODES.accounts.ReviveSuccess or status == CODES.accounts.WithoutChanges then
        -- Ну мы его разбудили правильно, ничего делать не надо, мы молодцы
    elseif status == CODES.accounts.DataLoss then
        account:set("role", CONFIG.roles.default_role)
        account:set("active", true)
    end

    if account:is_active() and container.accounts.get(account.username) == nil then
        container.accounts.put(account.username, account)
    end

    account:save()

    return account
end

function module.by_username.get_account(name)
    if not name then
        return nil
    end

    return container.accounts.get(name)
end

function module.leave(client)
    local account = client.account;

    logger.log(string.format('account "%s" left...', account.username))

    local date = os.date("*t");
    date.yday, date.wday, date.isdst, date.sec = nil, nil, nil, nil;

    if account.is_logged then
        account:set("last_session", {
            ip = client.address,
            timestamp = date,
        });
    end

    account:abort()

    local player = container.player_online.get(account.username)

    sandbox.leave_player(player)
    container.accounts.put(account.username, nil)

    return account
end

function module.get_role(account)
    if not account then
        return nil
    end

    return CONFIG.roles[account.role]
end

function module.get_client(account)
    if not account then
        error("Invalid account")
    end

    for _, client in pairs(container.clients_all.get()) do
        if not client.account then
            logger.log("Account information lost.", "E")
            goto continue
        end
        if client.account.username == account.username then
            return client
        end

        ::continue::
    end
end

function module.by_username.get_client(username)
    for _, client in pairs(container.clients_all.get()) do
        if client.account.username == username then
            return client
        end
    end
end

function module.get_rules(account, category)
    if not category then
        category = "game_rules"
    elseif category == true then
        category = "server_rules"
    end

    return CONFIG.roles[account.role][category]
end

return module
