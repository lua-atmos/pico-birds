require "atmos.env.pico"
local pico = require "pico"

pico.set.title "Birds - 06 (pool/scope)"
local dim = {w=640,h=480}
pico.set.view { grid=false, window=dim, world=dim }

local UP = "res/bird-up.png"
local DN = "res/bird-dn.png"

math.randomseed()

function Bird (y, speed)
    local xx  = 0
    local yy  = y
    local img = DN
    watching(function() return xx>1 end, function ()
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
    end)
end

call(function ()
    while true do
        watching('mouse.button.dn', function ()
            local birds <close> = tasks(5)
            every (clock{ms=500}, function ()
                spawn_in(birds, Bird, math.random(), 0.15 + math.random()/10)
            end)
        end)
    end
end)
