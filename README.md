# Hilo notes

TODO:
  elevation in vikextractor.lua (copy column over to current hilo file)

--------------




What we would like:
  * total surface numbers (how much walked on what surface)
  * surface numbers by section (trail [wyoming, ict, gwt, imt connector], overall portion)
  * databook
  * water info
  * updated maps
  * information on way I should have gone but didn't
  * detailed information about specific parts
  * town info


A THREAD is a:
  list of POINTS: mileages and additional metadata
  list of RANGES: mileage ranges and metadata (overall section notes; surface??? but that is deducible from points!)
METADATA:
  POINT:
    name    } for correlation with geographical data source. we can add points/thread and mix in later
    lat/lon }
    junction
    another thread start
    another thread end
    water info
    town name
  COULD BE EITHER POINT OR RANGE (going to do point for simplicity)
    I've been there (yes/no)
    surface type change?
    trail-we're-on (wyoming NRT; ICT; etc.)
  RANGE:
    overall descriptions


TOOLS NEEDED:
   1) generator from geographical data
   2) databook/guidebook generator with certain filters

   for old data: dijkstra's which generates waypoints and old junction point with metadata about type of tracks (surface type etc sinc we use different colors to denote different sources)
   reverse a thread
   graph creator of threads for combining and maybe even visualization
  easier to start with: serial combining (simple concatenation). split up threads.

BIG QUESTION: raw data is numerical mileage data or geographical data? latter would be more useful but tricky...


1) Databook with:
     surface metadata
     trail-we're-on metadata
     services metadata including a town name
     detailed water notes (collapsable & can collate in a scrtipt)
     detailed notes on sections (can be hidden). maybe linked to a start and end  -> METADATA for inclusion in trailguide
     references to alternates and descriptions


-> all data tagged with position, can create a trail guide or databook out of it.

overall section notes tagged with position too.
alternates in databook format too, but mileages tagged based on their own: A1-0 Start alt, A1-1 alt turns to road, etc.

scripts to generate databook, etc

3) updated maps with correct surface marking and references to databook points and alternates.

4) town guide

-----------

^ concerns with this:
  1) some parts of my route were utter garbage. why put them as part of the data book?
     -> have other threads around that. can geenerate whatever
  2) what about parts we didn't walk?
  3) what about parts I tried to walk and didn't work, do we want to keep this around?
     -> might be able to have dead in threads in version 2.0


MODELS -- compare if your system works as well as:
  Ley's CDT maps (provide mileage and all import
  Skurka's HDT bundle
  PNT resoures?
