local pico = require "pico"
local env  = require "atmos.env.pico"

pico.set.title "Birds - 08 (fall)"
pico.set.size.window(640, 480)

local UP = "res/bird-up.png"
local DN = "res/bird-dn.png"
local DIM = pico.get.size.image(UP)

math.randomseed()

function Bird (y, speed)
    local rect = { x=0, y=y, w=DIM.x, h=DIM.y }
    task().rect  = rect
    task().alive = true
    local img = DN
    watching(function(it) return rect.x>640 end, function ()
        watching('collided', function ()
            par (
                function ()
                    local ang = 0
                    every('clock', function (_,ms)
                        local v = ms * speed
                        rect.x = rect.x + (v/1000)
                        rect.y = y - ((speed/5) * math.sin(ang))
                        ang = ang + ((3.14*v)/100000)
                        local tmp = math.floor(((ang+(3.14/2))/3.14))
                        img = (tmp%2 == 0) and UP or DN
                    end)
                end,
                function ()
                    every('draw', function ()
                        pico.output.draw.image(rect, img)
                    end)
                end
            )
        end)
        task().alive = false
        watching(function () return rect.y>480-DIM.y/2 end, function ()
            par(function ()
                every('clock', function (_,ms)
                    rect.y = rect.y + (ms * 0.5)
                end)
            end, function ()
                every('draw', function ()
                    pico.output.draw.image(rect, DN)
                end)
            end)
        end)
    end)
end

call(function ()
    local birds <close> = tasks(5)
    par (
        function ()
            every (clock{ms=500}, function ()
                spawn_in(birds, Bird, math.random(0,480), 100 + math.random(0,100))
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
