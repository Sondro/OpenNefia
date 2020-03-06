local config = {}

config["base.keybinds"] = {}
config["base.play_music"] = false
config["base.anim_wait"] = 80 * 0.5
config["base.screen_sync"] = 6
config["base.positional_audio"] = false
config["base.show_charamake_extras"] = false
config["base.quickstart_scenario"] = "content.my_scenario"
config["base.default_font"] = "kochi-gothic-subst.ttf"
config["base.quickstart_on_startup"] = false

-- private variables
config["base._save_id"] = nil
config["base._basic_attributes"] = {
   "elona.stat_strength",
   "elona.stat_constitution",
   "elona.stat_dexterity",
   "elona.stat_perception",
   "elona.stat_learning",
   "elona.stat_will",
   "elona.stat_magic",
   "elona.stat_charisma",
}

-- Don't overwrite existing values in the current config.
config.on_hotload = function(old, new)
   for k, v in pairs(new) do
      if old[k] == nil then
         old[k] = v
      end
   end
end

return config
