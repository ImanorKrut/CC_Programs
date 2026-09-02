-- ===========================================================
--  Snow Farm Turtle — CC:Tweaked snow farm
-- ===========================================================
--  KEY MECHANIC THIS SCRIPT RELIES ON:
--  When a turtle mines a block, the drop goes into the CURRENTLY
--  SELECTED slot if that slot is empty or already holds the same
--  item. Only if the selected slot can't accept it does the turtle
--  fall back to searching other slots.
--
--  So instead of mining randomly and then shuffling items around
--  the inventory, we pre-select each of the 4 crafting-grid slots
--  in turn and dig repeatedly UNTIL THAT EXACT SLOT is full. This
--  guarantees the right items end up in the right place for the
--  2x2 snow-block recipe, with no transfers needed at all in the
--  normal case.
--
--  What the turtle does, in a loop:
--   1) select craft slot -> dig until it holds 16 snowballs
--      (a full snowball stack), for all 4 craft slots in turn;
--      if the slot already had some snowballs before the program
--      started, it only mines the remaining amount needed;
--   2) craft as many snow blocks as possible from the full grid;
--   3) drop every finished snow block straight down;
--   4) repeat.
--
--  REQUIREMENTS:
--   1) This must be a Crafting Turtle (has turtle.craft).
--      A regular mining turtle won't work.
--   2) If mining a THIN SNOW LAYER (minecraft:snow) — a shovel
--      must be equipped (turtle.equipLeft()/turtle.equipRight()),
--      otherwise no snowball will drop. For a FULL SNOW BLOCK
--      (minecraft:snow_block) any tool works.
--   3) Whatever is in front of the turtle must regenerate on its
--      own (snowfall, a snow generator, etc.), otherwise there
--      will be nothing left to mine after the first pass.
--   4) There must be a free drop below the turtle (shaft, hopper,
--      chest, etc.) — blocks are dropped via dropDown.
--   5) The 4 craft slots (see CRAFT_SLOTS below) should be empty
--      or already contain snowballs before starting — any other
--      item sitting in one of them will block mining from filling
--      that slot correctly.
-- ===========================================================

local SNOWBALL   = "minecraft:snowball"
local SNOW_BLOCK = "minecraft:snow_block"

-- Snowballs only stack to 16 in vanilla Minecraft (not 64).
local SNOWBALL_STACK = 16

-- 3x3 crafting grid slots (laid out as: 1,2,3 / 5,6,7 / 9,10,11).
-- We only ever mine into the top-left 2x2 of that grid.
local CRAFT_SLOTS    = {1, 2, 5, 6}
-- The rest of the grid must stay empty or the 2x2 recipe won't match.
local BAD_GRID_SLOTS = {3, 7, 9, 10, 11}
-- Fallback storage, only used to sweep up rare spillover (see below).
local STORAGE_SLOTS  = {4, 8, 12, 13, 14, 15, 16}

-- How long to wait before retrying when there was nothing to mine.
local IDLE_WAIT = 0.5

-- Moves an item from fromSlot into any suitable slot from targets
-- (moves a whole stack at once, never one item at a time).
local function moveToAny(fromSlot, targets)
    for _, t in ipairs(targets) do
        if t ~= fromSlot then
            local item = turtle.getItemDetail(fromSlot)
            if not item then
                return true
            end
            local targetItem = turtle.getItemDetail(t)
            if (not targetItem) or (targetItem.name == item.name and targetItem.count < SNOWBALL_STACK) then
                turtle.select(fromSlot)
                turtle.transferTo(t)
                if not turtle.getItemDetail(fromSlot) then
                    return true
                end
            end
        end
    end
    return false
end

-- Mines directly into `slot` until it holds `target` snowballs,
-- picking up from whatever count is already sitting there.
local function fillSlotBySelectedMining(slot, target)
    turtle.select(slot)
    while turtle.getItemCount(slot) < target do
        if not turtle.dig() then
            sleep(IDLE_WAIT)
        end
    end
end

-- Fills all 4 craft slots to a full stack, one at a time.
local function fillCraftSlots()
    for _, slot in ipairs(CRAFT_SLOTS) do
        fillSlotBySelectedMining(slot, SNOWBALL_STACK)
    end
end

-- Rare edge case: mining a full snow block drops 4 snowballs in a
-- single dig, which can overflow past a slot's 16-item cap in one
-- go. The overflow then spills into the next free slot, which might
-- be one of the grid slots that has to stay empty. Sweep any such
-- spillover back into the craft slots (or storage) before crafting.
local function cleanupSpillover()
    for _, slot in ipairs(BAD_GRID_SLOTS) do
        local item = turtle.getItemDetail(slot)
        while item and item.name == SNOWBALL do
            if not moveToAny(slot, CRAFT_SLOTS) and not moveToAny(slot, STORAGE_SLOTS) then
                break
            end
            item = turtle.getItemDetail(slot)
        end
    end
end

-- Drops every snow block currently in the inventory straight down.
local function dropSnowBlocks()
    for slot = 1, 16 do
        local item = turtle.getItemDetail(slot)
        if item and item.name == SNOW_BLOCK then
            turtle.select(slot)
            turtle.dropDown()
        end
    end
end

-- Main loop.
local function main()
    if not turtle.craft then
        error("This turtle can't craft — a Crafting Turtle is required!")
    end

    print("Snow farm started. Ctrl+T to stop the program.")
    while true do
        fillCraftSlots()
        cleanupSpillover()

        local ok, reason = turtle.craft()
        if ok then
            dropSnowBlocks()
        else
            print("Failed to craft snow block: " .. tostring(reason))
        end
    end
end

main()
