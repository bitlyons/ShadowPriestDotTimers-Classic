-- Author      : Kressilac /Duskwood
-- UI elements borrowed from Shadow Timer and extended for better use.
-- Create Date : 10/5/2011 6pm

ShadowPriestDoTTimerFrame_Default_X = 0
ShadowPriestDoTTimerFrame_Default_Y = 0
ShadowPriestDoTTimerFrame_Default_Size = 100
ShadowPriestDoTTimerFrame_Default_Scale = 1

MyAddon_UpdateInterval = 0.05; -- How often the OnUpdate code will run (in seconds)

WarningTime = 600; -- WarningTime (in milliseconds)
local buffscorecurrent = 0


--Used to keep track of the DoTs on a Mob.
local moblist = {}
local isincombat = false;
local currentmob = nil;
local maxmoblist = 10;

----------------------------------------------
local nameWordPain, rankWordPain, IconWordPain = GetSpellInfo(589);
--"Interface\\ICONS\\Spell_Shadow_ShadowWordPain.blp";
----------------------------------------------
local VTID = 34914
local nameVT, rankVT, IconVT, castTimeVT, minRangeVT, maxRangeVT = GetSpellInfo(VTID)	
--"Interface\\ICONS\\Spell_Holy_Stoicism.blp";
----------------------------------------------
local PlagueID = 2944
local namePlague, rankPlague, IconPlague = GetSpellInfo(PlagueID);
--"Interface\\ICONS\\Spell_Shadow_DevouringPlague.blp";
----------------------------------------------
local nameShadowOrbs, rankShadowOrbs, IconShadowOrbs = GetSpellInfo(77487);	
--"Interface\\ICONS\\spell_priest_shadoworbs.blp";
----------------------------------------------
local nameEmpShadow, rankEmpShadow, IconEmpShadow = GetSpellInfo(95799);
--"Interface\\ICONS\\inv_chaos_orb.blp";
----------------------------------------------
local MindBlastID = 8092;
local nameMindBlast, rankMindBlast, IconMindBlast = GetSpellInfo(MindBlastID);
----------------------------------------------
local nameDarkEvan, rankDarkEvan, IconDarkEvan = GetSpellInfo(87118);
--"Interface\\ICONS\\spell_holy_divineillumination.blp";
----------------------------------------------
local DarkArchangelID = 87153;
local nameArchangel, rankArchangel, IconArchangel = GetSpellInfo(DarkArchangelID);

function round(num) 
    if num >= 0 then return math.floor(num+.5) 
    else return math.ceil(num-.5) end
end

function ShadowPriestDoTTimerFrame_OnLoad(self)
	ShadowPriestDoTTimerFrame:RegisterEvent("PLAYER_LOGOUT");
	ShadowPriestDoTTimerFrame:RegisterEvent("ADDON_LOADED");
	ShadowPriestDoTTimerFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
	ShadowPriestDoTTimerFrame:RegisterEvent("PLAYER_REGEN_ENABLED");
	ShadowPriestDoTTimerFrame:RegisterEvent("PLAYER_REGEN_DISABLED");
	ShadowPriestDoTTimerFrame:RegisterEvent("PLAYER_TALENT_UPDATE");
	ShadowPriestDoTTimerFrame:RegisterEvent("PLAYER_ENTERING_WORLD");

	SPDT_SWP_Texture:SetTexture(IconWordPain);
	SPDT_DP_Texture:SetTexture(IconPlague);
	SPDT_VT_Texture:SetTexture(IconVT);
	SPDT_MB_Texture:SetTexture(IconMindBlast);
	SPDT_ORB_Texture:SetTexture(IconShadowOrbs);
	SPDT_DE_Texture:SetTexture(IconDarkEvan);
	SPDT_Archangel_Texture:SetTexture(IconArchangel);
	
	SPDT_VT_Texture:Hide();
	SPDT_DP_Texture:Hide();
	SPDT_SWP_Texture:Hide();
	Texture4:Hide();
	TEXT4_BUFFSCORE:Show();
	TEXT5_MB:Hide();
	SPDT_MB_Texture:Hide();
	SPDT_ORB_Texture:Hide();
	SPDT_DE_Texture:Hide();
	SPDT_Archangel_Texture:Hide();
	TEXT1_VT_Above:Show();
	TEXT2_DP_Above:Show();
	
	TimeSinceLastUpdate = 0

	ShadowPriestDoTTimerFrame:RegisterForDrag("LeftButton", "RightButton");
	ShadowPriestDoTTimerFrame:EnableMouse(false);
	
