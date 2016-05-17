TOOL.Name			= "#GMPermaWorld"
TOOL.Category		= "Server Tools"
TOOL.Command		= nil
TOOL.ConfigName		= ""

if ( CLIENT ) then
	language.Add( "tool.gmpermaworld.name", "GMPermaWorld" )
	language.Add( "tool.gmpermaworld.desc", "Keep entities persistent on a server." )
	TOOL.Information = {
		{ name = "info", stage = 1},
		{ name = "left"},
		{ name = "right"},
		{ name = "reload"},
	}
	language.Add( "tool.gmpermaworld.left", "Left click to make an entity persistent and add to the database." )
	language.Add( "tool.gmpermaworld.right", "Right click to make entity no-longer persistent and remove it from the database." )
	language.Add( "tool.gmpermaworld.reload", "Reload to load/refresh all persistent entities from database." )
	
	function TOOL.BuildCPanel( panel )	
		panel:AddControl("Header", { Text = "GMPermaWorld" })
		panel:AddControl("Label", {Text = "Reload/refresh persistent entities for any reason:"})
		panel:AddControl("Button", {
			Label = "Restore World",
			Command = "PermaWorld_Restore"
		})
		panel:AddControl("Label", {Text = "Remove all persistent world entities from the map:"})
		panel:AddControl("Button", {
			Label = "Clean Map",
			Command = "PermaWorld_CleanMap"
		})
		panel:AddControl("Label", {Text = "Purge the persistent world database of all entities:"})
		panel:AddControl("Button", {
			Label = "Purge Database",
			Command = "PermaWorldTool_Confirm PermaWorld_Purge"
		})
		panel:AddControl("Checkbox", {
			Label = "Clean map of persistent entities after purging database.",
			Command = "PermaWorldTool_ToggleClean"
		})
	end
	local CleanAfterPurge = true
	local function PermaWorld_Confirm(ply, cmd, args)
		if ( !args or !args[1] ) or ( !ply or !IsValid(ply) ) then return end
		if (ply and !ply:IsSuperAdmin()) then return end
		Derma_Query( "Are you sure you want to purge the database?\nThis action cannot be undone.", "Warning! Please confirm purge.", 
		"Purge Database", function ()
			ply:ConCommand( tostring(args[1]) )
			if CleanAfterPurge then
				ply:ConCommand( "PermaWorld_CleanMap" )
			end
		end, "Cancel", function() return end )
	end
	concommand.Add("PermaWorldTool_Confirm", PermaWorld_Confirm)
	local function PermaWorld_ToggleClean(ply, cmd, args)
		if ( !args or !args[1] ) or ( !ply or !IsValid(ply) ) then return end
		if (ply and !ply:IsSuperAdmin()) then return end
		if tonumber(args[1]) == 1 then
			CleanAfterPurge = true
		else
			CleanAfterPurge = false
		end
	end
	concommand.Add("PermaWorldTool_ToggleClean", PermaWorld_ToggleClean)
end

if ( CLIENT ) then return end

function TOOL:LeftClick( trace )
	local ent = trace.Entity or false
	local ply = self:GetOwner() or false
	if ( !ent or !IsValid(ent) ) or ( !ply or !IsValid(ply) ) then return false end
	if !ply:IsSuperAdmin() then ply:ChatPrint( "You need to be a SuperAdmin to use this tool." ) return false end
	ply:ConCommand( "PermaWorld_Add" )
	return true
end

function TOOL:RightClick( trace )
	local ent = trace.Entity or false
	local ply = self:GetOwner() or false
	if ( !ent or !IsValid(ent) ) or ( !ply or !IsValid(ply) ) then return false end
	if !ply:IsSuperAdmin() then ply:ChatPrint( "You need to be a SuperAdmin to use this tool." ) return false end
	ply:ConCommand( "PermaWorld_Remove" )
	return true
end

function TOOL:Reload()
	local ply = self:GetOwner() or false
	if ( !ply or !IsValid(ply) ) then return false end
	if !ply:IsSuperAdmin() then ply:ChatPrint( "You need to be a SuperAdmin to use this tool." ) return false end
	ply:ConCommand( "PermaWorld_Restore" )
	return false
end

