local function hsv_to_rgb(h, s, v, a)
	local r, g, b
	local i = math.floor(h * 6);
	local f = h * 6 - i;
	local p = v * (1 - s);
	local q = v * (1 - f * s);
	local t = v * (1 - (1 - f) * s);
	i = i % 6
	if i == 0 then r, g, b = v, t, p
		elseif i == 1 then r, g, b = q, v, p
		elseif i == 2 then r, g, b = p, v, t
		elseif i == 3 then r, g, b = p, q, v
		elseif i == 4 then r, g, b = t, p, v
		elseif i == 5 then r, g, b = v, p, q
	end
	return {math.floor(r * 255), math.floor(g * 255), math.floor(b * 255), math.floor(a * 255)}
end

local spirit_framecount = 0
local spirit_last_height = 0
local spirit_color = Vector4(0, 0, 0, 0)
local spirit_radius = 0

local spirit_data = {}
for i = 0,64 do
    spirit_data[i] = Vector3(0,0,0)
end
local position_history = {}
for i = 0,129 do
    position_history[i] = Vector3(0,0,0)
end

function render_spirit()
    local position = Vector3(0,0,0)
    player.get_coordinates(player.index(), position)
    cameraPos = Vector3(0, 0, 0)
    player.get_coordinates(player.index(), cameraPos)
    cameraPos = Vector3(cameraPos.x, cameraPos.y+10, cameraPos.z+10)
    if spirit_last_height ~= 0 then
        if spirit_last_height > position.z + 3 then
            spirit_last_height = spirit_last_height - 0.1
        end
        if spirit_last_height < position.z - 3 then
            spirit_last_height = spirit_last_height + 0.1
        end
        position.z = spirit_last_height;
    end
    spirit_last_height = position.z;
    table.remove(position_history)
    position_history[#position_history+1] = position

    if position_history[128].x ~= 0 then
        position = position_history[128]
    end
    spirit_framecount = spirit_framecount + 1
    if position.z < cameraPos.z-20 then
        position.z = position.z + 1
    elseif position.z > cameraPos.z+20 then
        position.z = position.z -1
    end
        
    position.y = position.y + math.sin((spirit_framecount / 900) * math.pi) * 55
    position.x = position.x + math.cos((spirit_framecount / 900) * math.pi) * 55

    if spirit_framecount % 2 == 0 then
        table.remove(spirit_data)
        spirit_data[#spirit_data+1] = position
    end
    screenpos = Vector2(0, 0)

    utils.world_to_screen(position,screenpos)
    
    distance = math.sqrt(math.pow(cameraPos.x - position.x, 2) + math.pow(cameraPos.y - position.y, 2) + math.pow(cameraPos.z - position.z, 2))
    if 255 - distance > 0 then
        size = (255 - distance) / 8 + 10 
    else
        size = 15
    end
    radius = size
    spirit_radius = radius
    spirit_color = hsv_to_rgb(system.ticks() % 5050 / 5050,1, 1, 1)
    if screenpos.x ~= 0 then
        draw.set_color(0,spirit_color[1],spirit_color[2],spirit_color[3],spirit_color[4])
        draw.set_radius(radius - 10)
        draw.circle_filled(screenpos.x + 5, screenpos.y - 5)
        draw.set_radius(radius - 8)
        draw.circle_filled(screenpos.x + 4, screenpos.y - 4)
        draw.set_radius(radius - 4)
        draw.circle_filled(screenpos.x + 2, screenpos.y - 2)
        draw.set_radius(radius)
        draw.circle_filled(screenpos.x, screenpos.y)

    end
end

function OnFrame()
    if player.index() ~= -1 then
        render_spirit()
    end
end