-- CONFIGURACIÓN DE KEYAUTH
local KeyAuthConfig = {
    Name = "serios.gg",           -- Cambia esto por el nombre de tu aplicación
    OwnerID = "UPGTkUDkee",       -- Cambia esto por tu Owner ID
    Version = "1.0"                -- Cambia esto por tu versión
}

-- URL de la API de KeyAuth
local KeyAuthURL = "https://keyauth.win/api/1.2/"

-- Función de verificación (sin prints)
local function verifyWithKeyAuth(username, key, callback)
    if username == "" or key == "" then
        callback(false, "empty")
        return
    end
    
    local httpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    if not httpRequest then
        callback(false, "no_http")
        return
    end
    
    -- Inicializar sesión
    local initData = string.format(
        "type=init&name=%s&ownerid=%s&version=%s",
        KeyAuthConfig.Name,
        KeyAuthConfig.OwnerID,
        KeyAuthConfig.Version
    )
    
    local initSuccess, initResponse = pcall(function()
        return httpRequest({
            Url = KeyAuthURL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/x-www-form-urlencoded"},
            Body = initData
        })
    end)
    
    if not initSuccess or not initResponse or not initResponse.Body then
        callback(false, "connection_error")
        return
    end
    
    local initData
    local parseSuccess = pcall(function()
        initData = game:GetService("HttpService"):JSONDecode(initResponse.Body)
    end)
    
    if not parseSuccess or not initData.success or not initData.sessionid then
        callback(false, "init_failed")
        return
    end
    
    -- Login
    local loginData = string.format(
        "type=login&username=%s&pass=%s&sessionid=%s&name=%s&ownerid=%s",
        username,
        key,
        initData.sessionid,
        KeyAuthConfig.Name,
        KeyAuthConfig.OwnerID
    )
    
    local loginSuccess, loginResponse = pcall(function()
        return httpRequest({
            Url = KeyAuthURL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/x-www-form-urlencoded"},
            Body = loginData
        })
    end)
    
    if not loginSuccess or not loginResponse or not loginResponse.Body then
        callback(false, "connection_error")
        return
    end
    
    local loginData
    parseSuccess = pcall(function()
        loginData = game:GetService("HttpService"):JSONDecode(loginResponse.Body)
    end)
    
    if not parseSuccess then
        callback(false, "parse_error")
        return
    end
    
    if loginData.success then
        callback(true, loginData.message or "Verified")
    else
        callback(false, loginData.message or "invalid")
    end
end

return {
    Config = KeyAuthConfig,
    URL = KeyAuthURL,
    Verify = verifyWithKeyAuth
}
