local addOnName = "Bags"
local version = "2.1.0"

if _G.Library then
  if not Library.isRegistered(addOnName, version) then
    local Compatibility = Library.retrieve("Compatibility", "^2.0.2")
    local Set = Library.retrieve("Set", "^1.1.0")

    --- @class Bags
    local Bags = {}

    function Bags.countItem(itemID)
      local count = 0

      for containerIndex = 0, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
        for slotIndex = 1, Compatibility.Container.receiveNumberOfSlotsOfContainer(containerIndex) do
          local itemInfo = Compatibility.Container.retrieveItemInfo(
          containerIndex, slotIndex)
          if itemInfo and itemInfo.itemID == itemID then
            count = count + itemInfo.stackCount
          end
        end
      end

      return count
    end

    --- @param selector number|number[]|fun(containerIndex: number, slotIndex: number): boolean
    --- @return number|nil, number|nil
    function Bags.findItem(selector)
      local isMatch
      local selectorType = type(selector)
      if selectorType == "number" then
        selector = { selector, }
        isMatch = function(containerIndex, slotIndex)
          local slotItemID = C_Container.GetContainerItemID(containerIndex,
            slotIndex)
          return selector == slotItemID
        end
      elseif selectorType == "table" then
        isMatch = function(containerIndex, slotIndex)
          local slotItemID = C_Container.GetContainerItemID(containerIndex,
            slotIndex)
          return Set.contains(selector, slotItemID)
        end
      elseif selectorType == "function" then
        isMatch = selector
      else
        error("Invalid selector type: " .. selectorType)
      end

      for containerIndex = 0, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
        for slotIndex = 1, Compatibility.Container.receiveNumberOfSlotsOfContainer(containerIndex) do
          if isMatch(containerIndex, slotIndex) then
            return containerIndex, slotIndex
          end
        end
      end

      return nil, nil
    end

    function Bags.hasItem(itemID)
      for containerIndex = 0, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
        for slotIndex = 1, Compatibility.Container.receiveNumberOfSlotsOfContainer(containerIndex) do
          local slotItemID = C_Container.GetContainerItemID(containerIndex,
            slotIndex)
          if slotItemID == itemID then
            return true
          end
        end
      end

      return false
    end

    function Bags.determineNumberOfFreeSlots()
      local numberOfFreeSlots = 0
      for containerIndex = 0, NUM_BAG_SLOTS do
        numberOfFreeSlots = numberOfFreeSlots +
          Compatibility.Container.receiveNumberOfFreeSlotsInContainer(
          containerIndex)
      end
      return numberOfFreeSlots
    end

    function Bags.areBagsFull()
      return Bags.determineNumberOfFreeSlots() == 0
    end

    function Bags.hasFreeSpace()
      return Bags.determineNumberOfFreeSlots() >= 1
    end

    Library.register(addOnName, version, Bags)
  end
else
  error(addOnName .. " requires Library. It seems absent.")
end