end

function ShadowPriestDoTTimerFrame_OnUpdate(elapsed)
	TimeSinceLastUpdate = TimeSinceLastUpdate + elapsed; 	
	while (TimeSinceLastUpdate > MyAddon_UpdateInterval) do
		CheckCurrentTargetDeBuffs();
		CheckPlayerBuffs();

		if (buffscorecurrent > 0) then
			TEXT4_BUFFSCORE:SetText(string.format("%d", buffscorecurrent));
			TEXT4_BUFFSCORE:Show();
		else
			TEXT4_BUFFSCORE:Hide();
		end
		TimeSinceLastUpdate = TimeSinceLastUpdate - MyAddon_UpdateInterval;
	end
end

function ShadowPriestDoTTimerFrame_OnEvent(self, event, ...)
	local arg1 = ...;

	if (event == "UNIT_SPELLCAST_SUCCEEDED") then
		local unit, _, spellid = ...;
		if (unit == "player") then
			if (spellid == VTID) then
				TEXT1_VT_Above:Show();
				TEXT1_VT_Above:SetText(string.format("%d", buffscorecurrent));

				FindOrCreateCurrentMob();
				if (currentmob) then
					currentmob[2] = buffscorecurrent;
					currentmob[4] = GetTime();
				end
			elseif (spellid == PlagueID) then
				TEXT2_DP_Above:Show();
				TEXT2_DP_Above:SetText(string.format("%d", buffscorecurrent));

				FindOrCreateCurrentMob();
				if (currentmob) then
					currentmob[3] = buffscorecurrent;
					currentmob[4] = GetTime();
				end
			end
		end
	elseif (event == "ADDON_LOADED" and arg1 == "ShadowPriestDotTimer") then
 		if (not ShadowPriestDoTTimerFrameScaleFrame) then
			ShadowPriestDoTTimerFrameScaleFrame = 1.0
		end
		
		SPDT_POPUP:Hide();
		ShadowPriestDoTTimerFrame:SetScale(ShadowPriestDoTTimerFrameScaleFrame);
		SetCooldownOffsets();
		checkIfShadow();
	elseif (event == "PLAYER_ENTERING_WORLD") then
		checkIfShadow();
		self:UnregisterEvent('PLAYER_ENTERING_WORLD')

	elseif (event == "PLAYER_LOGOUT") then
		ShadowPriestDoTTimerFrameScaleFrame = ShadowPriestDoTTimerFrame:GetScale();
		point, relativeTo, relativePoint, xOffset, yOffset = self:GetPoint(1);
		ShadowPriestDoTTimerxPosiFrame = xOffset;
	
	elseif (event == "PLAYER_TALENT_UPDATE") then  --when spec is changed
		checkIfShadow();
	
	elseif (event == "PLAYER_REGEN_ENABLED") then
		if (maxmoblist < #moblist) then
			--DP and VT don't last more than a minute so once we've been ooc for a minute, clear up the list.
			for i = 1, #moblist do
				if (moblist[i][4]-GetTime() > 60000 and moblist[i][1] ~= currentmob[1]) then
					table.remove(moblist, i);
				end
			end
		end
		isincombat = false;
	elseif (event == "PLAYER_REGEN_DISABLED") then
		isincombat = true;
	end
end

function SetCooldownOffsets()
	point, relativeTo, relativePoint, xOfs, yOfs = TEXT1_VT_:GetPoint();
	TEXT1_VT_:SetPoint(point, relativeTo, relativePoint, xOfs, CooldownOffset);
	point, relativeTo, relativePoint, xOfs, yOfs = TEXT2_DP_:GetPoint();
	TEXT2_DP_:SetPoint(point, relativeTo, relativePoint, xOfs, CooldownOffset);
	point, relativeTo, relativePoint, xOfs, yOfs = TEXT3_SWP:GetPoint();
	TEXT3_SWP:SetPoint(point, relativeTo, relativePoint, xOfs, CooldownOffset);
	point, relativeTo, relativePoint, xOfs, yOfs = TEXT5_MB:GetPoint();
	TEXT5_MB:SetPoint(point, relativeTo, relativePoint, xOfs, CooldownOffset);
	point, relativeTo, relativePoint, xOfs, yOfs = TEXT6:GetPoint();
	TEXT6:SetPoint(point, relativeTo, relativePoint, xOfs, CooldownOffset);
	point, relativeTo, relativePoint, xOfs, yOfs = TEXT7:GetPoint();
	TEXT7:SetPoint(point, relativeTo, relativePoint, xOfs, CooldownOffset);
	point, relativeTo, relativePoint, xOfs, yOfs = TEXT8:GetPoint();
	TEXT8:SetPoint(point, relativeTo, relativePoint, xOfs, CooldownOffset);
end

function FindCurrentMob()
	local targetguid = UnitGUID("playertarget");
	currentmob = nil;
	if (targetguid) then
		local i = 1;
		while not currentmob and i <= #moblist do
			if (moblist[i][1] == targetguid) then
				currentmob = moblist[i];
			end
			i = i + 1;
		end
	end
end

function FindOrCreateCurrentMob()
	local targetguid = UnitGUID("playertarget");
	currentmob = nil;

	if (targetguid) then
		--DEFAULT_CHAT_FRAME:AddMessage("SPDT Player Target: " .. targetguid);
		local i = 1;
		while not currentmob and i <= #moblist do
			if (moblist[i][1] == targetguid) then
				currentmob = moblist[i];
			end
			i = i + 1;
		end

		if (not currentmob) then
			currentmob = {targetguid, 0, 0, GetTime()};
			table.insert(moblist, currentmob);
			--DEFAULT_CHAT_FRAME:AddMessage("SPDT New mob: " .. currentmob[1]);
		else
			--DEFAULT_CHAT_FRAME:AddMessage("SPDT Found mob: " .. currentmob[1]);
		end
	end
end

function ClearMobList()
	for i = 1, #moblist do
		table.remove(moblist, i);
	end
	currentmob = nil;
end

function CheckCurrentTargetDeBuffs()
	local finished = false
	local count = 0
	local VTFound = 0
	local VTLeft = 0
	local VTlefttime = 0
	local VTlasttickTime = 0
	local VTlasttickcastTime = 0
	local VTleftMS = 0
	local PlagueFound = 0
	local PlagueLeft = 0
	local PlaguelasttickTime = 0
	local PlaguelasttickCastTime = 0
	local WordPainFound = 0
	local WordPainLeft = 0
	local CastTime = 0

	PseudoGCD = castTimeVT
	PseudoGCD2 = castTimeVT*2
	PseudoGCDWarn = castTimeVT+WarningTime
	VTlasttickTime = castTimeVT*3+WarningTime 
	VTlasttickcastTime = castTimeVT*3 
	PlaguelasttickTime = castTimeVT*2+WarningTime
	PlaguelasttickCastTime = castTimeVT*2  

	while not finished do
		count = count+1

		local bn,bicon,bcount,bType,bduration,bexpirationTime,bisMine,bisStealable,bshouldConsolidate,bspellId =  UnitDebuff("target", count, 0)
		if not bn then
			finished = true
		else
			--DEFAULT_CHAT_FRAME:AddMessage("testing debuff");
			if bisMine == "player" then
				--DEFAULT_CHAT_FRAME:AddMessage("ismine debuff");
				
				if bn == nameVT then 
					VTFound = 1 
					VTlefttime = floor((((bexpirationTime-GetTime())*10)+ 0.5))/10	
					
					if(VTlefttime <= 5.0) then				
						VTLeft = string.format("%1.1f",VTlefttime);
					else
						VTLeft = string.format("%d",VTlefttime);
					end			
										
					VTleftMS = VTlefttime*1000
					CastTime = castTimeVT	
					--VTleftMSSafe = VTleftMS-WarningTime
					VTduration = bduration;
				end
				if bn == namePlague then 
					PlagueFound = 1
					Plaguelefttime = floor((((bexpirationTime-GetTime())*10)+ 0.5))/10	
					
					if(Plaguelefttime <= 5.0) then				
						PlagueLeft = string.format("%1.1f",Plaguelefttime);
					else
						PlagueLeft = string.format("%d",Plaguelefttime);
					end		
				
					PlagueleftMS = Plaguelefttime*1000
				end
				if bn == nameWordPain then 
					WordPainFound = 1
					WordPainlefttime = floor((((bexpirationTime-GetTime())*10)+ 0.5))/10
					WordPainLeft = string.format("%1.1f",floor((((bexpirationTime-GetTime())*10)+ 0.5))/10)  
				end
			end
		end
	end

	if VTFound == 1 then
		SPDT_VT_Texture:Show()
		if  VTleftMS < VTlasttickTime then
			if VTleftMS < VTlasttickcastTime then
				SPDT_VT_Texture:SetVertexColor(0.1, 0.6, 0.1);
			else 
				SPDT_VT_Texture:SetVertexColor(0.9, 0.2, 0.2);
			end
		else
			SPDT_VT_Texture:SetVertexColor(1.0, 1.0, 1.0);
		end
		TEXT1_VT_Above:Show();

		

		FindCurrentMob();
		if (currentmob) then
			TEXT1_VT_Above:SetText(string.format("%d", currentmob[2]));
		end
		if(ColorDots == true) then
		 	--colour the current buff score based based on if its higher or lower
			if (buffscorecurrent > (currentmob[2])) then
				TEXT1_VT_Above:SetVertexColor(1.0, 0.1, 0.1);	--red 
			elseif (buffscorecurrent < (currentmob[2]) or buffscorecurrent == (currentmob[2])) then
				TEXT1_VT_Above:SetVertexColor(0.1, 0.6, 0.1);	--green
			end
		else
			TEXT1_VT_Above:SetVertexColor(1.0, 0.9, 0.1);	--yellow
		end
		

		TEXT1_VT_:SetText(VTLeft);
		TEXT1_VT_:Show();
	else
		TEXT1_VT_Above:Hide();
		TEXT1_VT_:Hide();
		SPDT_VT_Texture:Hide();
	end

	if PlagueFound == 1 then
		SPDT_DP_Texture:Show();
		if  PlagueleftMS < PlaguelasttickTime then
			if PlagueleftMS < PlaguelasttickCastTime  then
				SPDT_DP_Texture:SetVertexColor(0.1, 0.6, 0.1);
			else 
				SPDT_DP_Texture:SetVertexColor(0.9, 0.2, 0.2);
			end
		else
			SPDT_DP_Texture:SetVertexColor(1.0, 1.0, 1.0);
		end
		TEXT2_DP_Above:Show();

		FindCurrentMob();
		if (currentmob) then
			TEXT2_DP_Above:SetText(string.format("%d", currentmob[3]));
		end

		if(ColorDots == true) then
		 	if (buffscorecurrent > (currentmob[3])) then
				TEXT2_DP_Above:SetVertexColor(1.0, 0.1, 0.1);	--red 
			elseif (buffscorecurrent < (currentmob[3]) or buffscorecurrent == (currentmob[3])) then
				TEXT2_DP_Above:SetVertexColor(0.1, 0.6, 0.1);	--green
			end
		else
			TEXT2_DP_Above:SetVertexColor(1.0, 0.9, 0.1);	--yellow
		end

		TEXT2_DP_:SetText(PlagueLeft);
		TEXT2_DP_:Show();	
	else
		TEXT2_DP_Above:Hide();
		SPDT_DP_Texture:Hide();
		TEXT2_DP_:Hide();
	end

	if WordPainFound == 1 then
		SPDT_SWP_Texture:Show();
		TEXT3_SWP:SetText(WordPainLeft);
		TEXT3_SWP:Show();
	else
		SPDT_SWP_Texture:Hide();
		TEXT3_SWP:Hide();
	end

return 
end

function CheckPlayerBuffs()
	local finished = false;
	local count = 0;
	local ShadowOrbsFound = 0;
	local ShadowOrbsStacks = 0;
	local ShadowOrbsLeft = 0;
	local EmpShadowFound = 0;
	local EmpShadowLeft = 0;
	local DarkEvanFound = 0;
	local DarkEvanStacks = 0;
	local DarkEvanLeft = 0;
	local AAFound = 0;
	local AALeft = 0;
	local MBLeft = 0;

	buffscorecurrent = 0;
	savedbuffscorecurrent = 0;
	local base, stat, posBuff, negBuff = UnitStat("player",4);

	while not finished do
		count = count+1;
		local bn,bicon,bcount,bType,bduration,bexpirationTime,bisMine,bisStealable,bshouldConsolidate,bspellId =  UnitBuff("player", count, 0);

		local modifiedint = base + buffscorecurrent;
		
		if not bn then
			finished = true;
		else
			if bn == nameShadowOrbs then
				ShadowOrbsFound	= 1;
				ShadowOrbsStacks	= bcount;
				ShadowOrbsLeft	= string.format("%1.1f",floor((((bexpirationTime-GetTime())*10)+ 0.5))/10);
			end
			if bn == nameEmpShadow then
				EmpShadowFound	= 1;
				EmpShadowLeft	= string.format("%1.1f",floor((((bexpirationTime-GetTime())*10)+ 0.5))/10); 
			end	
			if bn == nameDarkEvan then 
				DarkEvanFound	= 1;
              	DarkEvanStacks	= bcount;
				DarkEvanLeft	= string.format("%1.1f",floor((((bexpirationTime-GetTime())*10)+ 0.5))/10);  
			end
			if (bn == nameArchangel) then
				AAFound			= 1;
				AALeft			= string.format("%1.1f",floor((((bexpirationTime-GetTime())*10)+ 0.5))/10);
			end

			-------------------------------------
			--loop the buffs in the list until we find a match.
			found = false;
			i = 1;
			while found == false and i <= #BuffList do
				local entry = BuffList[i];
				if (entry) then
					if (bn == entry[1]) then
						found = true;

						if (bcount <= 0) then
							bcount = entry[4];
						end

						if (string.lower(entry[2]) == "int") then
							buffscorecurrent = buffscorecurrent + (entry[3] * bcount);
						elseif (string.lower(entry[2]) == "mastery") then
							buffscorecurrent = buffscorecurrent + (entry[3] * bcount * MasteryWeight);
						elseif (string.lower(entry[2]) == "crit") then
							buffscorecurrent = buffscorecurrent + (entry[3] * bcount * CritWeight);
						elseif (string.lower(entry[2]) == "haste") then
							buffscorecurrent = buffscorecurrent + (entry[3] * bcount * HasteWeight);
						elseif (string.lower(entry[2]) == "damage") then
							buffscorecurrent = buffscorecurrent + (entry[3] * bcount * modifiedint * DamageWeight);
						elseif (string.lower(entry[2]) == "spellpower") then
							buffscorecurrent = buffscorecurrent + (entry[3] * bcount * SpellpowerWeight);
						end
					end
				end

				i = i + 1;
			end
			------------------------------------------
			-- loop class buffs list until we find a match.
			found1 = false;
			j = 1;
			while found1 == false and j <= #ClassBuffList do
				local entry1 = ClassBuffList[j];
				if (entry1) then
					if (bspellId == entry1[1]) then
						found1 = true;

						if (bcount <= 0) then
							bcount = entry1[4];
						end

						if (string.lower(entry1[2]) == "int") then
							buffscorecurrent = buffscorecurrent + (entry1[3] * bcount);
						elseif (string.lower(entry1[2]) == "mastery") then
							buffscorecurrent = buffscorecurrent + (entry1[3] * bcount * MasteryWeight);
						elseif (string.lower(entry1[2]) == "crit") then
							buffscorecurrent = buffscorecurrent + (entry1[3] * bcount * CritWeight);
						elseif (string.lower(entry1[2]) == "haste") then
							buffscorecurrent = buffscorecurrent + (entry1[3] * bcount * HasteWeight);
						elseif (string.lower(entry1[2]) == "damage") then
							buffscorecurrent = buffscorecurrent + (entry1[3] * bcount * modifiedint * DamageWeight);
						elseif (string.lower(entry1[2]) == "spellpower") then
							buffscorecurrent = buffscorecurrent + (entry1[3] * bcount * SpellpowerWeight);
						end
					end
				end

				j = j + 1;
			end		

		end
	end
	
	MBstart, MBduration, MBenabled = GetSpellCooldown(MindBlastID);	--MB CD
	MBLeft = MBduration - (floor((((GetTime()-MBstart)*10)+ 0.5))/10);
	if (HideMB == false and MBstart > 0 and MBduration > 1.5) then
		TEXT5_MB:SetText(string.format("%1.1f", MBLeft));
		TEXT5_MB:Show();
		SPDT_MB_Texture:Show();
		-- add a check if always show mindblast is set
		SPDT_MB_Texture:SetDesaturated(true);
		SPDT_MB_Texture:SetAlpha(.5);
	elseif (InCombatLockdown() == false) then
		SPDT_MB_Texture:Hide();
	else
		SPDT_MB_Texture:SetDesaturated(false);
		SPDT_MB_Texture:SetAlpha(1);
		TEXT5_MB:Hide();
	end
	if (MBduration <0.1) then -- added as temp fix
		TEXT5_MB:Hide();
	end

	if (ShadowOrbsFound == 1 and HideOrbs == false) then
		SPDT_ORB_Texture:SetTexture(IconShadowOrbs);
		SPDT_ORB_Texture:Show();
		TEXT6Above:SetText(ShadowOrbsStacks);
		TEXT6Above:Show();	
		
		if (EmpShadowFound == 1) then
			TEXT6:SetText(EmpShadowLeft);
			TEXT6:Show();	
		else
			TEXT6:Hide();
		end

		if ShadowOrbsStacks == 3 then
			if  (MBLeft <= PseudoGCD and MBstart > 0 and MBduration > 1.5) then
				SPDT_ORB_Texture:SetVertexColor(0.1, 0.6, 0.1);		--green
			elseif (MBLeft <= PseudoGCDWarn and MBstart > 0 and MBduration > 1.5) then
				SPDT_ORB_Texture:SetVertexColor(0.9, 0.2, 0.2);		--red
			end
		else								-- not 3 orbs
			SPDT_ORB_Texture:SetVertexColor(1.0, 1.0, 1.0);		--no colour
		end
	elseif (EmpShadowFound == 1 and HideES == false) then
		SPDT_ORB_Texture:SetVertexColor(1.0, 1.0, 1.0);		--no colour
		TEXT6Above:Hide();
		SPDT_ORB_Texture:SetTexture(IconEmpShadow);
		SPDT_ORB_Texture:Show();
		TEXT6:SetText(EmpShadowLeft);
		TEXT6:Show();	
	else
		SPDT_ORB_Texture:Hide();
		TEXT6:Hide();	
		TEXT6Above:Hide();
	end
	
	if (DarkEvanFound == 1 and HideEvangelism == false) then
		SPDT_DE_Texture:Show();
		TEXT7:SetText(DarkEvanLeft);
		TEXT7Above:SetText(DarkEvanStacks);
		TEXT7:Show();
		TEXT7Above:Show();
	else
		SPDT_DE_Texture:Hide();
		TEXT7:Hide();
		TEXT7Above:Hide();
	end

	if (AAFound == 1 and HideAA == false) then
		SPDT_Archangel_Texture:Show();
		TEXT8:SetText(AALeft);
		TEXT8:Show();	
	else
		SPDT_Archangel_Texture:Hide();
		TEXT8:Hide();
	end


return 
end

function checkIfShadow() -- see if shadowform is known
	if (IsSpellKnown(15473) == true) then
		ShadowPriestDoTTimerFrame:Show();
		--DEFAULT_CHAT_FRAME:AddMessage("shadow found");
	else 
		ShadowPriestDoTTimerFrame:Hide();
		--DEFAULT_CHAT_FRAME:AddMessage("shadow not found");
	end
	-- UnitClassBase("player") == "PRIEST"
end
	

SLASH_SHADOWPRIESTDOTTIMER1, SLASH_SHADOWPRIESTDOTTIMER2 = '/spdt', '/ShadowPriestDoTTimer';

local function SLASH_SHADOWPRIESTDOTTIMERhandler(msg, editbox)
	if msg == 'show' then
		ShadowPriestDoTTimerFrame:Show();
	elseif  msg == 'hide' then
		ShadowPriestDoTTimerFrame:Hide();
	elseif  msg == 'reset' then
		ShadowPriestDoTTimerFrame:Hide();
		ShadowPriestDoTTimerFrame:Show();
		ClearMobList();
	elseif  msg == 'clear' then
		ClearMobList();
	elseif  msg == 'lock' then	
		SPDT_POPUP:Hide();
		ShadowPriestDoTTimerFrame:EnableMouse(false);
		ShadowPriestDoTTimerFrame:SetBackdrop(nil);
		SetCooldownOffsets();
		STmode = 1
	elseif  msg == 'move' then
		SPDT_POPUP:Show();
		ShadowPriestDoTTimerFrame:EnableMouse(true);
		ShadowPriestDoTTimerFrame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeFile= "Interface/Tooltips/UI-Tooltip-Border", edgeSize = 4, tile = false, tileSize =16, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
		STmode = 2
	elseif  msg == 'options' or msg =='' then
		Settings.OpenToCategory("SPDT Classic")
	elseif  msg == 'scale1' then
		ShadowPriestDoTTimerScaleFrame = 0.5
		ShadowPriestDoTTimerFrame:SetScale(ShadowPriestDoTTimerScaleFrame);
	elseif  msg == 'scale2' then
		ShadowPriestDoTTimerScaleFrame = 0.6
		ShadowPriestDoTTimerFrame:SetScale(ShadowPriestDoTTimerScaleFrame);
	elseif  msg == 'scale3' then
		ShadowPriestDoTTimerScaleFrame = 0.7
		ShadowPriestDoTTimerFrame:SetScale(ShadowPriestDoTTimerScaleFrame);
	elseif  msg == 'scale4' then
		ShadowPriestDoTTimerScaleFrame = 0.8
		ShadowPriestDoTTimerFrame:SetScale(ShadowPriestDoTTimerScaleFrame);
	elseif  msg == 'scale5' then
		ShadowPriestDoTTimerScaleFrame = 0.9
		ShadowPriestDoTTimerFrame:SetScale(ShadowPriestDoTTimerScaleFrame);
	elseif  msg == 'scale6' then
		ShadowPriestDoTTimerScaleFrame = 1.0
		ShadowPriestDoTTimerFrame:SetScale(ShadowPriestDoTTimerScaleFrame);
	elseif  msg == 'help' then
		print("Syntax: /spdt (show | hide | reset | move | lock | options | clearmoblist )");
		print("Syntax: /spdt (scale1 | scale2 | scale3 | scale4 | scale5 | scale6)");
	else
		print("Syntax: /spdt (show | hide | reset | move | lock | options | clearmoblist )");
		print("Syntax: /spdt (scale1 | scale2 | scale3 | scale4 | scale5 | scale6)");
	end
end

SlashCmdList["SHADOWPRIESTDOTTIMER"] = SLASH_SHADOWPRIESTDOTTIMERhandler;

function lockSPDT()
	ShadowPriestDoTTimerFrame:EnableMouse(false);
	ShadowPriestDoTTimerFrame:SetBackdrop(nil);
	SetCooldownOffsets();
	SPDT_POPUP:Hide();
	STmode = 1
end





