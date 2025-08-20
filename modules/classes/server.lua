local protocol = require "protocol/protocol"
local List = require "common/list"
local server_handlers = require "handlers/server"

local Server = {}
local max_id = 0
Server.__index = Server

function Server.new()
    local self = setmetatable({}, Server)

    self.active = true
    self.id = max_id
    self.state = 0

    self.handlers = {
        on_connect = nil,
        on_change_info = nil,
        on_join = nil,
        on_leave = nil,
        on_disconnect = nil
    }

    self.response_queue = List.new()
    self.received_packets = List.new()

    max_id = max_id + 1

    return self
end

function Server:queue_response(packets)
    for _, packet in ipairs(packets) do
        server_handlers[packet.packet_type](packet, self)
    end
end

function Server:push_packet(...)
    local packet = protocol.build_packet("client", ...)
    server_handlers[packet.packet_type](packet, self)
end

return Server