--- Item generation algorithm for Elona.
--- @module Itemgen
local Chara = require("api.Chara")
local Item = require("api.Item")
local Rand = require("api.Rand")
local WeightedSampler = require("mod.tools.api.WeightedSampler")
local Log = require("api.Log")

-- This shouldn't be in base, since it has a lot of logic specific to
-- elona.
local Itemgen = {}

-- fltselects:
--  nil: vegetable_seed, long_staff, scroll_of_greater_identify
--  1: bug, fountain, tamers_whip, wallet, putitoro
--  2: shield_of_thorn, hiryu_to, skeleton_key, bow_of_vinderre, zantetsu, ether_dagger
--  3: gem_stone_of_mani, wind_bow, magic_fruit, statue_of_jure, diablo
--  8: tree_of_naked, tree_of_fir, christmas_tree

local function item_gen_weight(item, objlv)
   return math.floor((item.rarity or 1000000) / (1000 + math.abs((item.level or 0) - objlv) * (item.coefficient or 0)) + 1)
end

function Itemgen.random_item_id_raw(objlv, categories)
   objlv = objlv or 0
   categories = categories or {}
   assert(type(categories) == "table")
   if categories[1] then
      categories = table.set(categories)
   end

   local filter = function(item)
      if (item.level or 0) > objlv then
         return false
      end

      if next(categories) then
         local found = {}
         for _, v in ipairs(item.categories or {}) do
            if categories[v] then
               found[v] = true
            end
         end
         for k, _ in pairs(categories) do
            if not found[k] then
               return false
            end
         end
      end

      -- fltselect compatibility - item types with no_generate set to
      -- true means they will not be randomly generated unless
      -- explicitly asked for.
      for _, cat in ipairs(item.categories or {}) do
         if data["base.item_type"]:ensure(cat).no_generate then
            if not categories[cat] then
               return false
            end
         end
      end

      return true
   end

   local candidates = data["base.item"]:iter():filter(filter)
   local sampler = WeightedSampler:new()

   for _, item in candidates:unwrap() do
      local weight = item_gen_weight(item, objlv)
      sampler:add(item._id, weight)
   end

   if sampler:len() == 0 then
      Log.warn("No item generation candidates found for parameters: %d %s", objlv, inspect(categories))
   end

   return sampler:sample()
end

-- fltselect is always active in vanilla, so setting it to 0 will
-- still exclude items with a different fltselect, unlike flttypemajor
-- and flttypeminor, which are ignored if 0. To emulate this behavior,
-- the `categories` table has to be modified such that at most one
-- fltselect category is included at a time.

local function set_fltselect(categories, _type)
   local remove = {}
   for cat, _ in ipairs(categories) do
      if data["base.item_type"]:ensure(cat).no_generate then
         remove[#remove+1] = cat
      end
   end
   table.remove_keys(categories, remove)

   if _type then
      categories[#categories+1] = _type
   end
end

local function get_fltselect(categories)
   return fun.iter(categories)
       :filter(function(cat) return data["base.item_type"]:ensure(cat).no_generate end)
       :nth(1)
end


local function do_generate_item_id(params)
   local fltselect = get_fltselect(params.categories)

   if fltselect == nil and not params.is_shop then
      if params.quality == 3 and Rand.one_in(1000) then
         set_fltselect(params.categories, "elona.unique_item")
      end
      if params.quality == 4 and Rand.one_in(100) then
         set_fltselect(params.categories, "elona.unique_item")
      end
   end

   local id = Itemgen.random_item_id_raw(params.level, params.categories)

   if id == nil then
      if get_fltselect(params.categories) == "elona.unique_item" then
         params.quality = 4
      end
      params.level = params.level + 10
      set_fltselect(params.categories, nil)
      id = Itemgen.random_item_id_raw(params.level, params.categories)
   end

   if id == nil and params.categories["elona.furniture_altar"] then
      id = "elona.scroll_of_change_material"
   end

   return id
end

--- Creates a random item.
---
--- @tparam[opt] int x
--- @tparam[opt] int y
--- @tparam[opt] table params Extra parameters.
--- test
--- test2
--- @tparam[opt] ILocation where
--- @treturn[opt] IItem
function Itemgen.create(x, y, params, where)
   params = params or {}

   params.quality = params.quality or 0
   params.level = params.level or 0
   if type(params.categories) == "string" then
      params.categories = {params.categories}
   end
   params.categories = table.set(params.categories or {})

   local create_params = params.create_params or {}
   create_params.ownerless = params.ownerless

   local chara = Chara.player()
   if params.quality < 5 and chara and chara:skill_level("elona.stat_luck") > Rand.rnd(5000) then
      params.quality = params.quality + 1
   end

   local id = params.id or nil
   if id == nil then
      -- EVENT: generate_item_id
      id = do_generate_item_id(params)
   end

   local bug_id = "elona.bug"
   id = id or bug_id

   local item = Item.create(id, x, y, params.create_params, where)
   if item then
      item.quality = params.quality
   end

   return item
end

return Itemgen
