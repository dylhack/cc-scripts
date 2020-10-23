-- Version 1
local bomb = {}

function bomb.select(name)
    local i = 1
    local data
    
    while i <= 16 do
        data = turtle.getItemDetail(i)
        
        if data ~= nil then
            if data.name == name then
		turtle.select(i)
                return true
            end
        end    
	i = i + 1
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
	i = i + 1
    end
    return false
end


function bomb.select_tnt()
     return bomb.select('minecraft:tnt')
end


function bomb.select_ignite()
     return bomb.select("minecraft:flint_and_steel")
end


function bomb.place_tnt()
    local placed
  
    if bomb.select_tnt() then
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
    if not bomb.select_ignite() then
	    write("Failed to select flint and steel\n")
	    return false
    end

    if not turtle.up() then
        if not turtle.digUp() then
            write("Failed to prepare igniting\n")
            return false
        end
        turtle.up()       
    end

    if not turtle.place() then
        if not turtle.dig() then
            write("Failed to ignite\n")
	    turtle.down()
            return false
        end
        turtle.place()
    end

    turtle.down()
    return true
end


function bomb.refuel()
    return bomb.select_fn(turtle.refuel)
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
            bomb.refuel()
        else
            turtle.dig()
        end
        return bomb.move(direction, count, fn)
    else
        count = count - 1
	if fn ~= nil then fn() end
        if count <= 0 then
            return true
        else
            return bomb.move(direction, count, fn)
        end
    end
end

return bomb

