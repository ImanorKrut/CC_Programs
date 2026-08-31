for _, side in ipairs({"top", "bottom", "front", "back", "left", "right"}) do
    if peripheral.getType(side) == "turtle" then
        peripheral.call(side, "turnOn")
    end
end

while true do
    for slot = 1, 16 do
        turtle.select(slot)
        turtle.drop() 
    end
end
