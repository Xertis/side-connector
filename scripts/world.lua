local server_echo = require "common/server_echo"

function on_world_open()
end

function on_world_save()
    events.emit("server:save")
end

function on_world_tick()
    server_echo.proccess({CLIENT})
end