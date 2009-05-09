/*NPC AI MOD
BY: TB
File version 1.2*/
CreateConVar( "NPC_ai", "1", { FCVAR_NOTIFY, FCVAR_ARCHIVE } ) 
CreateConVar( "NPC_ai_Reuse", "1", { FCVAR_NOTIFY, FCVAR_ARCHIVE } )
CreateConVar( "NPC_ai_Turn", "1", { FCVAR_NOTIFY, FCVAR_ARCHIVE } )
CreateConVar( "NPC_ai_Manh", "0", { FCVAR_NOTIFY, FCVAR_ARCHIVE } )
CreateConVar( "NPC_ai_Grenades", "1", { FCVAR_NOTIFY, FCVAR_ARCHIVE } )
CreateConVar( "NPC_ai_ManhA", "2", { FCVAR_NOTIFY, FCVAR_ARCHIVE } )
CreateConVar( "NPC_ai_GrenadesA", "5", { FCVAR_NOTIFY, FCVAR_ARCHIVE } )
CreateConVar( "NPC_ai_SquadsA", "5", { FCVAR_NOTIFY, FCVAR_ARCHIVE } )
CreateConVar( "NPC_ai_Squads", "1", { FCVAR_NOTIFY, FCVAR_ARCHIVE } )
CreateConVar( "NPC_ai_SquadsP", "1", { FCVAR_NOTIFY, FCVAR_ARCHIVE } )
CreateConVar( "NPC_ai_SquadsJ", "1500", { FCVAR_NOTIFY, FCVAR_ARCHIVE } )
CreateConVar( "NPC_ai_SquadsF", "500", { FCVAR_NOTIFY, FCVAR_ARCHIVE } )
CreateConVar( "NPC_ai_ChaseThink", "0.3", { FCVAR_NOTIFY, FCVAR_ARCHIVE } )
//my attempt at something faster then findinsphere
local everything={}
local amount=1

local Squads = {}
local SquadsA = 0

function OnEntityCreated2( spawned )

if spawned:IsNPC() && spawned:IsValid() then
if GetConVar( "NPC_ai_Manh" ):GetBool() then
if spawned:GetClass()=="npc_metropolice" then//take out the edit out marks if you want them to have manhacks
spawned:SetKeyValue("manhacks" , GetConVarNumber("NPC_ai_ManhA"))//gives the metro police manhacks
end
end

if GetConVar( "NPC_ai_Grenades" ):GetBool() then
if spawned:GetClass()=="npc_combine_s" then
spawned:SetKeyValue("NumGrenades" , GetConVarNumber("NPC_ai_GrenadesA"))    // gives the combine grenades and ar2 combine balls to shoot
end
end

spawned.wep=nil
spawned.distance=1500
spawned.division=500
spawned.Squad=nil
spawned.IsM=false
spawned.IsL=false
spawned.times=1
spawned.hits=0
spawned.blocked=false
if spawned:GetClass()=="npc_fastzombie"||spawned:GetClass()=="npc_antlion" || spawned:GetClass()=="npc_antlion_worker" then
spawned.walkover=1000
else
spawned.walkover=17
end
if GetConVar( "NPC_ai_Reuse" ):GetBool() then
local found=false
for i=0, amount do
if found==false then
local e=everything[i]
if e==nil||e:IsValid()==false then
everything[i]=spawned
found=true
end
if e!=nil && i==amount then
if e:IsValid() then
amount=amount+1
everything[amount]=spawned
found=true
end
end
end
end
else
amount=amount+1
everything[amount]=spawned
end
	end
end

function Move(v, enemy, finalpos)
//Gather where our npc should move in chunks of 500 or based on a number i gave them  
//They can only move in a distance of 500 or less at a time
local divx=math.abs(v:GetPos().x-enemy:GetPos().x)
local divy=math.abs(v:GetPos().y-enemy:GetPos().y)
local perc=v.division/finalpos
xstep=divx*perc
ystep=divy*perc          
local action=SCHED_FORCED_GO_RUN
//Make sure were in the right plane
local px=1
local py=1
if (enemy:GetPos().x-v:GetPos().x)<0 && xstep!=nil then
xstep=xstep*-1
px=px*-1
end
if (enemy:GetPos().y-v:GetPos().y)<0 && ystep!=nil then
ystep= ystep*-1
py=py*-1
end
if xstep!=nil && ystep!=nil then

