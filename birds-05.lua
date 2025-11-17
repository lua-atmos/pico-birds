require "atmos.env.pico"
local pico = require "pico"

pico.set.title "Birds - 05 (termination)"
pico.set.size.window(640, 480)

local UP = "res/bird-up.png"
local DN = "res/bird-dn.png"

math.randomseed()

function Bird (y, speed)
    local xx  = 0
    local yy  = y
    local img = DN
    watching(function() return xx>640 end, function ()
        par (
            function ()
                local ang = 0
                every('clock', function (_,ms)
                    local v = ms * speed
                    xx = xx + (v/1000)
                    yy = y - ((speed/5) * math.sin(ang))
                    ang = ang + ((3.14*v)/100000)
                    local tmp = math.floor(((ang+(3.14/2))/3.14))
                    img = (tmp%2 == 0) and UP or DN
                end)
            end,
            function ()
                every('draw', function ()
                    pico.output.draw.image({x=xx,y=yy}, img)
                end)
            end
        )
    end)
end

call(function ()
    local birds = tasks(5)
    every (clock{ms=500}, function ()
        spawn_in(birds, Bird, math.random(0,480), 100 + math.random(0,100))
    end)
end)
