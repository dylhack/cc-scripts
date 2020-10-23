local i = 0
local sleepTime = 18.541



function alert()
    redstone.setOutput('right', true)
    sleep(0.5)
    redstone.setOutput('right', false)
end


function main()
    redstone.setOutput('right', false)
    
    
    -- get synced
    while ((os.time() % 1) ~= 0) do sleep(0.05) end
    
    local time
    
    while true do
        time = os.time()
        
        if (time > sleepTime) then
            while true do
                sleep(0.5)
                print('Alert')
                alert()
                
                time = os.time()
                if (time < sleepTime) then
                    break
                end
            end
        end
        
        print(time)
        sleep(1)
    end
end


main()


