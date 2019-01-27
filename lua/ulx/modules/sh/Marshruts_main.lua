local MarshrutsTBL = {}
for i = 1, 999 do
	MarshrutsTBL[i] = {}
	MarshrutsTBL[i].curpos = 0
end
--PrintTable(MarshrutsTBL)
if SERVER then
	for k,v in pairs(player.GetAll()) do
		v:SendLua([[initRasp(0)]])
	end	
end

function ulx.nextlist( calling_ply,int)
local variable = ""
	if table.Count(MarshrutsUrls[int]) == 0 then return end
	local MarshrutCurPosCheck = true
			for k1,v1 in pairs(MarshrutsTBL[int]) do
				if type(v1) == "number" then continue end
				--if calling_ply:GetPos():DistToSqr(v1:GetPos()) > 500*500 or calling_ply == v1 then continue end				
				if MarshrutCurPosCheck then
					if MarshrutsTBL[int].curpos == table.Count(MarshrutsUrls[int]) then 
						MarshrutsTBL[int].curpos = 0
					else  
						MarshrutsTBL[int].curpos = MarshrutsTBL[int].curpos + 1
					end
					MarshrutCurPosCheck = false
				end
				v1:SendLua([[SetCurList(]]..(MarshrutsTBL[int].curpos)..[[)]])
				if MarshrutsTBL[int].curpos == 0 then 
					ulx.fancyLogAdmin(calling_ply, "#A #s маршрутный лист игроку #T", "забрал", v1) 
				elseif MarshrutsTBL[int].curpos == 1 then 
					ulx.fancyLogAdmin(calling_ply, "#A выдал #s маршрутный лист игроку #T", "первый", v1) 
				elseif MarshrutsTBL[int].curpos == table.Count(MarshrutsUrls[int]) then
					ulx.fancyLogAdmin(calling_ply, "#A выдал #s маршрутный лист игроку #T","последний", v1) 
				else
					ulx.fancyLogAdmin(calling_ply, "#A выдал #s маршрутный лист игроку #T","следующий", v1) 
				end
			end
end
local nextlist = ulx.command( "Metrostroi", "ulx next", ulx.nextlist, "!next",true )
nextlist:addParam{ type=ULib.cmds.NumArg,min=1,max=999,default=0,hint="Номер маршрута"}
nextlist:defaultAccess( ULib.ACCESS_ALL )
nextlist:help( "Показать следующий маршрутный лист." )


function ulx.prevlist( calling_ply,int)
	if table.Count(MarshrutsUrls[int]) == 0 then return end
	local MarshrutCurPosCheck = true
			for k1,v1 in pairs(MarshrutsTBL[int]) do
				if type(v1) == "number" then continue end
				--if calling_ply:GetPos():DistToSqr(v1:GetPos()) > 500*500 or calling_ply == v1 then continue end				
				if MarshrutCurPosCheck then
					if MarshrutsTBL[int].curpos == 0 then 
						MarshrutsTBL[int].curpos = table.Count(MarshrutsUrls[int])
					else  
						MarshrutsTBL[int].curpos = MarshrutsTBL[int].curpos - 1
					end
					MarshrutCurPosCheck = false
				end
				v1:SendLua([[SetCurList(]]..(MarshrutsTBL[int].curpos)..[[)]])
				if MarshrutsTBL[int].curpos == 0 then 
					ulx.fancyLogAdmin(calling_ply, "#A #s маршрутный лист игроку #T", "забрал", v1) 
				elseif MarshrutsTBL[int].curpos == 1 then 
					ulx.fancyLogAdmin(calling_ply, "#A выдал #s маршрутный лист игроку #T", "первый", v1) 
				elseif MarshrutsTBL[int].curpos == table.Count(MarshrutsUrls[int]) then
					ulx.fancyLogAdmin(calling_ply, "#A выдал #s маршрутный лист игроку #T","последний", v1) 
				else
					ulx.fancyLogAdmin(calling_ply, "#A выдал #s маршрутный лист игроку #T","предыдущий", v1) 
				end
			end
end
local prevlist = ulx.command( "Metrostroi", "ulx prev", ulx.prevlist, "!prev",true )
prevlist:addParam{ type=ULib.cmds.NumArg,min=1,max=999,default=0,hint="Номер маршрута"}
prevlist:defaultAccess( ULib.ACCESS_ALL )
prevlist:help( "Показать предыдущий маршрутный лист." )


function ulx.marshrut(calling_ply, target_ply, int)
	ulx.removemarshrut(calling_ply,target_ply)
	if int == 0 or table.Count(MarshrutsUrls[int]) == 0 then return end
	table.insert(MarshrutsTBL[int], table.Count(MarshrutsTBL[int])+1, target_ply)
	MarshrutsTBL[int].curpos = 0
	ulx.fancyLogAdmin(calling_ply, "#A назначил игрока #T на маршрут #i", target_ply, int)
	target_ply:SendLua([[initRasp(]]..int..[[)]])
end
local marshrut = ulx.command( "Metrostroi", "ulx marshrut", ulx.marshrut, "!marshrut",true )
marshrut:addParam{ type=ULib.cmds.PlayerArg}
marshrut:defaultAccess( ULib.ACCESS_ALL )
marshrut:addParam{ type=ULib.cmds.NumArg,min=0,max=999,default=0,hint="Номер мрашрута"}

function ulx.removemarshrut(calling_ply, target_ply)
	for k,v in pairs(MarshrutsTBL) do
		for k1,v1 in pairs(v) do
			if type(v1) == "number" then continue end
			if target_ply == v1 then
				target_ply:SendLua([[initRasp(0)]])
				if not calling_ply then 
					ulx.fancyLogAdmin(v1,"#A снялcя c маршрута #i", k) 
				else
					ulx.fancyLogAdmin(calling_ply, "#A снял игрока #T c маршрута #i", v1, k) 
				end
				MarshrutsTBL[k][k1] = nil
				MarshrutsTBL[k].curpos = 0
			end
		end
	end
end
local removemarshrut = ulx.command( "Metrostroi", "ulx removemarshrut", ulx.removemarshrut, "!removemarshrut",true )
removemarshrut:addParam{ type=ULib.cmds.PlayerArg}
removemarshrut:defaultAccess( ULib.ACCESS_ALL )


hook.Add("PlayerDisconnected", "MarshrutsTBLClear", function(ply) 
ulx.removemarshrut(nil, ply)
end)