require "atmos.env.pico"
local pico = require "pico"

pico.set.title "Birds - 10 (tracking)"
local dim = {w=640,h=480}
pico.set.view { grid=false, window=dim, world=dim }

local UP = "res/bird-up.png"
local DN = "res/bird-dn.png"
local DIM = pico.get.image(UP, {'%'})

math.randomseed()

function Bird (y, speed)
    local rect = { 'C', x=0, y=y, w=DIM.w, h=DIM.h }
    task().rect  = rect
    task().alive = true
    local img = DN
    watching(function(it) return rect.x>1 end, function ()
        watching('collided', function ()
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
        task().alive = false
        watching(function () return rect.y>0.9 end, function ()
            par(function ()
                every('clock', function (_,ms)
                    rect.y = rect.y + ms/1000
                end)
            end, function ()
                every('draw', function ()
                    pico.output.draw.image(DN, rect)
                end)
            end)
        end)
        watching(clock{s=1}, function ()
            while true do
                await(clock{ms=100})
                watching(clock{ms=100}, function ()
                    every('draw', function ()
                        pico.output.draw.image(DN, rect)
                    end)
                end)
            end
        end)
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
            every ('clock', function (ms)
                for _,b1 in getmetatable(birds).__pairs(birds) do
                    for _,b2 in getmetatable(birds).__pairs(birds) do
                        local col = (b1~=b2) and b1.alive and b2.alive and pico.vs.rect_rect(b1.rect,b2.rect)
                        if col then
                            emit_in(b1, 'collided')
                            emit_in(b2, 'collided')
                            break
                        end
                    end
                end
            end)
        end,
        function ()
            while true do
                local _,_,bird = catch ('Track', function ()
                    every ('mouse.button.dn', function (evt)
                        for _,b in getmetatable(birds).__pairs(birds) do
                            if b.alive and pico.vs.pos_rect(evt,b.rect) then
                                throw('Track', b)
                            end
                        end
                    end)
                end)
                local base = { 'C', x=0.5, y=1 }
                watching (bird, function ()
                    every ('draw', function ()
                        pico.output.draw.line(base, bird.rect)
                    end)
                end)
            end
        end
    )
end)
