require "atmos.env.pico"
local pico = require "pico"

pico.set.title "Birds - 04 (bounded)"
local dim = {w=640,h=480}
pico.set.view { grid=false, window=dim, world=dim }

local UP = "res/bird-up.png"
local DN = "res/bird-dn.png"

function Bird (y, speed)
    local xx  = 0
    local yy  = y
    local img = DN
    par (
        function ()
            local ang = 0
            every('clock', function (_,ms)
                local v = ms * speed
                xx = xx + (v/1000)
                yy = y - (speed * math.sin(ang) / 5)
                ang = ang + (3.14*v/100)
                local tmp = math.floor((ang+(3.14/2))/3.14)
                img = (tmp%2 == 0) and UP or DN
            end)
        end,
        function ()
            every('draw', function ()
                pico.output.draw.image(img, {'C',x=xx,y=yy,w=0,h=0})
            end)
        end
    )
end

call(function ()
    local birds = tasks()
    for i=1, 5 do
        spawn_in(birds, Bird, i*0.20-0.10, 0.15 + 0.02*i)
    end
    await(false)
end)
