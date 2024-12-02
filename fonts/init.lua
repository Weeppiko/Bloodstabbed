local function make_font(file, width, height)
  local image = love.image.newImageData(file)
  local data = love.image.newImageData(16 * 16 * (width + 1), height)
  for y = 0, 15 do
    for x = 0, 15 do
      local src_x = x * width
      local src_y = y * height
      local out_x = (y * 16 + x) * (width + 1)
      data:setPixel(out_x, 0, 1, 1, 0, 1)
      data:paste(image, out_x + 1, 0, src_x, src_y, width, height)
    end
  end
  return data
end

local charset = [[ !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_£abcdefghijklmnopqrstuvwxyz{|}~©âãàáêéíôõóúç]]
return {
  normal = love.graphics.newImageFont( 'fonts/font.png', charset ),
  small  = love.graphics.newImageFont( make_font('fonts/font_alt1.png', 6, 6), charset ),
}
