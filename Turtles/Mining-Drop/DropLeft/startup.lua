for _, side in ipairs({"top", "bottom", "front", "back", "left", "right"}) do
    if peripheral.getType(side) == "turtle" then
        peripheral.call(side, "turnOn")
    end
end

while true do
    local success, data = turtle.inspect()
    if success and data.name:find("stone") then
        break
    else
        turtle.turnLeft()
    end
end

while true do
    turtle.turnLeft()
    for slot = 1, 16 do
        turtle.select(slot)
        turtle.dropDown()  
    end
    turtle.turnRight()  
    for slot = 1, 16 do
        if turtle.getItemCount(slot) ~= 64 then
            turtle.dig()
            break
        end
    end
end