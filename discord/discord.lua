-- Version 2
local discord = {
    headers = {
        ["Content-Type"] = "application/json",
    },
    storage = {
        name = ".discord",
        webhook = "webhook",
        username = "username",
    },
}


function discord.getMonitors()
    local i = 2
    local monitors = {
        "self",
    }

    peripheral.find("monitor", function (_n, obj)
        monitors[i] = obj
        i = i + 1
    end)

    return monitors
end


function discord.init()
    local username = ""
    local webhook = ""
    local monitors = discord.getMonitors()

    settings.load(discord.storage.name)
    
    username = settings.get(discord.storage.username, webhook)
    webhook = settings.get(discord.storage.webhook, username)
        
    if (string.len(username) == 0) then
        username = discord.prompt(monitors, "Enter your username: ")
        settings.set(discord.storage.username, username)
    end 
    
    if (string.len(webhook) == 0) then
        webhook = discord.prompt(monitors, "Enter Webhook: ")
        settings.set(discord.storage.webhook, webhook)
    end

    settings.save(discord.storage.name)
    discord.clearAll(monitors)

    return username, webhook, monitors
end


function discord.clearAll(monitors)
    for i,monitor in ipairs(monitors) do
        if (monitor == "self") then
            term.redirect(term.native())
        else
            term.redirect(monitor)
        end
        term.setCursorBlink(true)
        term.clear()
        term.setCursorPos(1, 1)
    end
    term.redirect(term.native())
end


function discord.writeAll(monitors, text)
    for i,monitor in ipairs(monitors) do
        if (monitor == "self") then
            term.redirect(term.native())
        else
            term.redirect(monitor)
        end

        write(text)
    end
    term.redirect(term.native())
end


function discord.writeOthers(monitors, text)
    for i,monitor in ipairs(monitors) do
        if (monitor ~= "self") then
            term.redirect(monitor)
        end
        
        write(text)
    end
    term.redirect(term.native())
end


function discord.send_message(webhook, username, content) 
    if (content == nil) then
        content = ""
    end

    local body = {
        ["username"] = username,
        ["content"] = content
    }
    local serialized = textutils.serializeJSON(body)
    local res = http.post(webhook, serialized, discord.headers)

        
    if (res == nil) then
        return nil
    end
    
    return res.getResponseCode()
end


function discord.prompt(monitors, dialogue)
    discord.writeAll(monitors, dialogue)
    local result = read()
    discord.writeOthers(monitors, result .. "\n")
    return result
end


function main()
    local username, webhook, monitors = discord.init()
    discord.clearAll(monitors)


    local message = ""

    discord.writeAll(monitors, "Type \".help\" for commands\n\n")        

    while (true) do
        message = discord.prompt(monitors, username .. ": ")
        
        if (message == ".help") then
            discord.writeAll(monitors, "Commands:\n")
            discord.writeAll(monitors, " * .setname\n")
            discord.writeAll(monitors, " * .exit\n")
        elseif (message == ".setname") then
            username = discord.prompt(monitors, "Enter your name: ")
            settings.set(discord.storage.username, username)
            settings.save(discord.storage.name)
        elseif (message == ".exit") then
            break
        else
            local res = discord.send_message(webhook, username, message)
            local err

            if res ~= 200 and res ~= 204 then
                if res == nil then
                    err = "Something went wrong.\n"
                else
                    err = "Something went wrong. [" .. res .. "]\n"
                end
                discord.writeAll(monitors, err)
            else
                discord.writeAll(monitors, "Message sent.\n")
            end
        end
    end
end

main()
