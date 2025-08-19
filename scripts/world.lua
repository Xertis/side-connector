require "std/stdmin"

local server = require "classes/server"
local client = require "classes/client"

function on_world_open()
    SERVER = server
    CLIENT = client
end