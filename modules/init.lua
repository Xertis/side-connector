--Проверка на наличие файла конфига
do
    if not file.exists(CONFIG_PATH) then
        file.write(CONFIG_PATH, file.read(PACK_ID .. ":default_data/server_config.json"))
    end
end

--Загружаем конфиг
do
    CONFIG = json.parse(file.read(CONFIG_PATH))

    if CONFIG.server.chunks_loading_distance > 255 then
        CONFIG.server.chunks_loading_distance = 255
        logger.log("Chunks distance is too high. Please select a value in the range of 0-255. The current chunks distance is set to 255", 'W')
    end

    CONFIG = table.freeze(CONFIG)

    RENDER_DISTANCE = (CONFIG.server.chunks_loading_distance + 2) * 16
end

logger.log("config initialized")

--Загружаем константы песочницы

do
    CODES = json.parse(file.read(CODES.codes_path))
    CODES = table.freeze(CODES)
end