for _, side in ipairs({"top", "bottom", "front", "back", "left", "right"}) do
    if peripheral.getType(side) == "turtle" then
        peripheral.call(side, "turnOn")
    end
end

