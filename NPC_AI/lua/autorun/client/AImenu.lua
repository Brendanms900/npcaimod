//File version 1.0
local function Build( panel )
  panel:AddControl( "Label", {Text = "NPC AI addon Settings"})
  panel:AddControl( "CheckBox", { Label = "Activate/Disable AI", Command = "NPC_ai" })
  panel:AddControl( "CheckBox", { Label = "Reuse Array", Command = "NPC_ai_Reuse" })
  panel:AddControl( "CheckBox", { Label = "Friendly fire on NPCs", Command = "NPC_ai_Turn" })
  panel:AddControl( "Slider", { Label = "Next Think Time", Type	= "Float",Command = "NPC_ai_ChaseThink", min = 0.1, max = 1 })
  panel:AddControl( "Label", {Text = "NPC Features"})
  panel:AddControl( "CheckBox", { Label = "Allow Metro Police Manhacks", Command = "NPC_ai_Manh" })
  panel:AddControl( "Slider", { Label = "Amount of Manhacks", Command = "NPC_ai_ManhA", min = 1, max = 10 })
  panel:AddControl( "CheckBox", { Label = "Allow Grenades", Command = "NPC_ai_Grenades" })
  panel:AddControl( "Slider", { Label = "Amount of Grenades", Command = "NPC_ai_GrenadesA", min = 1, max = 10 })
  panel:AddControl( "Label", {Text = "NPC Squads"})
  panel:AddControl( "CheckBox", { Label = "Allow Players to be Squad Leaders", Command = "NPC_ai_SquadsP" })
  panel:AddControl( "CheckBox", { Label = "Allow Squads", Command = "NPC_ai_Squads" })
  panel:AddControl( "Slider", { Label = "Max Members of a Squad", Command = "NPC_ai_SquadsA", min = 1, max = 10 })
  panel:AddControl( "Slider", { Label = "Max Join Distance", Command = "NPC_ai_SquadsJ", min = 50, max = 2000 })
  panel:AddControl( "Slider", { Label = "Max Follow Distance", Command = "NPC_ai_SquadsF", min = 500, max = 2000 })
  end

function ServerAI()
  spawnmenu.AddToolMenuOption( "Utilities", "AI", "NPC's AI Options", "NPC's AI Options", "", "", Build, {} )
end
hook.Add( "PopulateToolMenu", "AI_menu", ServerAI )