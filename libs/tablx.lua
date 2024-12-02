local tablx = { }

function tablx.random(tbl)
  return tbl[ love.math.random(1, #tbl) ]
end

function tablx.lshift(tbl)
  table.insert( tbl, table.remove(tbl, 1) )
end

function tablx.rshift(tbl)
  table.insert( tbl, 1, table.remove(tbl) )
end

function tablx.shuffle(tbl)
  for i = #tbl, 2, -1 do
    local j = love.math.random(i)
    tbl[i], tbl[j] = tbl[j], tbl[i]
  end
  return tbl
end

function tablx.copy(t)
  local o = { }
  for k, v in pairs(t) do
    if type(v) == 'table' then
      o[k] = tblx.copy(v)
    else
      o[k] = v
    end
  end
  return o
end

return tablx
