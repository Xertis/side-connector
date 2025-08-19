local bit_converter = { }

-- Credits to Iryont <https://github.com/iryont/lua-struct>

local function reverse(tbl)
      for i=1, math.floor(#tbl / 2) do
        local tmp = tbl[i]
        tbl[i] = tbl[#tbl - i + 1]
        tbl[#tbl - i + 1] = tmp
      end
    return tbl
end

local orders = { "LE", "BE" }

local fromLEConvertors =
{
        LE = function(bytes) return bytes end,
        BE = function(bytes) return reverse(bytes) end
}

local toLEConvertors =
{
        LE = function(bytes) return bytes end,
        BE = function(bytes) return reverse(bytes) end
}

bit_converter.default_order = "BE"

local function fromLE(bytes, orderTo)
    if orderTo then
        bit_converter.validate_order(orderTo)
        return fromLEConvertors[orderTo](bytes)
    else return bytes end
end

local function toLE(bytes, orderFrom)
    if orderFrom then
        bit_converter.validate_order(orderFrom)
        return toLEConvertors[orderFrom](bytes)
    else return bytes end
end

function bit_converter.validate_order(order)
    if not bit_converter.is_valid_order(order) then
         error("invalid order: "..order)
    end
end

local function floatOrDoubleToBytes(val, opt)
    local sign = 0

    if val < 0 then
      sign = 1
      val = -val
    end

    local mantissa, exponent = math.frexp(val)
    if val == 0 then
      mantissa = 0
      exponent = 0
    else
      mantissa = (mantissa * 2 - 1) * math.ldexp(0.5, (opt == 'd') and 53 or 24)
      exponent = exponent + ((opt == 'd') and 1022 or 126)
    end

    local bytes = {}
    if opt == 'd' then
      val = mantissa
      for i = 1, 6 do
        bytes[#bytes + 1] = math.floor(val) % (2 ^ 8)
        val = math.floor(val / (2 ^ 8))
      end
    else
      bytes[#bytes + 1] = math.floor(mantissa) % (2 ^ 8)
      val = math.floor(mantissa / (2 ^ 8))
      bytes[#bytes + 1] = math.floor(val) % (2 ^ 8)
      val = math.floor(val / (2 ^ 8))
    end

    bytes[#bytes + 1] = math.floor(exponent * ((opt == 'd') and 16 or 128) + val) % (2 ^ 8)
    val = math.floor((exponent * ((opt == 'd') and 16 or 128) + val) / (2 ^ 8))
    bytes[#bytes + 1] = math.floor(sign * 128 + val) % (2 ^ 8)
    val = math.floor((sign * 128 + val) / (2 ^ 8))

    return bytes
end

local function bytesToFloatOrDouble(bytes, opt)
    local n = (opt == 'd') and 8 or 4

    local sign = 1
    local mantissa = bytes[n - 1] % ((opt == 'd') and 16 or 128)
    for i = n - 2, 1, -1 do
      mantissa = mantissa * (2 ^ 8) + bytes[i]
    end

    if bytes[n] > 127 then
      sign = -1
    end

    local exponent = (bytes[n] % 128) * ((opt == 'd') and 16 or 2) + math.floor(bytes[n - 1] / ((opt == 'd') and 16 or 128))
    if exponent == 0 then
      return 0.0
    else
      mantissa = (math.ldexp(mantissa, (opt == 'd') and -52 or -23) + 1) * sign
      return math.ldexp(mantissa, exponent - ((opt == 'd') and 1023 or 127))
    end
end

local function f16ToBytes(val)
    local sign = 0
    if val < 0 then
        sign = 1
        val = -val
    end

    local mantissa, exponent = 0, 0
    if val ~= 0 then
        local m, e = math.frexp(val)
        mantissa = (m * 2 - 1) * 1024.0
        exponent = e + 14

        if exponent < 1 then
            mantissa = math.floor(mantissa * math.ldexp(0.5, 1 - exponent) + 0.5)
            exponent = 0
        elseif exponent >= 31 then
            exponent = 31
            mantissa = 0
        else
            mantissa = math.floor(mantissa + 0.5)
            if mantissa >= 1024 then
                mantissa = 0
                exponent = exponent + 1
                if exponent >= 31 then exponent = 31 end
            end
        end
    end

    local byte0 = mantissa % 256
    local byte1 = math.floor(mantissa / 256) + (exponent % 32) * 4 + sign * 128
    return {byte0, byte1}
end

local function bytesToF16(bytes)
    local byte0, byte1 = bytes[1], bytes[2]
    local sign = math.floor(byte1 / 128)
    local exponent = math.floor((byte1 % 128) / 4)
    local mantissa = byte0 + (byte1 % 4) * 256

    if exponent == 0 then
        if mantissa == 0 then
            return sign == 1 and -0.0 or 0.0
        else
            return sign == 1 
               and -math.ldexp(mantissa / 1024.0, -14) 
                or math.ldexp(mantissa / 1024.0, -14)
        end
    elseif exponent == 31 then
        if mantissa == 0 then
            return sign == 1 and -math.huge or math.huge
        else
            return 0/0
        end
    else
        local m = 1 + mantissa / 1024.0
        if sign == 1 then m = -m end
        return math.ldexp(m, exponent - 15)
    end
end

function bit_converter.is_valid_order(order) return table.has(orders, order) end

function bit_converter.float16_to_bytes(float, order)
    return fromLE(f16ToBytes(float), order)
end

function bit_converter.float32_to_bytes(float, order)
    return fromLE(floatOrDoubleToBytes(float, 'f'), order)
end

function bit_converter.float64_to_bytes(float, order)
    return fromLE(floatOrDoubleToBytes(float, 'd'), order)
end

function bit_converter.bytes_to_float16(bytes, order)
    return bytesToF16(toLE(bytes, order))
end

function bit_converter.bytes_to_float32(bytes, order)
    return bytesToFloatOrDouble(toLE(bytes, order), 'f')
end

function bit_converter.bytes_to_float64(bytes, order)
    return bytesToFloatOrDouble(toLE(bytes, order), 'd')
end

function bit_converter.bytes_to_string(bytes, pos)
  local str_bytes = {}

	for i = pos, math.huge do
    local byte = bytes[i]
		if byte ~= 255 then
      table.insert(str_bytes, byte)
    else
      break
    end
	end

	return utf8.tostring(str_bytes)
end

function bit_converter.string_to_bytes(str)
	local bytes = utf8.tobytes(str, true)
  table.insert(bytes, 255)

	return bytes
end

function bit_converter.bool_to_byte(bool)
	return bool and 1 or 0
end

function bit_converter.norm16_to_bytes(val, order)
  val = math.clamp(val, -1, 1)

  local uint16
  if val >= 0 then
      uint16 = math.floor(val * 32767 + 32767 + 0.5)
  else
      uint16 = math.floor((val + 1) * 32767 + 0.5)
  end

  return fromLE({
      uint16 % 256,
      math.floor(uint16 / 256)
  }, order)
end

function bit_converter.bytes_to_norm16(bytes, order)
  bytes = toLE(bytes, order)
  local uint16 = bytes[1] + bytes[2] * 256

  if uint16 > 32767 then
      return (uint16 - 32767) / 32767
  else
      return uint16 / 32767 - 1
  end
end

function bit_converter.uint24_to_bytes(val, order)
  return fromLE({
      bit.band(bit.rshift(val, 16), 0xFF),
      bit.band(bit.rshift(val, 8), 0xFF),
      bit.band(val, 0xFF)
  }, order)
end

function bit_converter.bytes_to_uint24(bytes, order)
    bytes = toLE(bytes, order)
    return bit.bor(
      bit.lshift(bytes[1], 16),
      bit.lshift(bytes[2], 8),
      bytes[3]
  )
end

function bit_converter.norm8_to_byte(val)
  local uint8 = math.floor((math.clamp(val, -1, 1) + 1) * 127.5 + 0.5)
  return uint8
end

function bit_converter.byte_to_norm8(uint8)
  return (uint8 / 127.5) - 1
end


return bit_converter
