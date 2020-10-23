-- Version HEAD
local defHeaders = {
    ["Content-Type"] = "application/json"
}
local monitors = settings.get("discord.monitors", {"self"})


function clearAll()
    for i,monitor in ipairs(monitors) do
        if (monitor == "self") then
            term.setCursorBlink(true)
            term.clear()
            term.setCursorPos(1, 1)
        else
            peripheral.call(monitor, "setCursorBlink", true)
            peripheral.call(monitor, "clear")
            peripheral.call(monitor, "setCursorPos", 1, 1)
        end
    end
end


function writeAll(text)
    for i,monitor in ipairs(monitors) do
        if (monitor == "self") then
            term.redirect(term.native())
        else
            term.redirect(peripheral.wrap(monitor))
        end

        write(text)
    end
    term.redirect(term.native())
end


function writeOthers(text)
    for i,monitor in ipairs(monitors) do
        if (monitor ~= "self") then
            term.redirect(peripheral.wrap(monitor))
        end
        
        write(text)
    end
    term.redirect(term.native())
end


function send_message(webhook, username, content) 
    if (content == nil) then
        content = ""
    end

    local body = {
        ["username"] = username,
        ["content"] = content
    }
    local serialized = textutils.serializeJSON(body)
    local res = http.post(webhook, serialized, defHeaders)

        
    if (res == nil) then
        writeAll("Something went wrong\n")
        return
    end
    
    local status = res.getResponseCode()

    
    if (status == 200 or status == 204) then
        writeAll("Message Sent!\n")
    else
        writeAll("Something went wrong [" .. status .. "]\n")
    end
end


function prompt(dialogue)
    writeAll(dialogue)
    local result = read()
    writeOthers(result .. "\n")
    return result
end


function main()
    clearAll()
    settings.load(".discord.json")
    local username = settings.get("discord.username", "")
    local webhook = settings.get("discord.webhook", "")
        
    if (string.len(username) == 0) then
        username = prompt("Enter your username: ")
        settings.set("discord.username", username)
    end 
    
    if (string.len(webhook) == 0) then
        webhook = prompt("Enter Webhook: ")
        settings.set("discord.webhook", webhook)
    end

    settings.save(".discord.json")
    clearAll()

    local message = ""

    writeAll("Type \".help\" for commands\n\n")        

    while (true) do
        message = prompt(username .. ": ")
        
        if (message == ".help") then
            writeAll("Commands:\n")
            writeAll(" * .setname\n")
            writeAll(" * .exit\n")
        elseif (message == ".setname") then
            writeAll("Enter your name: ")
            username = read()
            settings.set("discord.username", username)
            settings.save(storage)
        elseif (message == ".exit") then
            break
        else
            send_message(webhook, username, message)
        end
    end
end


main()
