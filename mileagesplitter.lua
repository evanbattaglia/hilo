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

function write_coord(coord, newsegment, outfile)
  newsegment = newsegment and " newsegment=\"yes\"" or ""
  write("type=\"trackpoint\" latitude=\"" .. coord:lat() .. "\" longitude=\"" .. coord:lon() .. "\"" .. newsegment .. "\n", outfile)
end

function write(s, outfile)
  if outfile then
    outfile:write(s)
  end
  io.write(s)
end



--Written for 5.0; could be made slightly cleaner with 5.1
--Splits a string based on a separator string or pattern;
--returns an array of pieces of the string.
--(May optionally supply a table as the third parameter which will be filled  with the results.)
function string:split( inSplitPattern, outResults )
  if not outResults then
    outResults = { }
  end
  local theStart = 1
  local theSplitStart, theSplitEnd = string.find( self, inSplitPattern, 
theStart )
  while theSplitStart do
    table.insert( outResults, string.sub( self, theStart, theSplitStart-1 ) )
    theStart = theSplitEnd + 1
    theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
  end
  table.insert( outResults, string.sub( self, theStart ) )
  return outResults
end

function run(vw, thresholds, outfilename)
  thresholds = map(function(t) return(t * 1609.34) end, thresholds:split(","))

  local i = 1
  local vtl = vw:top_trwlayer()
  local newsegment = true

  local outfile = nil
  if (outfilename) then
    outfile = io.open(outfilename, "w")
  end
  write("type=\"track\" name=\"luaoutput\"\n", outfile)

  local thisfile = string.sub(debug.getinfo(1).source,2)
  local track = nil
  for trname, tr in vtl:tracks() do
    track = tr
  end
  local len = 0
  local last_coord = nil
  for tp in track:trackpoints() do
    if last_coord then
      len = len + coord.diff(tp:coord(), last_coord)
    end
    last_coord = tp:coord()
    if thresholds[i] and len > thresholds[i] then
      i = i + 1
      newsegment = true
    end
    if (i % 2) == 0 then
      write_coord(tp:coord(), newsegment, outfile)
      newsegment = false
    end
  end

  if outfile then outfile:close() end
end


