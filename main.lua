cells = {}
colors = { 8, 12, 10 }

x = 64 y = 64
bg = 5

min = 5
mid = 61
max = 122

winner = nil

function _init()
  player = { x = mid, y = mid, r = 4, fill = 11, border = 3, cpu = false }
  cpu1 = { x = min, y = min, r = 4, fill = 3, border = 6, cpu = true }
  cpu2 = { x = mid, y = min, r = 4, fill = 12, border = 1, cpu = true }
  cpu3 = { x = max, y = min, r = 4, fill = 13, border = 2, cpu = true }
  cpu4 = { x = max, y = mid, r = 4, fill = 2, border = 13, cpu = true }
  cpu5 = { x = max, y = max, r = 4, fill = 14, border = 8, cpu = true }
  cpu6 = { x = mid, y = max, r = 4, fill = 8, border = 14, cpu = true }
  cpu7 = { x = min, y = max, r = 4, fill = 9, border = 10, cpu = true }
  cpu8 = { x = min, y = mid, r = 4, fill = 10, border = 9, cpu = true }

  cells[1] = player
  cells[2] = cpu1
  cells[3] = cpu2
  cells[4] = cpu3
  cells[5] = cpu4
  cells[6] = cpu5
  cells[7] = cpu6
  cells[8] = cpu7
  cells[9] = cpu8

  local feeders = {
    { x = 30, y = 30, r = 1 },
    { x = 35, y = 35, r = 1 },
    { x = 30, y = 40, r = 1 },
    { x = 40, y = 30, r = 1 },
    { x = 30, y = 30, r = 1 }
  }

  for f in all(feeders) do
    local feeder = { x = f.x, y = f.y, r = f.r, fill = 7, border = 6, cpu = true }
    add(cells, feeder)
  end

  -- alt colors if cell color matches bg
  for cell in all(cells) do
    if cell.fill == bg then
      cell.fill = 5
    end
  end
end

function _update()
  -- pause movement on victory
  if winner then return end
  -- arrow keys move player
  if btn(0) then cells[1].x = cells[1].x - 1 end
  if btn(1) then cells[1].x = cells[1].x + 1 end
  if btn(2) then cells[1].y = cells[1].y - 1 end
  if btn(3) then cells[1].y = cells[1].y + 1 end
  -- physics move cpus
  -- handle collisions
  collisions()
end

function _draw()
  cls(bg)
  if winner then
    local offset = { x = 0, y = 0 }
    winner.r += 1
    if winner.x > 0 then
      winner.x -= 1
      offset.x -= 1
    elseif winner.x < 0 then
      winner.x += 1
      offset.x += 1
    elseif winner.y > 0 then
      winner.y -= 1
      offset.y -= 1
    elseif winner.y < 0 then
      winner.y += 1
      offset.y += 1
    end
    camera(offset.x, offset.y)

    circfill(winner.x, winner.y, winner.r, winner.border)
    circfill(winner.x, winner.y, winner.r - 1, winner.fill)
    -- reset players and start drawing them in after new bg has filled out
    if winner.r == 64 then
      _init()
    elseif winner == 128 then
    end
    -- after winner takes over screen change bg and load next stage
    if winner.r >= 192 then
      bg = winner.fill
      winner = nil
    end
  else
    for cell in all(cells) do
      if cell.r > 0 then
        circfill(cell.x, cell.y, cell.r, cell.border)
        circfill(cell.x, cell.y, cell.r - 1, cell.fill)
      end
    end
  end
end

function collisions()
  for i = #cells, 1, -1 do
    for j = i - 1, 1, -1 do
      local cell_a = cells[i]
      local cell_b = cells[j]
      local distance = sqrt((cell_a.x - cell_b.x) ^ 2 + (cell_a.y - cell_b.y) ^ 2)
      if distance < cell_a.r + cell_b.r then
        absorb(cell_a, cell_b)
      end
    end
  end
end

function absorb(cell_a, cell_b)
  -- todo: if losing cell is player, zoom back out through all previous
  -- victories (tunnel-like) to starting point
  local tie = cell_a.r == cell_b.r
  local tie_breaker = rnd(2)
  if cell_a.r > cell_b.r or tie and tie_breaker == 0 then
    cell_a.r += cell_b.r
    cell_b.r = 0
  else
    cell_b.r += cell_a.r
    cell_a.r = 0
  end

  -- if only 1 cell remains declare the winner
  local remaining = 0
  local last_cell = nil
  for cell in all(cells) do
    if cell.r > 0 then
      remaining += 1
      last_cell = cell
    end
  end
  if remaining == 1 then
    winner = last_cell
  end
end