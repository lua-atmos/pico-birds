require "atmos.env.pico"

pico.set.window { title="Birds - 02 (scope)" }
pico.set.dim {'!', w=640, h=480}

pico.layer.image(nil, 'up', "res/bird-up.png")
pico.layer.image(nil, 'dn', "res/bird-dn.png")

function Bird (y, speed)
    local xx  = 0
    local yy  = y
    local img = 'dn'
    par (
        function ()
            local ang = 0
            every('clock', function (_,ms)
                local v = ms * speed
                xx = xx + (v/1000)
                yy = y - (speed * math.sin(ang) / 5)
                ang = ang + (math.pi*v/100)
                local tmp = math.floor((ang+(math.pi/2))/math.pi)
                img = (tmp%2 == 0) and 'up' or 'dn'
            end)
        end,
        function ()
            every('draw', function ()
                pico.output.draw.layer(img, {'%', x=xx, y=yy, w=0.15})
            end)
        end
    )
end

loop(function ()
    while true do
        local _ <close> = spawn(Bird, 0.33, 0.15)
        local _ <close> = spawn(Bird, 0.66, 0.30)
        await 'mouse.button.dn'
    end
end)