//Set the Coordinate where the npc will be going
local cordx=v:GetPos().x+xstep
local cordy=v:GetPos().y+ystep
local tracedata = {}
tracedata.start = Vector(v:GetPos().x, v:GetPos().y, v:GetPos().z+v.walkover)
tracedata.endpos = Vector(cordx,cordy,v:GetPos().z+v.walkover)
tracedata.filter = v
tracedata.mins = v:OBBMins()
tracedata.maxs = v:OBBMaxs()
local trace = util.TraceHull(tracedata)
local search = trace.Entity
if search!=NULL || search:IsWorld() || v.blocked==true then
v.blocked=true
local move = v:OBBMaxs()*v.times
local right1 = v:GetRight().x*move
local right2 = v:GetRight().y*move
local left1 = v:GetRight().x*move*-1
local left2 = v:GetRight().y*move*-1
if v.blocked==true then
local tracedata2 = {}
tracedata2.start = Vector(v:GetPos().x+right1.x, v:GetPos().y+right2.y, v:GetPos().z+v.walkover)
tracedata2.endpos = Vector(enemy:GetPos().x, enemy:GetPos().y, v:GetPos().z+v.walkover)
tracedata2.filter = enemy
tracedata2.mins = v:OBBMins()
tracedata2.maxs = v:OBBMaxs()
local trace2 = util.TraceHull(tracedata2)
local search2 = trace2.Entity

local tracedata3 = {}
tracedata3.start = Vector(v:GetPos().x+left1.x, v:GetPos().y+left2.y , v:GetPos().z+v.walkover)
tracedata3.endpos = Vector(enemy:GetPos().x, enemy:GetPos().y, v:GetPos().z+v.walkover)
tracedata3.filter = enemy
tracedata3.mins = v:OBBMins()
tracedata3.maxs = v:OBBMaxs()
local trace3 = util.TraceHull(tracedata3)
local search3 = trace3.Entity

if search2==NULL then
v:SetLastPosition( Vector(v:GetPos().x+right1.x, v:GetPos().y+right2.y, v:GetPos().z))
v:SetSchedule( action )
v.blocked=false
v.times=1
return
end
if search3==NULL then
v:SetLastPosition( Vector(v:GetPos().x+left1.x, v:GetPos().y+left2.y, v:GetPos().z))
v:SetSchedule( action )
v.blocked=false
v.times=1
return
end
v.times=v.times+1
end
else
end

if v:GetClass()!="npc_manhack" then
if v.blocked==false then
v:SetLastPosition( Vector(cordx,cordy,v:GetPos().z))
v:SetSchedule( action )
end
else 
v:SetLastPosition( Vector(cordx,cordy,enemy:GetPos().z+5))
v:SetSchedule( action )
end

end
end

function EntityTakeDamage2( ent, inflictor, attacker, amount )
if GetConVar( "NPC_ai_Turn" ):GetBool()  then
//make friendlys turn against you if you shoot at them
	if inflictor:IsPlayer()&& ent:IsNPC() && ent:Disposition(inflictor)!=1 && ent.hits!=nil then
	ent.hits=ent.hits+1
		if ent.hits>=3 then
		ent:AddEntityRelationship(inflictor, 1, 99)
		end       
	end
end
end

function PlayerInitialSpawn2( ply )
amount=amount+1
everything[amount]=ply
if GetConVar("NPC_ai_SquadsP"):GetBool() then
SquadsA =SquadsA +1
Squads[SquadsA]=ply
ply.Squad=Squads[SquadsA]
ply.IsL =true 
Squads[SquadsA].L=ply
ply.Squad=SquadsA
Squads[SquadsA].A=1
Squads[SquadsA].A2=1
Squads[SquadsA].M={}
Squads[SquadsA].M[Squads[SquadsA].A]=ply
end
end

function Removed(npc)
if GetConVar( "NPC_ai_Squads" ):GetBool() then
if npc:IsNPC() then
if npc.Squad!=nil then
Squads[npc.Squad].A2=Squads[npc.Squad].A2-1
end
if npc.IsL then
local found=false
for i,e in pairs(Squads[npc.Squad].M) do
if e:IsValid() then
if e!=npc then
if found==true then
Squads[e.Squad].A=Squads[e.Squad].A+1
Squads[e.Squad].A2=Squads[e.Squad].A2+1
Squads[e.Squad].M[Squads[e.Squad].A]=e
end
if found==false then
Squads[npc.Squad]=e
Squads[npc.Squad].L=e
Squads[e.Squad].A=1
Squads[e.Squad].A2=1
Squads[e.Squad].M={}
Squads[e.Squad].M[Squads[e.Squad].A]=e
e.IsL=true
e.IsM=false
found=true
end
end
end
end
end
end
end
end

hook.Add( "OnEntityCreated", "npcspawn123", OnEntityCreated2 )
hook.Add( "EntityTakeDamage", "npcdmg123", EntityTakeDamage2 )
hook.Add( "PlayerInitialSpawn", "addplayer123", PlayerInitialSpawn2 )
hook.Add( "EntityRemoved", "Removed123", Removed )

