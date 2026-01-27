require "atmos.env.pico"

pico.set.title "Birds - 01 (task)"
local dim = {'!', w=640, h=480}
pico.set.view { window=dim, world=dim }

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
                pico.output.draw.image(img, {'%', x=xx, y=yy})
            end)
        end
    )
end

call(function ()
    spawn(Bird, 0.33, 0.15)
    spawn(Bird, 0.66, 0.30)
    await(false)
end)
