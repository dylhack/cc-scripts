-- Version 3.1
local bomb = require('./bomb_lib')


function main()
    local amount
    local offset
    local placed

    write('How many do you want me to place?\n')
    write('> ')
    amount = tonumber(read())
    offset = 1
    
    
    -- Move
    print('Moving')
    bomb.move('forward', offset)
                
    -- Place TNT
    print('Placing') 
    bomb.move('forward', amount)
    if bomb.move('back', amount, bomb.place_tnt) then
        bomb.ignite()
    end
            
    -- Run!
    print('Running')       
    bomb.move('back', offset)
end


main()
