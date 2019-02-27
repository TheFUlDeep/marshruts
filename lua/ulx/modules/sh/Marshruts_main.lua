local MarshrutsUrls = {}
local MarshrutsTBL = {}
local MarshrutsTBL = {}
--PrintTable(MarshrutsTBL)
if SERVER then
	if file.Exists("MarshrutsUrls.txt", "DATA") then MarshrutsUrls = util.JSONToTable(file.Read("MarshrutsUrls.txt", "DATA")) end
	
	util.AddNetworkString("MarshrutsUrls")

	for k,v in pairs(player.GetAll()) do
		v:SendLua([[initRasp(0)]])
	end
end

if SERVER then
	function ulx.addlist(ply,int,str)
		if not str or str == "" or str:find(" ") then ULib.tsayError( ply, "Invalid link", true ) return end
		if not MarshrutsUrls[int] then MarshrutsUrls[int] = {} end
		MarshrutsUrls[int][table.Count(MarshrutsUrls[int])+1] = str
		PrintTable(MarshrutsUrls)
		file.Write("MarshrutsUrls.txt",util.TableToJSON(MarshrutsUrls))
		ulx.fancyLogAdmin(ply, "#A добавил маршрутный лист номер #i для маршрута #i",table.Count(MarshrutsUrls[int]),int) 
		
		net.Start("MarshrutsUrls")
		local DataToSend = util.Compress(util.TableToJSON(MarshrutsUrls[int]))
		if not #DataToSend then return end
		local DataToSendN = #DataToSend
		net.WriteUInt(DataToSendN, 32)
		net.WriteData(DataToSend,DataToSendN)
		if not MarshrutsTBL[int] then return end
		for k,v in pairs(MarshrutsTBL[int]) do
			if type(v) == "number" then continue end
			net.Send(v)
		end
	end
end
local addlist = ulx.command( "Metrostroi", "ulx addlist", ulx.addlist, "!addlist",true )
addlist:addParam{ type=ULib.cmds.NumArg,min=1,max=999,default=0,hint="Номер маршрута"}
addlist:addParam{ type=ULib.cmds.StringArg, hint="link" }
addlist:defaultAccess( ULib.ACCESS_ALL )
addlist:help( "Добавить маршрутный лист на маршрут" )

if SERVER then 
	function ulx.clearlist(ply,int)
		if MarshrutsTBL[int] then
			for k,v in pairs(MarshrutsTBL[int]) do
				if type(v) == "number" then continue end
				ulx.removemarshrut(ply,v)
			end
		end
		ulx.fancyLogAdmin(ply, "#A удалил маршрутные листы для маршрута #i",int) 
		if not MarshrutsUrls[int] then return end
		MarshrutsUrls[int] = nil
		file.Write("MarshrutsUrls.txt",util.TableToJSON(MarshrutsUrls))	
	end
end
local clearlist = ulx.command( "Metrostroi", "ulx clearlist", ulx.clearlist, "!clearlist",true )
clearlist:addParam{ type=ULib.cmds.NumArg,min=1,max=999,default=0,hint="Номер маршрута"}
clearlist:defaultAccess( ULib.ACCESS_ALL )
clearlist:help( "Удалить маршрутные листы для указанного маршрута" )

if SERVER then
	function ulx.nextlist( calling_ply,int)
	local variable = ""
		if not MarshrutsUrls[int] or table.Count(MarshrutsUrls[int]) == 0 or not MarshrutsTBL[int] then return end
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
				ulx.fancyLogAdmin(calling_ply, "#A #s маршрутный лист у игрока #T", "забрал", v1) 
			elseif MarshrutsTBL[int].curpos == 1 then 
				ulx.fancyLogAdmin(calling_ply, "#A выдал #s маршрутный лист игроку #T", "первый", v1) 
			elseif MarshrutsTBL[int].curpos == table.Count(MarshrutsUrls[int]) then
				ulx.fancyLogAdmin(calling_ply, "#A выдал #s маршрутный лист игроку #T","последний", v1) 
			else
				ulx.fancyLogAdmin(calling_ply, "#A выдал #s маршрутный лист игроку #T","следующий", v1) 
			end
		end
	end
