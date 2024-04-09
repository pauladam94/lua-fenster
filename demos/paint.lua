local fenster = require('fenster')

---Draw a line between two points (window boundary version)
---@param window userdata
---@param x0 number
---@param y0 number
---@param x1 number
---@param y1 number
---@param color number
local function draw_line(window, x0, y0, x1, y1, color)
	local window_width = window:width()
	local window_height = window:height()
	local dx = math.abs(x1 - x0)
	local dy = math.abs(y1 - y0)
	local sx = x0 < x1 and 1 or -1
	local sy = y0 < y1 and 1 or -1
	local err = (dx > dy and dx or -dy) / 2
	local e2
	while true do
		-- NOTE: If you are copying this code, you may want to remove this boundary check
		if x0 >= 0 and x0 < window_width and y0 >= 0 and y0 < window_height then
			window:set(x0, y0, color)
		end

		if x0 == x1 and y0 == y1 then
			break
		end

		e2 = err
		if e2 > -dx then
			err = err - dy
			x0 = x0 + sx
		end
		if e2 < dy then
			err = err + dx
			y0 = y0 + sy
		end
	end
end

---Fill an area with a specific color
---@param x number
---@param y number
---@param color number
---@param old_color number?
local function fill(window, x, y, color, old_color)
	old_color = old_color or window:get(x, y)
	if old_color == color then
		return
	end
	if x < 0 or x >= window:width() or y < 0 or y >= window:height() then
		return
	end
	if window:get(x, y) == old_color then
		window:set(x, y, color)
		fill(window, x - 1, y, color, old_color)
		fill(window, x + 1, y, color, old_color)
		fill(window, x, y - 1, color, old_color)
		fill(window, x, y + 1, color, old_color)
	end
end

-- Define the keyboard keys and their corresponding colors
local key_color_map = {
	[48] = 0x000000, -- 0 (black)
	[49] = 0xffffff, -- 1 (white)
	[50] = 0x0000ff, -- 2 (blue)
	[51] = 0x00ff00, -- 3 (green)
	[52] = 0x00ffff, -- 4 (cyan)
	[53] = 0xff0000, -- 5 (red)
	[54] = 0xff00ff, -- 6 (magenta)
	[55] = 0xffff00, -- 7 (yellow)
	[56] = 0x808080, -- 8 (gray)
	[57] = 0xFFA500, -- 9 (orange)
}

-- Define the key for the fill action
local fill_key = 70 -- F Key

-- Open a window
local window_width = 640
local window_height = 480
local window = fenster.open(
	'Paint Demo - Press ESC to exit, 0-9 to change color, F to fill',
	window_width,
	window_height
)

-- Main loop
local paint_color = key_color_map[49]
local last_mouse_x, last_mouse_y
while window:loop(60) and not window:key(27) do
	local keys = window:keys()

	-- Check if a color key is pressed
	for key, color in pairs(key_color_map) do
		if keys[key] then
			-- Set the color to the assigned key color
			paint_color = color
		end
	end

	local mouse_x, mouse_y, mouse_down = window:mouse()

	if mouse_down then -- Check if mouse is pressed
		-- Check if the last mouse position is not set
		if not last_mouse_x and not last_mouse_y then
			-- Use the current mouse position as the "last mouse position" (line starting point)
			last_mouse_x, last_mouse_y = mouse_x, mouse_y
		end

		-- Draw a line between the last mouse position and the current mouse position
		draw_line(window, last_mouse_x, last_mouse_y, mouse_x, mouse_y, paint_color)

		-- Update the last mouse position
		last_mouse_x, last_mouse_y = mouse_x, mouse_y
	elseif last_mouse_x and last_mouse_y then -- Otherwise check if mouse is released
		-- Reset the last mouse position
		last_mouse_x, last_mouse_y = nil, nil
	elseif keys[fill_key] then -- Otherwise check if fill key is pressed
		-- Fill the area at the mouse position
		fill(window, mouse_x, mouse_y, paint_color)

		-- Wait until fill key released
		while window:loop(60) and window:key(fill_key) do end
	end
end
