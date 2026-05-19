require "atmos.env.pico"

pico.set.window { title="Birds - 08 (fall)" }
pico.set.dim {'!', w=640, h=480}

pico.layer.image(nil, 'up', "res/bird-up.png")
pico.layer.image(nil, 'dn', "res/bird-dn.png")
local pct = {'%'}
pico.get.image("res/bird-up.png", pct)

math.randomseed()

function Bird (y, speed)
    local rect = {'%', x=0, y=y, w=pct.w, h=pct.h}
    task().rect  = rect
    task().alive = true
    local img = 'dn'
    watching(function(it) return rect.x>1 end, function ()
        watching('collided', function ()
            par (
                function ()
                    local ang = 0
                    every('clock', function (_,ms)
                        local v = ms * speed
                        rect.x = rect.x + v/1000
                        rect.y = y - (speed * math.sin(ang) / 5)
                        ang = ang + (math.pi*v/100)
                        local tmp = math.floor((ang+(math.pi/2))/math.pi)
                        img = (tmp%2 == 0) and 'up' or 'dn'
                    end)
                end,
                function ()
                    every('draw', function ()
                        pico.output.draw.layer(img, rect)
                    end)
                end
            )
        end)
        task().alive = false
        watching(function () return rect.y>1 end, function ()
            par(function ()
                every('clock', function (_,ms)
                    rect.y = rect.y + ms/1000
                end)
            end, function ()
                every('draw', function ()
                    pico.output.draw.layer('dn', rect)
                end)
            end)
        end)
    end)
end

loop(function ()
    local birds <close> = tasks(5)
    par (
        function ()
            every (clock{ms=500}, function ()
                spawn_in(birds, Bird, math.random(), 0.15 + math.random()/10)
            end)
        end,
        function ()
            every ('clock', function (_,ms)
                for _,b1 in getmetatable(birds).__pairs(birds) do
                    for _,b2 in getmetatable(birds).__pairs(birds) do
                        local col = (b1~=b2) and pico.vs.rect.rect(b1.rect,b2.rect)
                        if col then
                            emit_in(b1, 'collided')
                            emit_in(b2, 'collided')
                            break
                        end
                    end
                end
            end)
        end
    )
end)
