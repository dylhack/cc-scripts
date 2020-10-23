-- Version 3.1
local bomb = require('./bomb_lib')

function main()
    local distance
    local placed
    write('How far do you want me to move?\n')
    write('> ')
    distance = tonumber(read()) + 7
    
    -- Move
    print('Moving')
    bomb.move('forward', distance)
                
    -- Place TNT
    print('Placing')     
    if bomb.place_tnt() then
       print('Igniting')
       bomb.ignite()   
    end
            
    -- Run!
    print('Running')       
    bomb.move('back', distance)
end


main()
