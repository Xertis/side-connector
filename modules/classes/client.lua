local protocol = require "protocol/protocol"
local List = require "common/list"
local server_handlers = require "handlers/server"

local Client = {}
local max_id = 0
Client.__index = Client

function Client.new(active, network, address, port, username)
    local self = setmetatable({}, Client)

    self.active = false or active
    self.network = network
    self.username = username
    self.address = address
    self.port = port
    self.client_id = max_id
    self.account = nil
    self.player = nil
    self.ping = {ping = 0, last_upd = 0}
    self.meta = {}
    self.is_kicked = false

    self.response_queue = List.new()
    self.received_packets = List.new()

    max_id = max_id + 1

    return self
end

function Client:push_packet(...)
    local packet = protocol.build_packet("server", ...)
    server_handlers[packet.packet_type](packet, self)
end

return Client