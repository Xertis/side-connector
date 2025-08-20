require "globals"
require "init"

local api_manager = require "api_manager"

local server_api = {
    events = api_manager.load("server", "events", "v1"),
    accounts = api_manager.load("server", "accounts", "v1"),
    rpc = api_manager.load("server", "rpc", "v1"),
    bson = require "files/bson",
    --console = api_manager.load("server", "console", "v1"),
    sandbox = api_manager.load("server", "sandbox", "v1"),
    --db = api_manager.load("server", "db", "v1"),
    env = api_manager.load("server", "env", "v1"),
    --middlewares = api_manager.load("server", "middlewares", "v1"),
    protocol = api_manager.load("server", "protocol", "v1"),
    entities = api_manager.load("server", "entities", "v1"),
    weather = api_manager.load("server", "weather", "v1"),
    particles = api_manager.load("server", "particles", "v1"),
    audio = api_manager.load("server", "audio", "v1"),
    text3d = api_manager.load("server", "text3d", "v1"),
    blockwraps = api_manager.load("server", "blockwraps", "v1"),
    inventory_data = api_manager.load("server", "inv_dat", "v1"),
    constants = {
        --config = CONFIG,
        --render_distance = RENDER_DISTANCE,
        --tps = TPS
    }

}

local client_api = {
    events = api_manager.load("client", "events", "v1"),
    rpc = api_manager.load("client", "rpc", "v1"),
    bson = require "files/bson",
    env = api_manager.load("client", "env", "v1"),
    entities = api_manager.load("client", "entities", "v1"),
    sandbox = api_manager.load("client", "sandbox", "v1"),
    inv_dat = api_manager.load("server", "inv_dat", "v1")
}

return {server = server_api, client = client_api}