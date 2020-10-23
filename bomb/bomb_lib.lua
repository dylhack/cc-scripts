-- Version 1
local bomb = {}

function bomb.select(name)
    local i = 1
    local data
    
    while i <= 16 do
        data = turtle.getItemDetail(i)
        
        if data ~= nil then
            if data.name == name then
                return true
            end
        end    
    end
    
    return false 
end


function bomb.select_fn(fn)
    local i = 1
    local data
    
    while i <= 16 do
        data = turtle.getItemDetail(i)    
        
        if data ~= nil then
            turtle.select(i)
            if fn() then
                return true
            end
        end     
    end
    return false
end


function bomb.select_tnt()
    local tnt_slots = settings.get(slots.tnt)
    local data
    
    for i,slot in ipairs(tnt_slots) do
        data = turtle.getItemDetail(slot)

        if data == nil then return false end
        if data.name == "minecraft:tnt" then
            return turtle.select(slot)
        end   
    end

    return false
end


function bomb.select_ignite()
    local ignite_slots = settings.get(slots.ignite)
    local data
    for i,slot in ipairs(ignite_slots) do
        data = turtle.getItemDetail(slot)
        
        if data.name == "minecraft:flint_and_steel" then
            turtle.select(slot)
            return true
        end
    end
    return false
end


function bomb.select_fuel()
    local fuel_slots = settings.get(slots.fuel)
    local selected
    
    for i,slot in ipairs(fuel_slots) do
        selected = turtle.select(slot)
        
        if selected then
            return true
        end    
    end
    return false
end


function bomb.place_tnt()
    local placed
    local selected = select_tnt()
  
    if selected then
        placed = turtle.place()
        
        if placed then
            return true
        else
            turtle.dig()
            placed = turtle.place()
            if not placed then
                write("Failed to place TNT\n")
            end
            
            return placed     
        end
    else
        write("Out of TNT!\n")
        return false
    end
end


function bomb.ignite()
    select_ignite()
    if not turtle.up() then
        if not turtle.digUp() then
            write("Failed to ignite\n")
            return false
        end
        turtle.up()       
    end
    if not turtle.place() then
        if not turtle.dig() then
            write("Failed to ignite\n")
            return false
        end
        turtle.place()
    end
    turtle.down()
    return true
end


function bomb.refuel()
    select_fuel()
    return turtle.refuel()
end


function bomb.move(direction, count, fn)
    local moved
    
    if direction == 'forward' then
        moved = turtle.forward()
    else
        moved = turtle.back()
    end
    
    if not moved then
        if turtle.getFuelLevel() == 0 then
            select_fuel()
            turtle.refuel()
        else
            turtle.dig()
        end
        return move(direction, count)
    else
        if fn ~= nil then fn() end
        if count <= 0 then
            return true
        else
            return move(direction, count - 1, fn)
        end
    end
end

return bomb

