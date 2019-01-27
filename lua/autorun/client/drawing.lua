local urltbl = {}
local currentlist = 0

function SetCurList(int)	
	currentlist = int
end

function initRasp(int)
	local path = "downloaded_assets/"
	local files, directories = file.Find( path.."*", "DATA" )
	for k,v in pairs(files) do
		file.Delete(path..v)
	end
	currentlist = 0
	if int == 0 then return end
	urltbl = MarshrutsUrls[int]
	local i = 0
	for k,v in pairs(urltbl) do
		draw.WebImage(urltbl[k], 0/2, 0/2, 0, 0, nil, 0,nil)
		timer.Simple(3, function()
			currentlist = 1
			i = i + 0.1
			timer.Simple(i, function() if currentlist == table.Count(urltbl) then timer.Simple(0.3, function() currentlist = 0 end) else currentlist = currentlist + 1 end end)
		end)
	end
end

local width = 550/1.7
local height = 800/1.7
hook.Add("HUDPaint", "WebImage", function()
if currentlist < 1 then return end
draw.WebImage(urltbl[currentlist], width/2, height/2, width, height, nil, 0,nil)
end)
--ScrH()
--ScrW()