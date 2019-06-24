local Inventory = require("api.Inventory")
local ILocation = require("api.ILocation")

--- Interface for character inventory. Allows characters to store map
--- objects.
local ICharaInventory = interface("ICharaInventory", {}, {ILocation})

ICharaInventory:delegate("inv",
                        {
                           "is_positional",
                           "move_object",
                           "remove_object",
                           "move_object",
                           "can_take_object",
                           "is_in_bounds",
                           "objects_at_pos",
                           "get_object",
                           "has_object",
                           "iter"
                        })

function ICharaInventory:init()
   self.inv = Inventory:new(200)
end

function ICharaInventory:take_object(obj)
   if not self:can_take_object(obj) then
      return nil
   end

   if not self.inv:take_object(obj) then
      return nil
   end

   obj.location = self
   self:refresh_weight()

   return obj
end

function ICharaInventory:put_into(other, obj, x, y)
   local result = self.inv:put_into(other, obj, x, y)
   self:refresh_weight()

   return result
end


function ICharaInventory:drop_item(item, amount)
   if not self:has_item(item) then
      error("Character " .. self.uid .. " does not own item " .. item.uid)
   end

   local map = self:current_map()
   if not map then
      Log.warn("Character tried dropping item, but was not in map. %d", self.uid)
      return nil
   end

   return item:move_some(amount, map, self.x, self.y)
end

function ICharaInventory:take_item(item)
   return self:take_object(item)
end

function ICharaInventory:has_item(item)
   return self:has_object(item)
end

function ICharaInventory:iter_items()
   return self.inv:iter()
end

function ICharaInventory:stack_items()
   -- TODO
end

return ICharaInventory