end
local nextlist = ulx.command( "Metrostroi", "ulx next", ulx.nextlist, "!next",true )
nextlist:addParam{ type=ULib.cmds.NumArg,min=1,max=999,default=0,hint="Номер маршрута"}
nextlist:defaultAccess( ULib.ACCESS_ALL )
nextlist:help( "Показать следующий маршрутный лист." )

if SERVER then
	function ulx.prevlist( calling_ply,int)
		if not MarshrutsUrls[int] or table.Count(MarshrutsUrls[int]) == 0 then return end
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
					ulx.fancyLogAdmin(calling_ply, "#A #s маршрутный лист у игрока #T", "забрал", v1) 
				elseif MarshrutsTBL[int].curpos == 1 then 
					ulx.fancyLogAdmin(calling_ply, "#A выдал #s маршрутный лист игроку #T", "первый", v1) 
				elseif MarshrutsTBL[int].curpos == table.Count(MarshrutsUrls[int]) then
					ulx.fancyLogAdmin(calling_ply, "#A выдал #s маршрутный лист игроку #T","последний", v1) 
				else
					ulx.fancyLogAdmin(calling_ply, "#A выдал #s маршрутный лист игроку #T","предыдущий", v1) 
				end
			end
	end
end
local prevlist = ulx.command( "Metrostroi", "ulx prev", ulx.prevlist, "!prev",true )
prevlist:addParam{ type=ULib.cmds.NumArg,min=1,max=999,default=0,hint="Номер маршрута"}
prevlist:defaultAccess( ULib.ACCESS_ALL )
prevlist:help( "Показать предыдущий маршрутный лист." )

if SERVER then
	function ulx.marshrut(calling_ply, target_ply, int)
		ulx.removemarshrut(calling_ply,target_ply)
		if int == 0 then return end
		if not MarshrutsUrls[int] or table.Count(MarshrutsUrls[int]) == 0 then ULib.tsayError(calling_ply,"На данном маршруте нет листов") return end
		if not MarshrutsTBL[int] then MarshrutsTBL[int] = {} end
		table.insert(MarshrutsTBL[int], table.Count(MarshrutsTBL[int])+1, target_ply)
		MarshrutsTBL[int].curpos = 0
		
		net.Start("MarshrutsUrls")
		local DataToSend = util.Compress(util.TableToJSON(MarshrutsUrls[int]))
		if not #DataToSend then return end
		local DataToSendN = #DataToSend
		net.WriteUInt(DataToSendN, 32)
		net.WriteData(DataToSend,DataToSendN)
		net.Send(target_ply)
		
		ulx.fancyLogAdmin(calling_ply, "#A назначил игрока #T на маршрут #i", target_ply, int)
		target_ply:SendLua([[initRasp(]]..int..[[)]])
	end
end
local marshrut = ulx.command( "Metrostroi", "ulx marshrut", ulx.marshrut, "!marshrut",true )
marshrut:addParam{ type=ULib.cmds.PlayerArg}
marshrut:defaultAccess( ULib.ACCESS_ALL )
marshrut:addParam{ type=ULib.cmds.NumArg,min=0,max=999,default=0,hint="Номер мрашрута"}

if SERVER then
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
end
local removemarshrut = ulx.command( "Metrostroi", "ulx removemarshrut", ulx.removemarshrut, "!removemarshrut",true )
removemarshrut:addParam{ type=ULib.cmds.PlayerArg}
removemarshrut:defaultAccess( ULib.ACCESS_ALL )

if SERVER then
	hook.Add("PlayerDisconnected", "MarshrutsTBLClear", function(ply) 
	ulx.removemarshrut(nil, ply)
	end)
end