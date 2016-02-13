--[[ Original script written by FPtje (for Eusion): https://facepunch.com/showthread.php?t=735138. --]]
--[[ Modified/Enhanced by StealthPaw/101kl. --]]

local DBprefix = "gmpw" -- What the server SQL database name will be prefixed with.
local LoadOnStart = true -- Change this to false if you don't want the database to be auto-loaded when you start a game/server.
local SaveIndicator = false -- Change this to true if you want entities to quickly flash green/red, indicating they have been successfully added/removed to the database.
local DeleteOnRemove = false -- Change this to true if you want entities to delete from the map after removal from database (purge included).

if CLIENT then return end
local function GetWorldDatabase()
	if !DBprefix then return {} end
	return sql.Query("SELECT * FROM "..DBprefix.."_worldspawns;") or {}
end

local function WorldHasEntity(ent)
	if !IsValid(ent) or !ent.PermaWorld or !DBprefix then return false end
	local map = string.lower(game.GetMap())
	for _,v in pairs(GetWorldDatabase()) do
		if string.find(v.map, map) == 1 then
			if tostring(ent.PermaWorld) == tostring(v.unid) then return true end
		end
	end
	return false
end

local function FreezeEnt(ent)
	if !IsValid(ent) then return end
	ent:SetSolid(SOLID_VPHYSICS)
	ent:SetMoveType(MOVETYPE_NONE)
	local phys = ent:GetPhysicsObject()
	if phys and phys:IsValid() then phys:EnableMotion(false) end
end

local function PW_CleanWorld(ply)
	if (ply and !ply:IsSuperAdmin()) then return end
	local Refreshed = false
	for _,v in pairs(ents.GetAll()) do if IsValid(v) and v.PermaWorld then v:Remove() Refreshed = true end end
	if !Refreshed then return false end
	return true
end
concommand.Add("PermaWorld_CleanMap", PW_CleanWorld)

local function PW_Add(ply)
	local ent = ply:GetEyeTrace().Entity
	if !IsValid(ent) or !ply:IsSuperAdmin() or ent:IsWorld() or !DBprefix then return end
	if WorldHasEntity(ent) then ply:ChatPrint("Already In Database.") return end
	local pos = ent:GetPos()
	pos = Vector(math.Round(pos.x), math.Round(pos.y), math.Round(pos.z))
	local col = ent:GetColor() or Color(255,255,255,255)
	ent:SetPos(pos)
	local ang = ent:EyeAngles()
	ang = Angle(math.Round(ang.p), math.Round(ang.y), math.Round(ang.r))
	ent:SetAngles(ang)
	local map = string.lower(game.GetMap())
	local class = ent:GetClass() or "prop_physics"
	local model = ent:GetModel()
	local mat = ent:GetMaterial() or "false"
	if !model then return end
	FreezeEnt(ent)
	local data = GetWorldDatabase()
	local identifier = math.Rand( 1, 500 )
	for _,v in pairs(data) do if string.find(v.map, map) == 1 then if identifier == tonumber(v.unid) then identifier = math.Rand( 1, 500 ) end end end -- Just in case...
	ent.PermaWorld = identifier
	sql.Query("INSERT INTO "..DBprefix.."_worldspawns VALUES("..sql.SQLStr(map..tostring(table.Count(data) + 1))..", "..sql.SQLStr(identifier)..", "..sql.SQLStr(class)..", "..sql.SQLStr(model)..", "..sql.SQLStr(mat)..", "..sql.SQLStr(pos.x)..", "..sql.SQLStr(pos.y)..", "..sql.SQLStr(pos.z)..", "..sql.SQLStr(col.r)..", "..sql.SQLStr(col.g)..", "..sql.SQLStr(col.b)..", "..sql.SQLStr(col.a)..", "..sql.SQLStr(ang.p)..", "..sql.SQLStr(ang.y)..", "..sql.SQLStr(ang.r)..");")
	if SaveIndicator then
		local RenderMode = ent:GetRenderMode() or 1
		local RenderColor = ent:GetColor()
		if RenderMode != 1 then ent:SetRenderMode( 1 ) end
		ent:SetColor(Color(0,255,0,255))
		timer.Simple(0.5, function() if ent and IsValid(ent) then ent:SetColor(RenderColor or Color(255,255,255,255)) ent:SetRenderMode( RenderMode ) end end)
	end
	ply:ChatPrint("Added To Permanent World.")
end
concommand.Add("PermaWorld_Add", PW_Add)

local function PW_Remove(ply)
	local ent = ply:GetEyeTrace().Entity
	if !IsValid(ent) or !ply:IsSuperAdmin() or ent:IsWorld() or !ent.PermaWorld or !DBprefix then return end
	if !WorldHasEntity(ent) then ply:ChatPrint("Not In Database.") return end
	sql.Query("DELETE FROM "..DBprefix.."_worldspawns WHERE unid = "..sql.SQLStr(ent.PermaWorld)..";")
	ent.PermaWorld = false
	if SaveIndicator then
		local RenderMode = ent:GetRenderMode() or 1
		local RenderColor = ent:GetColor()
		if RenderMode != 1 then ent:SetRenderMode( 1 ) end
		ent:SetColor(Color(255,0,0,255))
		timer.Simple(0.5, function() if ent and IsValid(ent) then if DeleteOnRemove then ent:Remove() else ent:SetColor(RenderColor or Color(255,255,255,255)) ent:SetRenderMode( RenderMode ) end end end)
	end
	ply:ChatPrint("Removed From Permanent World.")
end
concommand.Add("PermaWorld_Remove", PW_Remove)

sql.Query("CREATE TABLE IF NOT EXISTS "..DBprefix.."_worldspawns('map' TEXT NOT NULL, 'unid' INTEGER NOT NULL, 'class' TEXT NOT NULL, 'model' TEXT NOT NULL, 'material' TEXT NOT NULL, 'x' INTEGER NOT NULL, 'y' INTEGER NOT NULL, 'z' INTEGER NOT NULL, 'red' INTEGER NOT NULL, 'green' INTEGER NOT NULL, 'blue' INTEGER NOT NULL, 'alpha' INTEGER NOT NULL, 'pitch' INTEGER NOT NULL, 'yaw' INTEGER NOT NULL, 'roll' INTEGER NOT NULL, PRIMARY KEY('map'));")

local function PW_Restore(ply)
	if (ply and !ply:IsSuperAdmin()) or !DBprefix then return end
	if PW_CleanWorld(ply) then ply:ChatPrint("Refreshing Permanent World.") end
	timer.Simple(1, function()
		local data = GetWorldDatabase()
		if !data then return end
		local map = string.lower(game.GetMap())
		for _,v in pairs(GetWorldDatabase()) do
			if string.find(v.map, map) == 1 then
				local ent = ents.Create(v.class or "prop_physics")
				ent:SetPos(Vector(tonumber(v.x), tonumber(v.y), tonumber(v.z)))
				ent:SetAngles(Angle(tonumber(v.pitch), tonumber(v.yaw), tonumber(v.roll)))
				if v.material and v.material != "false" then ent:SetMaterial( v.material, false ) end
				if tonumber(v.alpha) < 255 then ent:SetRenderMode( 1 ) end
				ent:SetColor(Color(tonumber(v.red), tonumber(v.green), tonumber(v.blue), tonumber(v.alpha)))
				ent:SetModel(v.model)
				FreezeEnt(ent)
				ent.PermaWorld = tonumber(v.unid)
			end
		end
	end)
end
if LoadOnStart then hook.Add( "InitPostEntity", "MapRestore", PW_Restore) end
concommand.Add("PermaWorld_Restore", PW_Restore)

local function PW_Purge(ply)
	if !ply:IsSuperAdmin() or !DBprefix then return end
	if DeleteOnRemove then PW_CleanWorld(ply) end
	local map = string.lower(game.GetMap())
	for _,v in pairs(GetWorldDatabase()) do
		if string.find(v.map, map) == 1 then
			sql.Query("DELETE FROM "..DBprefix.."_worldspawns WHERE map = "..sql.SQLStr(v.map)..";")
		end
	end
	ply:ChatPrint("Permanent World Database Purged.")
end
concommand.Add("PermaWorld_Purge", PW_Purge)