local nextthink=0
 hook.Add("Think","NPCAI",
function() 
if CurTime()>=nextthink then
if GetConVar( "NPC_ai" ):GetBool() then
for k, v in pairs(ents.FindByClass("npc_*")) do
if v:IsNPC()&& v:IsValid() && v:GetClass()!="npc_rollermine"  then //this script makes rollermines buggy this fixs it


local friend=0
local finalpos=0
local enemy
if GetConVar( "NPC_ai_Squads" ):GetBool() then
if v.Squad==nil && v:GetClass()!="npc_manhack" then
for i,e in pairs(everything) do
if e:IsValid() then
if e:IsNPC()&&e!=v||e:IsPlayer()&& GetConVar( "NPC_ai_SquadsP" ):GetBool()then
if  v:Disposition(e)!=1 then
friend=math.abs(v:GetPos().x-e:GetPos().x)+math.abs(v:GetPos().y-e:GetPos().y)+math.abs(v:GetPos().z-e:GetPos().z) 
if friend<=GetConVarNumber("NPC_ai_SquadsJ") then

if e.Squad==nil && v.Squad==nil then
SquadsA =SquadsA +1
Squads[SquadsA]=v 
v.Squad=Squads[SquadsA]
v.IsL =true 
Squads[SquadsA].L=v
v.Squad=SquadsA
Squads[SquadsA].A=1
Squads[SquadsA].A2=1
Squads[SquadsA].M={}
Squads[SquadsA].M[Squads[SquadsA].A]=v
end

if e.IsL && v.Squad==nil && Squads[e.Squad].A2<GetConVarNumber("NPC_ai_SquadsA") then
v.Squad=e.Squad
Squads[e.Squad].A=Squads[e.Squad].A +1
Squads[e.Squad].A2=Squads[e.Squad].A2+1
v.IsM = true
Squads[e.Squad].M[Squads[e.Squad].A]=v
finalpos=friend
end

end
end
end
end
end
end

if v.IsM==true then

if v.wep!="squad" then
v.wep="squad"
v.distance=GetConVarNumber("NPC_ai_SquadsF") 
v.division=500
end
if Squads[v.Squad].L!=nil then
enemy = Squads[v.Squad].L
end
if enemy!=nil then
finalpos=math.abs(v:GetPos().x-enemy:GetPos().x)+math.abs(v:GetPos().y-enemy:GetPos().y)+math.abs(v:GetPos().z-enemy:GetPos().z) 
if finalpos >= v.distance then
Move(v, enemy, finalpos)
end
end

end
end

if v:GetEnemy()!=nil && !v.IsM then

if v.wep==nil && !v.IsM then
if v:GetActiveWeapon():IsValid() then
v.wep=v:GetActiveWeapon():GetClass()
	if v.wep=="weapon_crowbar" || v.wep=="weapon_stunstick" then //add npc melee weapons here for them to work
	v.distance=200
	v.division=200
	v.wep="melee"
	end
	
	if v.wep=="weapon_shotgun" then //add npc short range weapons here for them to work
	v.distance=400
	v.division=200
	end

if v.wep=="weapon_rpg" then //add npc short range weapons here for them to work
v.distance=1600
v.division=350
end
end
	if !v:GetActiveWeapon():IsValid() then //NPC's without a weapon
		if v:IsValid() then
		if v:GetClass()=="npc_fastzombie"  then
		v.wep="melee"
		v.distance=450
		v.division=200
		else
		if v:GetClass()=="npc_antlion" then
		v.wep="melee"
		v.distance=600
		v.division=200
		else
		if v:GetClass()=="npc_hunter" then
		v.wep="hunter"
		v.distance=1200
		v.division=200
		else
if v:GetClass()=="npc_antlionguard" then
v.wep="melee"
v.distance=900
v.division=200
else
		if v:GetClass()=="npc_antlion_worker" then
		v.wep="hunter"
		v.distance=1200
		v.division=200
		else
		v.wep="melee"
		v.distance=200
		v.division=200
		end
		end 
		end
		end
		end
end
	end
end

local enemy2
enemy=v:GetEnemy()
local pos1=v:GetPos()  
local pos2=enemy:GetPos()  
local x=pos1.x-pos2.x
local y=pos1.y-pos2.y
local z=pos1.z-pos2.z 
//Distance From the enemy
finalpos=math.abs(x)+math.abs(y)+math.abs(z)
        
//Checks if they should change to a closer target within recognize range
for i,e in pairs(everything) do
	if e:IsValid() then
		if e:IsPlayer()&&!GetConVar( "ai_ignoreplayers" ):GetBool()||e:IsNPC() then	
	if e!=enemy && e!=v then

				if v:Disposition(e)==1 then
				enemy2=math.abs(v:GetPos().x-e:GetPos().x)+math.abs(v:GetPos().y-e:GetPos().y)+math.abs(v:GetPos().z-e:GetPos().z) 
					if enemy2<finalpos then
					enemy=e
					finalpos=enemy2
					end
				end     
			end
		end 
	end
end

//If their enemy is outside there recognize range follow them
if finalpos >= v.distance then
Move(v, enemy, finalpos)
end

end
end
end
end
nextthink=CurTime()+GetConVarNumber("NPC_ai_ChaseThink")
end
end)
Msg("NPCAI mod has been started\n")
