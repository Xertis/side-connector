local protocol = {
    ServerMsg = {},
    ClientMsg = {},
    States = {}
}
local protocol_names = {server = {}, client = {}}
protocol.data = json.parse(file.read("side_connector:default_data/protocol/protocol.json"))

for key, packet in ipairs(protocol.data.server) do
    local names = {}
    for i=2, #packet do
        local raw_type = packet[i]
        local parts = string.explode(':', raw_type)

        local name = parts[1]
        table.insert(names, name)
    end

    protocol_names.server[key] = names
end

for key, packet in ipairs(protocol.data.client) do
    local names = {}
    for i=2, #packet do
        local raw_type = packet[i]
        local parts = string.explode(':', raw_type)

        local name = parts[1]
        table.insert(names, name)
    end

    protocol_names.client[key] = names
end

function protocol.create_databuffer()
    local buffer = {bytes = {__is_buffer = true}}

    function buffer.put_packet(_, packet)
        table.insert(buffer.bytes, packet)
    end

    return buffer
end

function protocol.build_packet(client_or_server, packet_type, ...)
    local values = {...}
    local packet = {}

    for indx, value in ipairs(values) do
        local name = protocol_names[client_or_server][packet_type][indx]
        packet[name] = value
    end

    packet["packet_type"] = packet_type

    return packet
end

function protocol.parse_packet(client_or_server, data)
    return data
end

for index, value in ipairs(protocol.data.server) do
    protocol.ServerMsg[index] = value[1]
    protocol.ServerMsg[value[1]] = index
end

for index, value in ipairs(protocol.data.client) do
    protocol.ClientMsg[index] = value[1]
    protocol.ClientMsg[value[1]] = index
end

return protocol