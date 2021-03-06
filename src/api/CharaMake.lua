local chara_make = require("game.chara_make")

-- Functions for interacting with the character making process. Of
-- course, they will only have an effect while character making is
-- ongoing.
-- @module CharaMake
local CharaMake = {}

CharaMake.get_section_result = chara_make.get_section_result
CharaMake.make_chara = chara_make.make_chara
CharaMake.set_caption = chara_make.set_caption
CharaMake.is_active = chara_make.is_active

return CharaMake
