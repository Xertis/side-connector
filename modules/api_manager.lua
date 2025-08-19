local manager = {}

function manager.load(side, file, version)
    local path = string.format("api/%s/%s/%s", version, side, file)
    return start_require(path)
end

return manager