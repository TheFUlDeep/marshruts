local urltbl = {}
local currentlist = 0
local marhsh = 0

net.Receive( "MarshrutsUrls", function()
	local Len = net.ReadUInt(32)
	urltbl = util.JSONToTable(util.Decompress(net.ReadData(Len)))
	if not urltbl then return end
	--[[for k,v in pairs(urltbl) do
		draw.WebImage(v, 0, 0, 0, 0, nil, 0,nil)	
	end]]
	--PrintTable(urltbl)
end)

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
	marhsh = 0
	if int == 0 then return end
	marhsh = int
	if not urltbl then return end
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


local k = 2
local width = 693/1.2
local height = 454/1.2
local lastlist = currentlist
hook.Add("HUDPaint", "WebImage", function()
if not urltbl or not urltbl[currentlist] or currentlist < 1 then lastlist = currentlist return end
if lastlist ~= currentlist then
	lastlist = currentlist
	local w,h = GetPNGSize("downloaded_assets/"..util.CRC(urltbl[currentlist])..".png")
	if w and h then
		width = w
		height = h
	end
end
--if marhsh == 22 then width = 749/3 height = 1195/3 end
draw.WebImage(urltbl[currentlist], width/k/2, height/k/2, width/k, height/k, nil, 0,nil)
end)
--ScrH()
--ScrW()