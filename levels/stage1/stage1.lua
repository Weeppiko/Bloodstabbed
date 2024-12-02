return {
  version = "1.10",
  luaversion = "5.1",
  tiledversion = "1.11.0",
  class = "",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 400,
  height = 18,
  tilewidth = 8,
  tileheight = 8,
  nextlayerid = 11,
  nextobjectid = 177,
  properties = {
    ["music_filename"] = "music_a.ogg",
    ["music_loopstart"] = 4.414,
    ["palette_index"] = 2,
    ["script"] = "local spawn_rate = 5\nself.prng  = self.prng or love.math.newRandomGenerator(0xBA7A7A)\nself.bias  = self.bias or 0.5\nself.timer = (self.timer or 0) + dt\nif self.timer >= spawn_rate then\n  self.timer = self.timer - spawn_rate\n  local l, t, r, b = gamecamera:getBoundaries()\n  if self.prng:random() < self.bias then\n    self.bias = self.bias - 0.25\n    local near = gameroom:chooseFromGroup('player', function(a, b) return a.x < b.x end)\n    local properties = { direction = 'right', move_speed = 65 + self.prng:random(10) }\n    gameroom:addInstance('undead', 'objects', l, near.y_land, properties)\n  else\n    self.bias = self.bias + 0.25\n    local near = gameroom:chooseFromGroup('player', function(a, b) return a.x > b.x end)\n    local properties = { direction = 'left', move_speed = 45 + self.prng:random(10) }\n    gameroom:addInstance('undead', 'objects', r, near.y_land, properties)\n  end\nend\n\n"
  },
  tilesets = {
    {
      name = "tileset",
      firstgid = 1,
      class = "",
      tilewidth = 8,
      tileheight = 8,
      spacing = 0,
      margin = 0,
      columns = 16,
      image = "../../assets/tileset/tileset.png",
      imagewidth = 128,
      imageheight = 256,
      objectalignment = "unspecified",
      tilerendersize = "tile",
      fillmode = "stretch",
      tileoffset = {
        x = 0,
        y = 0
      },
      grid = {
        orientation = "orthogonal",
        width = 8,
        height = 8
      },
      properties = {},
      wangsets = {},
      tilecount = 512,
      tiles = {
        {
          id = 4,
          properties = {
            ["type"] = "solid"
          }
        },
        {
          id = 5,
          properties = {
            ["type"] = "solid"
          }
        },
        {
          id = 6,
          properties = {
            ["type"] = "solid"
          }
        },
        {
          id = 8,
          properties = {
            ["type"] = "oneway"
          }
        },
        {
          id = 9,
          properties = {
            ["type"] = "oneway"
          }
        },
        {
          id = 10,
          properties = {
            ["type"] = "oneway"
          }
        },
        {
          id = 11,
          properties = {
            ["type"] = "oneway"
          }
        },
        {
          id = 12,
          properties = {
            ["type"] = "solid"
          }
        },
        {
          id = 13,
          properties = {
            ["type"] = "solid"
          }
        },
        {
          id = 14,
          properties = {
            ["type"] = "solid"
          }
        },
        {
          id = 15,
          properties = {
            ["type"] = "oneway"
          }
        },
        {
          id = 20,
          properties = {
            ["type"] = "solid"
          }
        },
        {
          id = 21,
          properties = {
            ["type"] = "solid"
          }
        },
        {
          id = 22,
          properties = {
            ["type"] = "solid"
          }
        },
        {
          id = 28,
          properties = {
            ["type"] = "solid"
          }
        },
        {
          id = 29,
          properties = {
            ["type"] = "solid"
          }
        },
        {
          id = 30,
          properties = {
            ["type"] = "solid"
          }
        },
        {
          id = 36,
          properties = {
            ["type"] = "solid"
          }
        },
        {
          id = 37,
          properties = {
            ["type"] = "solid"
          }
        },
        {
          id = 38,
          properties = {
            ["type"] = "solid"
          }
        },
        {
          id = 44,
          properties = {
            ["type"] = "solid"
          }
        },
        {
          id = 45,
          properties = {
            ["type"] = "solid"
          }
        },
        {
          id = 46,
          properties = {
            ["type"] = "solid"
          }
        },
        {
          id = 74,
          properties = {
            ["type"] = "solid"
          }
        },
        {
          id = 75,
          properties = {
            ["type"] = "solid"
          }
        },
        {
          id = 76,
          properties = {
            ["type"] = "solid"
          }
        },
        {
          id = 90,
          properties = {
            ["type"] = "solid"
          }
        },
        {
          id = 91,
          properties = {
            ["type"] = "solid"
          }
        },
        {
          id = 92,
          properties = {
            ["type"] = "solid"
          }
        },
        {
          id = 96,
          properties = {
            ["type"] = "solid"
          }
        },
        {
          id = 97,
          properties = {
            ["type"] = "solid"
          }
        },
        {
          id = 98,
          properties = {
            ["type"] = "solid"
          }
        },
        {
          id = 112,
          properties = {
            ["type"] = "ladder"
          }
        },
        {
          id = 113,
          properties = {
            ["type"] = "ladder"
          }
        },
        {
          id = 128,
          properties = {
            ["type"] = "ladder"
          }
        },
        {
          id = 129,
          properties = {
            ["type"] = "ladder"
          }
        },
        {
          id = 130,
          properties = {
            ["type"] = "ladder"
          }
        },
        {
          id = 131,
          properties = {
            ["type"] = "ladder"
          }
        },
        {
          id = 144,
          properties = {
            ["type"] = "ladder"
          }
        },
        {
          id = 145,
          properties = {
            ["type"] = "ladder"
          }
        },
        {
          id = 146,
          properties = {
            ["type"] = "ladder"
          }
        },
        {
          id = 147,
          properties = {
            ["type"] = "ladder"
          }
        }
      }
    }
  },
  layers = {
    {
      type = "imagelayer",
      image = "../../assets/sprite/backplane1.png",
      id = 4,
      name = "background_lower",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 0,
      parallaxy = 1,
      repeatx = false,
      repeaty = false,
      properties = {}
    },
    {
      type = "imagelayer",
      image = "../../assets/sprite/backplane3.png",
      id = 9,
      name = "background_middle",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 0.5,
      parallaxy = 1,
      repeatx = true,
      repeaty = false,
      properties = {}
    },
    {
      type = "imagelayer",
      image = "../../assets/sprite/backplane2.png",
      id = 8,
      name = "background_upper",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 0.75,
      parallaxy = 1,
      repeatx = true,
      repeaty = false,
      properties = {}
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 400,
      height = 18,
      id = 6,
      name = "tiles_back",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "base64",
      compression = "zlib",
      data = "eJztmslNBEEMRSceYiEE0kBEgMiDJQC2BNgCYEsASIBlzhipRypaTdMuu2yr/J/0LzNll+0vdV28WgEAAAAAAAAAAAAAAAAAAADwm0PSEemYdNLgvFZsFrL6EamW3rCYLfzLxynpjHROuiBdKp/Xis1CVj8i1dIbFrOFf3m5Il2Tbki3pDvl81qxWcjqR6RaesNitvAvJ/ekB9Ij6Yn0rHxeKzYLWf2IVEtvWMwW/uXlhfRKemt0Xis2C1n9iFRLb1jMFv7l4530QfokfZHWyue1YrOQ1Y9ItfSGxWyn7liP/gdt9ww0c9fm2h5kxdL7OP1I5+gdX1LOh5O31kdr/yOj4aP3flwEP+dqyLS31XLPQDO3JNfOICuW3MfpRzpH7/gxm/lw89b6aO1/VDR8jLAfF8HPv2rw3tvaG2lX+NsSWu4ZaOauzbU1yIql93H6kc7RO76knA8nb62P1v5HRsNH7/24CH7O1TDVo+T7zOFgpH3hb0touWegmbs2V9T3g9OPdI7e8SXlfDh58X7I0fDRez8ugp9zNUz1KPk+c/B4P35ouWegmbsml/V3hxPH6Uc6R+/4DeP5LM2L90MHDR899+Mi+PlfDeMee34/Wu4yaOauzRX1/eD0I52jd3xJOR9OXrwfcjR89N6Pi+DnXA1TPVq9HwAAAAAAAABgxTco/wyw"
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 400,
      height = 18,
      id = 1,
      name = "tiles",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "base64",
      compression = "zlib",
      data = "eJzt2jFywjAQhWFOkCPQE44COQHJIaAiZahCSU4cUXjGeFYg7H3yavi/mdfIYyRrNRKFFgsAAAAAAAAAAAAAAAAAAAAAAAAAiOOY8h3gN+bU+vgVmBMAj/ymnAP8xpxaH78Cc4LaNinbQfYpB6NdlVx/H8LvjsqzHt7vWfXYOD6fGsX4oiuZv9J1oKxffwwtzjNsu5TPQX5STka7Krn+voTfHZVnPca+d0n5M9qteuwcn0+NYnzRlcxf6TpQ1q8/hhbnGbZVyvsgXa2H7ark+lsLvzsqz3p054CyHivH51OjGF90JfNXug6U9euPocV5hs2q/9h9Z2xy/b3iOvOsx9hzh/OjHSXzV7oOlPXrj6HFefaQu9/wbHukfj3/73b9Kvere2rXR3HfxbMenB++54fX+vJcp5wf7cjdb3i2PVK/nvtV1+9c50ft+ijuu3B+xD0/vNaX5zrl/JjmTZBa944IIYTc5no/S7GvW1kKUuveESGEkNtc72cp9nUr/+L1+44="
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 400,
      height = 18,
      id = 7,
      name = "tiles_front",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "base64",
      compression = "zlib",
      data = "eJzt2jsOABAURUH7wv63RSOxAJJLZpJTaXyie6UAAAAAAAAAAAAAAAAAALCrsxZav3juVK+9Rz24nri/dEn3518DAAAAAAAAAEvyDIwk/Zz5LAAA4EcDwI121Q=="
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 3,
      name = "objects",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      objects = {
        {
          id = 1,
          name = "Player",
          type = "player",
          shape = "point",
          x = 52,
          y = 120,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "player"
          }
        },
        {
          id = 38,
          name = "boss trigger",
          type = "trigger",
          shape = "point",
          x = 3120,
          y = 128,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "trigger",
            ["script"] = "gameroom:addInstance('megaskeleton', 'tiles_back', self.x)\ngameaudio:playBGM('boss.ogg', 0.75, 3.434)\ngamescene.get():stopScript()"
          }
        },
        {
          id = 75,
          name = "<- Undead",
          type = "placeholder",
          shape = "point",
          x = 720,
          y = 132,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "placeholder",
            ["direction"] = "left",
            ["enemy"] = "undead",
            ["modifier"] = 0,
            ["move_speed"] = 61
          }
        },
        {
          id = 78,
          name = "Undead ->",
          type = "placeholder",
          shape = "point",
          x = 660,
          y = 84,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "placeholder",
            ["direction"] = "right",
            ["enemy"] = "undead",
            ["modifier"] = 0,
            ["move_speed"] = 70
          }
        },
        {
          id = 80,
          name = "Undead ->",
          type = "placeholder",
          shape = "point",
          x = 756,
          y = 132,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "placeholder",
            ["direction"] = "right",
            ["enemy"] = "undead",
            ["modifier"] = 0,
            ["move_speed"] = 72
          }
        },
        {
          id = 81,
          name = "<- Undead",
          type = "placeholder",
          shape = "point",
          x = 852,
          y = 132,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "placeholder",
            ["direction"] = "left",
            ["enemy"] = "undead",
            ["modifier"] = 0,
            ["move_speed"] = 61
          }
        },
        {
          id = 82,
          name = "<- Undead",
          type = "placeholder",
          shape = "point",
          x = 968,
          y = 132,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "placeholder",
            ["direction"] = "left",
            ["enemy"] = "undead",
            ["modifier"] = 0,
            ["move_speed"] = 55
          }
        },
        {
          id = 83,
          name = "<- Undead",
          type = "placeholder",
          shape = "point",
          x = 1052,
          y = 132,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "placeholder",
            ["direction"] = "left",
            ["enemy"] = "undead",
            ["modifier"] = 0,
            ["move_speed"] = 55
          }
        },
        {
          id = 88,
          name = "<- Undead",
          type = "placeholder",
          shape = "point",
          x = 932,
          y = 84,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "placeholder",
            ["direction"] = "left",
            ["enemy"] = "undead",
            ["modifier"] = 0,
            ["move_speed"] = 60
          }
        },
        {
          id = 89,
          name = "<- Bat",
          type = "placeholder",
          shape = "point",
          x = 756,
          y = 68,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "placeholder",
            ["direction"] = "left",
            ["enemy"] = "bat",
            ["modifier"] = 1,
            ["move_speed"] = 50
          }
        },
        {
          id = 91,
          name = "<- Bat",
          type = "placeholder",
          shape = "point",
          x = 844,
          y = 76,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "placeholder",
            ["direction"] = "left",
            ["enemy"] = "bat",
            ["modifier"] = 1,
            ["move_speed"] = 50
          }
        },
        {
          id = 95,
          name = "Bat ->",
          type = "placeholder",
          shape = "point",
          x = 972,
          y = 116,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "placeholder",
            ["direction"] = "right",
            ["enemy"] = "bat",
            ["modifier"] = 1,
            ["move_speed"] = 90
          }
        },
        {
          id = 99,
          name = "Bat ->",
          type = "placeholder",
          shape = "point",
          x = 1200,
          y = 132,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "placeholder",
            ["direction"] = "right",
            ["enemy"] = "bat",
            ["modifier"] = 1,
            ["move_speed"] = 90
          }
        },
        {
          id = 102,
          name = "<- Undead",
          type = "placeholder",
          shape = "point",
          x = 1500,
          y = 132,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "placeholder",
            ["direction"] = "left",
            ["enemy"] = "undead",
            ["modifier"] = 0,
            ["move_speed"] = 64
          }
        },
        {
          id = 103,
          name = "Undead ->",
          type = "placeholder",
          shape = "point",
          x = 1560,
          y = 132,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "placeholder",
            ["direction"] = "right",
            ["enemy"] = "undead",
            ["modifier"] = 0,
            ["move_speed"] = 72
          }
        },
        {
          id = 104,
          name = "Undead ->",
          type = "placeholder",
          shape = "point",
          x = 1720,
          y = 132,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "placeholder",
            ["direction"] = "right",
            ["enemy"] = "undead",
            ["modifier"] = 0,
            ["move_speed"] = 75
          }
        },
        {
          id = 106,
          name = "Undead ->",
          type = "placeholder",
          shape = "point",
          x = 1492,
          y = 84,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "placeholder",
            ["direction"] = "right",
            ["enemy"] = "undead",
            ["modifier"] = 0,
            ["move_speed"] = 73
          }
        },
        {
          id = 108,
          name = "<- Undead",
          type = "placeholder",
          shape = "point",
          x = 1672,
          y = 84,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "placeholder",
            ["direction"] = "left",
            ["enemy"] = "undead",
            ["modifier"] = 0,
            ["move_speed"] = 60
          }
        },
        {
          id = 109,
          name = "<- Bat",
          type = "placeholder",
          shape = "point",
          x = 1636,
          y = 124,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "placeholder",
            ["direction"] = "left",
            ["enemy"] = "bat",
            ["modifier"] = 1,
            ["move_speed"] = 50
          }
        },
        {
          id = 110,
          name = "<- Bat",
          type = "placeholder",
          shape = "point",
          x = 1604,
          y = 68,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "placeholder",
            ["direction"] = "left",
            ["enemy"] = "bat",
            ["modifier"] = 1,
            ["move_speed"] = 50
          }
        },
        {
          id = 111,
          name = "<- Bat",
          type = "placeholder",
          shape = "point",
          x = 1780,
          y = 116,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "placeholder",
            ["direction"] = "left",
            ["enemy"] = "bat",
            ["modifier"] = 1,
            ["move_speed"] = 50
          }
        },
        {
          id = 112,
          name = "<- Bat",
          type = "placeholder",
          shape = "point",
          x = 1872,
          y = 120,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "placeholder",
            ["direction"] = "left",
            ["enemy"] = "bat",
            ["modifier"] = 1,
            ["move_speed"] = 50
          }
        },
        {
          id = 114,
          name = "<- Undead",
          type = "placeholder",
          shape = "point",
          x = 1740,
          y = 84,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "placeholder",
            ["direction"] = "left",
            ["enemy"] = "undead",
            ["modifier"] = 0,
            ["move_speed"] = 60
          }
        },
        {
          id = 117,
          name = "Bat ->",
          type = "placeholder",
          shape = "point",
          x = 1840,
          y = 72,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "placeholder",
            ["direction"] = "right",
            ["enemy"] = "bat",
            ["modifier"] = 1,
            ["move_speed"] = 70
          }
        },
        {
          id = 119,
          name = "Bat ->",
          type = "placeholder",
          shape = "point",
          x = 1908,
          y = 68,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "placeholder",
            ["direction"] = "right",
            ["enemy"] = "bat",
            ["modifier"] = 1,
            ["move_speed"] = 85
          }
        },
        {
          id = 120,
          name = "<- Undead",
          type = "placeholder",
          shape = "point",
          x = 1836,
          y = 132,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "placeholder",
            ["direction"] = "left",
            ["enemy"] = "undead",
            ["modifier"] = 0,
            ["move_speed"] = 55
          }
        },
        {
          id = 122,
          name = "<- Undead",
          type = "placeholder",
          shape = "point",
          x = 1952,
          y = 132,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "placeholder",
            ["direction"] = "left",
            ["enemy"] = "undead",
            ["modifier"] = 0,
            ["move_speed"] = 60
          }
        },
        {
          id = 128,
          name = "Undead ->",
          type = "placeholder",
          shape = "point",
          x = 2052,
          y = 132,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "placeholder",
            ["direction"] = "right",
            ["enemy"] = "undead",
            ["modifier"] = 0,
            ["move_speed"] = 70
          }
        },
        {
          id = 130,
          name = "<- Undead",
          type = "placeholder",
          shape = "point",
          x = 2160,
          y = 132,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "placeholder",
            ["direction"] = "left",
            ["enemy"] = "undead",
            ["modifier"] = 0,
            ["move_speed"] = 61
          }
        },
        {
          id = 132,
          name = "<- Undead",
          type = "placeholder",
          shape = "point",
          x = 2380,
          y = 132,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "placeholder",
            ["direction"] = "left",
            ["enemy"] = "undead",
            ["modifier"] = 0,
            ["move_speed"] = 55
          }
        },
        {
          id = 133,
          name = "Undead ->",
          type = "placeholder",
          shape = "point",
          x = 2308,
          y = 132,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "placeholder",
            ["direction"] = "right",
            ["enemy"] = "undead",
            ["modifier"] = 0,
            ["move_speed"] = 70
          }
        },
        {
          id = 135,
          name = "Undead ->",
          type = "placeholder",
          shape = "point",
          x = 1964,
          y = 84,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "placeholder",
            ["direction"] = "right",
            ["enemy"] = "undead",
            ["modifier"] = 0,
            ["move_speed"] = 70
          }
        },
        {
          id = 137,
          name = "<- Undead",
          type = "placeholder",
          shape = "point",
          x = 2064,
          y = 84,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "placeholder",
            ["direction"] = "left",
            ["enemy"] = "undead",
            ["modifier"] = 0,
            ["move_speed"] = 55
          }
        },
        {
          id = 139,
          name = "<- Bat",
          type = "placeholder",
          shape = "point",
          x = 2024,
          y = 68,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "placeholder",
            ["direction"] = "left",
            ["enemy"] = "bat",
            ["modifier"] = 1,
            ["move_speed"] = 50
          }
        },
        {
          id = 140,
          name = "<- Bat",
          type = "placeholder",
          shape = "point",
          x = 2108,
          y = 68,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "placeholder",
            ["direction"] = "left",
            ["enemy"] = "bat",
            ["modifier"] = 1,
            ["move_speed"] = 50
          }
        },
        {
          id = 142,
          name = "<- Bat",
          type = "placeholder",
          shape = "point",
          x = 2192,
          y = 60,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "placeholder",
            ["direction"] = "left",
            ["enemy"] = "bat",
            ["modifier"] = 1,
            ["move_speed"] = 50
          }
        },
        {
          id = 143,
          name = "Undead ->",
          type = "placeholder",
          shape = "point",
          x = 2196,
          y = 84,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "placeholder",
            ["direction"] = "right",
            ["enemy"] = "undead",
            ["modifier"] = 0,
            ["move_speed"] = 75
          }
        },
        {
          id = 144,
          name = "<- Undead",
          type = "placeholder",
          shape = "point",
          x = 2444,
          y = 132,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "placeholder",
            ["direction"] = "left",
            ["enemy"] = "undead",
            ["modifier"] = 0,
            ["move_speed"] = 60
          }
        },
        {
          id = 145,
          name = "<- Undead",
          type = "placeholder",
          shape = "point",
          x = 2596,
          y = 132,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "placeholder",
            ["direction"] = "left",
            ["enemy"] = "undead",
            ["modifier"] = 0,
            ["move_speed"] = 64
          }
        },
        {
          id = 146,
          name = "Undead ->",
          type = "placeholder",
          shape = "point",
          x = 2692,
          y = 132,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "placeholder",
            ["direction"] = "right",
            ["enemy"] = "undead",
            ["modifier"] = 0,
            ["move_speed"] = 72
          }
        },
        {
          id = 148,
          name = "Undead ->",
          type = "placeholder",
          shape = "point",
          x = 2592,
          y = 84,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "placeholder",
            ["direction"] = "right",
            ["enemy"] = "undead",
            ["modifier"] = 0,
            ["move_speed"] = 73
          }
        },
        {
          id = 149,
          name = "<- Undead",
          type = "placeholder",
          shape = "point",
          x = 2680,
          y = 84,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "placeholder",
            ["direction"] = "left",
            ["enemy"] = "undead",
            ["modifier"] = 0,
            ["move_speed"] = 60
          }
        },
        {
          id = 150,
          name = "<- Bat",
          type = "placeholder",
          shape = "point",
          x = 2540,
          y = 104,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "placeholder",
            ["direction"] = "left",
            ["enemy"] = "bat",
            ["modifier"] = 1,
            ["move_speed"] = 50
          }
        },
        {
          id = 151,
          name = "<- Bat",
          type = "placeholder",
          shape = "point",
          x = 2724,
          y = 68,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "placeholder",
            ["direction"] = "left",
            ["enemy"] = "bat",
            ["modifier"] = 1,
            ["move_speed"] = 50
          }
        },
        {
          id = 154,
          name = "Undead ->",
          type = "placeholder",
          shape = "point",
          x = 2768,
          y = 84,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "placeholder",
            ["direction"] = "right",
            ["enemy"] = "undead",
            ["modifier"] = 0,
            ["move_speed"] = 75
          }
        },
        {
          id = 155,
          name = "<- Undead",
          type = "placeholder",
          shape = "point",
          x = 2916,
          y = 84,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "placeholder",
            ["direction"] = "left",
            ["enemy"] = "undead",
            ["modifier"] = 0,
            ["move_speed"] = 60
          }
        },
        {
          id = 156,
          name = "Bat ->",
          type = "placeholder",
          shape = "point",
          x = 2820,
          y = 116,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "placeholder",
            ["direction"] = "right",
            ["enemy"] = "bat",
            ["modifier"] = 1,
            ["move_speed"] = 90
          }
        },
        {
          id = 158,
          name = "Bat ->",
          type = "placeholder",
          shape = "point",
          x = 2976,
          y = 116,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "placeholder",
            ["direction"] = "right",
            ["enemy"] = "bat",
            ["modifier"] = 1,
            ["move_speed"] = 80
          }
        },
        {
          id = 159,
          name = "Undead ->",
          type = "placeholder",
          shape = "point",
          x = 3020,
          y = 132,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "placeholder",
            ["direction"] = "right",
            ["enemy"] = "undead",
            ["modifier"] = 0,
            ["move_speed"] = 75
          }
        },
        {
          id = 161,
          name = "<- Undead",
          type = "placeholder",
          shape = "point",
          x = 308,
          y = 132,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "placeholder",
            ["direction"] = "left",
            ["enemy"] = "undead",
            ["modifier"] = 0,
            ["move_speed"] = 55
          }
        },
        {
          id = 162,
          name = "<- Undead",
          type = "placeholder",
          shape = "point",
          x = 604,
          y = 132,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "placeholder",
            ["direction"] = "left",
            ["enemy"] = "undead",
            ["modifier"] = 0,
            ["move_speed"] = 61
          }
        },
        {
          id = 164,
          name = "<- Undead",
          type = "placeholder",
          shape = "point",
          x = 1348,
          y = 132,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "placeholder",
            ["direction"] = "left",
            ["enemy"] = "undead",
            ["modifier"] = 0,
            ["move_speed"] = 60
          }
        },
        {
          id = 166,
          name = "<- Undead",
          type = "placeholder",
          shape = "point",
          x = 2796,
          y = 132,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["_module"] = "placeholder",
            ["direction"] = "left",
            ["enemy"] = "undead",
            ["modifier"] = 0,
            ["move_speed"] = 60
          }
        }
      }
    }
  }
}
