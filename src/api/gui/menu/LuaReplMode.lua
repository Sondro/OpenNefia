local IReplMode = require("api.gui.menu.IReplMode")

local LuaReplMode = class("LuaReplMode", IReplMode)

function LuaReplMode:init(env)
   self.caret = "> "
   self.env = env

   -- HACK
   self.env.Debug = require("mod.debug.api.Debug")
end

function LuaReplMode:submit(text)
   -- WARNING: massive backdoor waiting to happen.
   local chunk, err = loadstring("return " .. text)

   if chunk == nil then
      chunk, err = loadstring(text)

      if chunk == nil then
         return false, err
      end
   end

   setfenv(chunk, self.env)

   local success, result = pcall(chunk)

   return success, result
end

return LuaReplMode