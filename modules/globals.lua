local server = require "classes/server"
local client = require "classes/client"
local avatar = require "classes/avatar"

PACK_ID = "side_connector"

--Конфиг
CONFIG_PATH = "config:server_config.json"
CONFIG = {} --Инициализируется в std
LAST_SERVER_UPDATE = -1

--Песочница
RENDER_DISTANCE = 0
PLAYER_ENTITY_ID = nil
ROOT_PID = 0
COMMAND_PREFIX = "/"
RESERVED_USERNAMES = {}
CODES = {
    codes_path = "side_connector:default_data/codes.json"
}

SERVER = server.new()
CLIENT = client.new()
CLIENT_PLAYER = avatar.new(0)