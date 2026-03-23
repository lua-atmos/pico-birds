require "atmos.env.pico"

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
                pico.output.draw.image(img, {'%', x=xx, y=yy, w=0.15})
            end)
        end
    )
end

loop(function ()
    pico.set.window { title="Birds - 02 (scope)" }
    pico.set.view { dim={'!', w=640, h=480} }

    while true do
        local _ <close> = spawn(Bird, 0.33, 0.15)
        local _ <close> = spawn(Bird, 0.66, 0.30)
        await 'mouse.button.dn'
    end
end)
