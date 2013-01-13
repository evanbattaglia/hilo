-- functions needed
-- trwlayer:waypoints() -> iterator wpname wp
-- wp:comment()
-- track:trackpoints() -> iterator
-- tp:coord()
-- wp:coord()
-- Viking.dist(coord1, coord2)
--
--
-- Later we can have unified types with a "we generated this so should free it in gc()" flag
--

--function run(vtl)
--  for trname, tr in vtl:tracks() do
--    io.write("track::: " .. trname .. "\n")
--  end
--  for wpname, wp in vtl:waypoints() do
--    cmt = wp:comment()
--    if cmt then
--      io.write("waypoint::: " .. wpname .. " = " .. cmt .. "\n")
--    end
--  end
--end

-- functions needed
-- trwlayer:waypoints() -> iterator wpname wp
-- track:trackpoints() -> iterator
-- tp:coord()
-- wp:coord()
-- Viking.dist(coord1, coord2)
-- wp:comment()
--
--
-- Later we can have unified types with a "we generated this so should free it in gc()" flag
--

-- Used to escape "'s by toCSV
function escape_csv(orig_s)
  s = tostring(orig_s)
  if string.find(s, '[,"]') or (type(orig_s) == "string" and string.find(s, "^[0-9\\.]+$")) then
    s = '"' .. string.gsub(s, '"', '""') .. '"'
  end
  return s
end

function map(func, tbl)
 local newtbl = {}
 for i,v in pairs(tbl) do
   newtbl[i] = func(v)
 end
 return newtbl
end

function csv_line(tbl)
  return table.concat(map(escape_csv, tbl), ",") .. "\n"
end

function write(s, outfile)
  if outfile then
    outfile:write(s)
  end
  io.write(s)
end

function run(vtl, outfilename)
  local outfile = nil
  if (outfilename) then
    outfile = io.open(outfilename, "w")
  end

  local thisfile = string.sub(debug.getinfo(1).source,2)
  dofile(string.gsub(thisfile, "[^/]*$", "") .. "hilofields.lua.rb")

  write(HILOFIELDS .. "\n", outfile)
  local track = nil
  for trname, tr in vtl:tracks() do
    track = tr
  end
  for wpname, wp in vtl:waypoints() do
    local nearest_dist = nil
    local nearest_len = nil
    local len = 0
    local last_coord = nil
    for tp in track:trackpoints() do
      local dist = coord.diff(tp:coord(), wp:coord())
      if dist < 300 and (nearest_dist == nil or dist < nearest_dist) then
        nearest_dist = dist
        nearest_len = len
      end
      if last_coord then
        len = len + coord.diff(tp:coord(), last_coord)
      end
      last_coord = tp:coord()
    end
    if nearest_dist then
      fields = {
        nearest_len/1000.0,
        wpname,
        string.gsub(wp:comment() or '', '\n', ' ; '),
        wp:coord():lat(),
        wp:coord():lon()
      }
      write(csv_line(fields), outfile)
      io.flush()
    end
  end

  if outfile then outfile:close() end
end


