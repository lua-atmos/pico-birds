require "atmos.env.pico"

pico.set.title "Birds - 07 (collision)"
local dim = {'!', w=640, h=480}
pico.set.view { window=dim, world=dim }

local UP = "res/bird-up.png"
local DN = "res/bird-dn.png"
local pct = {'%'}
pico.get.image(UP, pct)

math.randomseed()

function Bird (y, speed)
    local rect = {'%', x=0, y=y, w=pct.w, h=pct.h}
    task().rect = rect
    local img = DN
    watching(function(it) return rect.x>1 or it=='collided' end, function ()
        par (
            function ()
                local ang = 0
                every('clock', function (_,ms)
                    local v = ms * speed
                    rect.x = rect.x + (v/1000)
                    rect.y = y - (speed * math.sin(ang) / 5)
                    ang = ang + (3.14*v/100)
                    local tmp = math.floor((ang+(3.14/2))/3.14)
                    img = (tmp%2 == 0) and UP or DN
                end)
            end,
            function ()
                every('draw', function ()
                    pico.output.draw.image(img, rect)
                end)
            end
        )
    end)
end

call(function ()
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
                        local col = (b1~=b2) and pico.vs.rect_rect(b1.rect,b2.rect)
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
