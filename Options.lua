-- Author      : Kressilac - Bathral  - Lyonzy
-- Create Date : 6/9/2024 

local defaultdamageweight = .01
local defaultmasteryweight = .48
local defaultcritweight = .48
local defaulthasteweight = .51
local defaultspellpowerweight = .79
local maxentries = 16 
local defaulthidees = false;
local defaulthideaa = false;
local defaulthideevangelism = false;
local defaulthideorbs = false;
local defaulthidemb = false;
local defaulthidecolor = false;
local defaultcooldownoffset = 0;
local category, layout
local subcategory, subcategoryLayout
local defaultSPDTpdtScale = 6;
local incombatFlag = false

local defaultbufftable = {}

table.insert(defaultbufftable, {"Volcanic Destruction", "Int", 1600, 1}); 	--DMC: volcano
table.insert(defaultbufftable, {"Fiery Quintessence", "Int", 1149, 1});     --Fiery Quintessence
table.insert(defaultbufftable, {"Velocity", "Haste", 3278, 1});				--Insignia of the Corrupted Mind
table.insert(defaultbufftable, {"Soul Fragment", "Mastery", 39, 10});		--Necromantic Focus
table.insert(defaultbufftable, {"Combat Mind", "Int", 88, 10});				--Will of Unbinding
table.insert(defaultbufftable, {"Soul Power","spellpower",1926 ,1});  		--Soul Casket
table.insert(defaultbufftable, {"Witching Hour","Haste",1710 ,1});  		--Witching Hourglass
table.insert(defaultbufftable, {"Jeweled Serpent","spellpower",1425 ,1}); 	--Figurine - Jeweled Serpent
table.insert(defaultbufftable, {"Leviathan","spellpower",1425 ,1}); 		--Sea Star
table.insert(defaultbufftable, {"Revelation", "Mastery", 2178 , 1});		--Theralion's Mirror
table.insert(defaultbufftable, {"Dire Magic","spellpower",2178 ,1});  		--Bell of Enraging Resonance
table.insert(defaultbufftable, {"Mark of the Firelord", "Int", 1277, 1});	--Rune of Zeth


local defaultclbufftable = {}

--class abilities
table.insert(defaultclbufftable, {32182, "Haste", 30, 1});      -- Heroism
table.insert(defaultclbufftable, {2825, "Haste", 30, 1});       -- Bloodlust
table.insert(defaultclbufftable, {80353, "Haste", 30, 1});      -- Time Warp
table.insert(defaultclbufftable, {90355, "Haste", 30, 1});      -- Primal Rage
table.insert(defaultclbufftable, {57934, "Damage", 15, 1});		-- Tricks of the Trade (Rogue)

--race abilities
table.insert(defaultclbufftable, {26297, "Haste", 20, 1});      -- Berserking

--profession abilities
table.insert(defaultclbufftable, {96230, "Int", 480 , 1});      -- Synapse Spring
table.insert(defaultclbufftable, {74497, "Haste", 480, 1});     -- Lifeblood
table.insert(defaultclbufftable, {55642, "Int", 295 , 1});      -- Lightweave Embroidery
table.insert(defaultclbufftable, {75172, "Int", 580, 1});       -- Lightweave Embroidery

--manufactured items
table.insert(defaultclbufftable, {58091, "Int", 1200, 1});      -- Volcanic Potion

--weapon enchants
table.insert(defaultclbufftable, {74242, "Int", 500, 1}); 		-- Power Torrent
table.insert(defaultclbufftable, {74221, "Int", 1650, 1});      -- Hurricane

--priest abilities
table.insert(defaultclbufftable, {10060, "Haste", 20, 1});      -- Power Infusion Buff 
table.insert(defaultclbufftable, {87118, "Damage", 2, 5}); 		-- Dark Evangelism
table.insert(defaultclbufftable, {95799, "Damage", 10, 1}); 	-- Empowered Shadow



function CancelButton_OnClick()
end

function SaveButton_OnClick()
	--Save the dialog's variables here.
	HasteWeight = EditBoxHaste:GetNumber();
	CritWeight = EditBoxCrit:GetNumber();
	MasteryWeight = EditBoxMastery:GetNumber();
	DamageWeight = EditBoxDamage:GetNumber();
	SpellpowerWeight = EditBoxSpellPower:GetNumber();
	CooldownOffset = EditBoxCooldownOffset:GetNumber();
	SetCooldownOffsets();
	SetCheckBoxes()
	-- DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer Options Saved...");
end

function OptionsFrame_OnLoad(panel)
    -- Set the name for the Category for the Panel
    --
	panel:RegisterEvent("ADDON_LOADED");
	panel:RegisterEvent("PLAYER_LOGOUT");
    panel.name = "SPDT Classic";

    -- When the player clicks okay, run this function.
    --
    panel.okay = function (self) SaveButton_OnClick(); end;

    -- When the player clicks cancel, run this function.
    --
    panel.cancel = function (self) CancelButton_OnClick();  end;

	--Build the list of buttons in the table.
		
	--DEFAULT_CHAT_FRAME:AddMessage("Building Entry Frames");
	local entry = CreateFrame("Button", "$parentEntry1", BuffListTable, "BuffListEntry");
	entry:SetID(1);
	entry:SetPoint("TOPLEFT", 4, -32);

	for i = 2, maxentries do
		local entry = CreateFrame("Button", "$parentEntry" .. i, BuffListTable, "BuffListEntry");
		entry:SetID(i);
		entry:SetPoint("TOP", "$parentEntry" .. (i - 1), "BOTTOM");
	end
	--DEFAULT_CHAT_FRAME:AddMessage("Done Building Entry Frames");

    -- Add the panel to the Interface Options
	category, layout = Settings.RegisterCanvasLayoutCategory(panel, panel.name);
	category.ID = "SPDT Classic"
	Settings.RegisterAddOnCategory(category);
	subcategory, subcategoryLayout = Settings.RegisterCanvasLayoutSubcategory(category, SPDTBuffSettings, "Buff List"); --buff menu
	
	OptionsFrame:Hide();
end

function OptionsFrame_OnEvent(self, event, ...)
	local arg1 = ...;
	
	if (event == "ADDON_LOADED"  and arg1 == "ShadowPriestDotTimer") then
	
		if(not HasteWeight) then
			HasteWeight = defaulthasteweight;
			DEFAULT_CHAT_FRAME:AddMessage("SPDT Classic Default HasteWeight Loaded...");
		end
		
		if(not CritWeight) then
			CritWeight = defaultcritweight;
			DEFAULT_CHAT_FRAME:AddMessage("SPDT Classic Default CritWeight Loaded...");
		end
		if(not MasteryWeight) then
			MasteryWeight = defaultmasteryweight;
			DEFAULT_CHAT_FRAME:AddMessage("SPDT Classic Default MasteryWeight Loaded...");
		end
		if(not DamageWeight) then
			DamageWeight = defaultdamageweight;
			DEFAULT_CHAT_FRAME:AddMessage("SPDT Classic Default DamageWeight Loaded...");
		end
		if(not SpellpowerWeight) then
			SpellpowerWeight = defaultspellpowerweight;
			DEFAULT_CHAT_FRAME:AddMessage("SPDT Classic Default SpellpowerWeight Loaded...");
		end
		if(not BuffList) then
			BuffList = defaultbufftable;
			DEFAULT_CHAT_FRAME:AddMessage("SPDT Classic Default BuffList Loaded...");
		end

		if(not SPDTScale) then
			SPDTScale= defaultSPDTpdtScale
		end

		ClassBuffList = defaultclbufftable;	--load the class list
		
		if(not HideAA) then
			HideAA = defaulthideaa;
		end
		if(not HideES) then
			HideES = defaulthidees;
		end
		if(not HideEvangelism) then
			HideEvangelism = defaulthideevangelism;
		end
		if(not HideOrbs) then
			HideOrbs = defaulthideorbs;
		end
		if(not HideMB) then
			HideMB = defaulthidemb;
		end
		if(not ColorDots) then
			ColorDots = defaulthidecolor;
		end
		if(not CooldownOffset) then
			CooldownOffset = defaultcooldownoffset;
			DEFAULT_CHAT_FRAME:AddMessage("SPDT Classic Default Cooldown Offset Loaded...");
		end

		SetWeights()

		if (HideAA == true) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Hide Dark Archangel");
			CheckButtonHideAA:SetChecked(true);
		end
		if (HideEvangelism == true) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Hide Evangelism");
			CheckButtonHideEvangelism:SetChecked(true);
		end
		if (HideES == true) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Hide Empowered Shadow");
			CheckButtonHideES:SetChecked(true);
		end
		if (HideOrbs == true) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Hide Shadow Orbs");
			CheckButtonHideOrbs:SetChecked(true);
		end

		if (HideMB == true) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Hide Mind Blast");
			CheckButtonHideMB:SetChecked(true);
		end

		if (ColorDots == true) then
			DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Dot Colour =1");
			CheckButtonColorDots:SetChecked(true);
		end
		
		BuffListBoxUpdate();

		SPDTScaleSlider:SetValue(SPDTScale)


		DEFAULT_CHAT_FRAME:AddMessage("--- SPDT Classic Stat Weights Loaded ---");
	elseif (event == "PLAYER_LOGOUT") then
		HasteWeight = EditBoxHaste:GetNumber();
		CritWeight = EditBoxCrit:GetNumber();
		MasteryWeight = EditBoxMastery:GetNumber();
		DamageWeight = EditBoxDamage:GetNumber();
		SpellpowerWeight = EditBoxSpellPower:GetNumber();
		CooldownOffset = EditBoxCooldownOffset:GetNumber();
		SPDTScale = SPDTScaleSlider:GetValue();
		SetCheckBoxes()
	end
end

function SetCheckBoxes()
	if (CheckButtonHideEvangelism:GetChecked()) then
		HideEvangelism = true;
	else
		HideEvangelism = false;
	end		
	if (CheckButtonHideOrbs:GetChecked()) then
		HideOrbs = true;

	else
		HideOrbs = false;
	end		
	if (CheckButtonHideES:GetChecked()) then
		HideES = true;
	else
		HideES = false;
	end		
	if (CheckButtonHideAA:GetChecked()) then
		HideAA = true;
	else
		HideAA = false;
	end		
	if (CheckButtonHideMB:GetChecked()) then
		HideMB = true;
		SPDT_MB_Texture:Hide(); --for cases where it is waiting to timeout still.
	else
		HideMB = false;
	end		
	if (CheckButtonColorDots:GetChecked()) then
		ColorDots = true;
	else
		ColorDots = false;
	end		
end

function SetWeights()
	EditBoxHaste:SetText(string.format("%1.3f", HasteWeight));
	EditBoxCrit:SetText(string.format("%1.3f", CritWeight));
	EditBoxMastery:SetText(string.format("%1.3f", MasteryWeight));
	EditBoxDamage:SetText(string.format("%1.2f", DamageWeight));
	EditBoxSpellPower:SetText(string.format("%1.3f", SpellpowerWeight));
	EditBoxCooldownOffset:SetText(string.format("%d", CooldownOffset));
end

function ResetDefaultWeightsButton_OnClick()
	DEFAULT_CHAT_FRAME:AddMessage("Resetting Stat Weights");
	HasteWeight = defaulthasteweight;
	CritWeight = defaultcritweight;
	MasteryWeight = defaultmasteryweight;
	DamageWeight = defaultdamageweight;
	SpellpowerWeight = defaultspellpowerweight;
	SetWeights();
end

function ButtonAddBuff_OnClick()
	-- Find the buff in the list
	local selection = nil;

	for i = 1, #BuffList do
		local entry = BuffList[i]
		if (entry) then
			if (entry[1] == EditBoxAddBuffName:GetText()) then
				selection = entry;
			end
		end
	end

	if (not selection) then
		-- If we have data, add the buff to the list.
		local stat = EditBoxAddStat:GetText();
		local buff = EditBoxAddBuffName:GetText();
		local modifier = EditBoxAddModifier:GetNumber();
		local maxstacks = EditBoxAddMaxStacks:GetNumber();

		if (stat and buff and modifier and maxstacks) then
			if (string.lower(stat) == "int" or
				string.lower(stat) == "mastery" or
				string.lower(stat) == "haste" or
				string.lower(stat) == "crit" or
				string.lower(stat) == "spellpower" or
				string.lower(stat) == "damage") then
				table.insert(BuffList, {buff, stat, modifier, maxstacks});
				FontStringError:SetText("Added...");
			else
				FontStringError:SetText("Stat must be one of: int, mastery, haste, crit, spellpower or damage.");
			end
		else
			FontStringError:SetText("All fields are required to add a buff. Modifier and maxstacks must be numeric.");
		end
	else
		FontStringError:SetText("Buff already exists.  Remove it first.");
	end

	EditBoxAddStat:SetText("");
	EditBoxAddBuffName:SetText("");
	EditBoxAddModifier:SetText("");
	EditBoxAddMaxStacks:SetText("");
	BuffListBoxUpdate();
end
 
function BuffListBoxUpdate(self)
	--DEFAULT_CHAT_FRAME:AddMessage("Updating frames with data");
	for i = 1, maxentries do
		local entry = BuffList[i + BuffListScrollFrame.offset];
		local frame = getglobal("BuffListTableEntry" .. i);

		if (entry) then
			frame:Show();
			getglobal(frame:GetName() .. "Name"):SetText(entry[1]);
			getglobal(frame:GetName() .. "Stat"):SetText(entry[2]);
			if (entry[2] == "Damage") then
				getglobal(frame:GetName() .. "Modifier"):SetText(entry[3] .. "%");
			else
				getglobal(frame:GetName() .. "Modifier"):SetText(entry[3]);
			end
			getglobal(frame:GetName() .. "MaxStacks"):SetText(entry[4]);
		else
			frame:Hide();
		end
	end
	
	--DEFAULT_CHAT_FRAME:AddMessage("Updating scroll bar");
	FauxScrollFrame_Update(BuffListScrollFrame, #BuffList, maxentries, 24, "BuffListTableEntry", 464, 480, BuffListTableHeaderMaxStacks, 88, 104);
	--DEFAULT_CHAT_FRAME:AddMessage("Done Updating scroll bar");
end

function BuffListScrollFrame_OnVerticalScroll(self, value, itemHeight, updateFunction)
	local scrollbar = getglobal(self:GetName() .. "ScrollBar");
	scrollbar:SetValue(value);
	self.offset = floor((value / itemHeight) + 0.5);
	BuffListBoxUpdate(self);
end

function ScrollFrameTemplate_OnMouseWheel(self, value, scrollBar)
	scrollBar = scrollBar or getglobal(self:GetName() .. "ScrollBar");
	if (value > 0) then
		scrollBar:SetValue(scrollBar:GetValue() - (scrollBar:GetHeight() /2));
	else
		scrollBar:SetValue(scrollBar:GetValue() + (scrollBar:GetHeight() /2));
	end
end

function BuffListEntry_OnClick(self)

	local id = self:GetID();
	local entry = BuffList[id + BuffListScrollFrame.offset];

	if (entry) then
		table.remove(BuffList, id + BuffListScrollFrame.offset);
		FontStringError:SetText("Removed...");
	end

	BuffListBoxUpdate();
end

function ResetDefaultBuffsButton_OnClick()
	DEFAULT_CHAT_FRAME:AddMessage("Resetting Buff List");
	ClearBuffList();
	BuffListBoxUpdate();
	FontStringError:SetText("Buff List reset to defaults.");
end

function ClearBuffList()  --clears the bufflist and then adds each entry from the defualtbufftable to bufftable.
	wipe(BuffList)
	for i = 1, #defaultbufftable do
		table.insert(BuffList, defaultbufftable[i])
	end
end

function SPDTPawnButton_OnClick()
	StaticPopupDialogs["SPDT_Pawn_EP_import"] = {

		text = "Please enter pawn string \n \124cFFFF0000NOTE: default stats are perfectly fine to use",
		button1 = "Accept",
		button2 = "Cancel",
		hasEditBox = true,
		editBoxWidth = 300,
		OnAccept = function (self)
			importString = self.editBox:GetText ();
			if (importString ~= "") then
				importPawn(importString)
			end
		end,
		timeout = 0,	
		whileDead = true,
		hideOnEscape = true,
	}
	StaticPopup_Show("SPDT_Pawn_EP_import")
end


function importPawn(import)
	local class = extractStat(import, "Class")
	local CritImport = extractStat(import, "CritRating")
	local HasteImport = extractStat(import, "HasteRating")
	local MasteryImport = extractStat(import, "MasteryRating")
	local SpellpowerImport = extractStat(import, "SpellDamage")

	if(class ~= nil) then
		if(CritImport ~= nil and HasteImport ~= nil and  MasteryImport ~= nil and SpellpowerImport ~= nil) then
			CritWeight = CritImport
			HasteWeight = HasteImport
			MasteryWeight =MasteryImport
			SpellpowerWeight =SpellpowerImport
			SetWeights();
			DEFAULT_CHAT_FRAME:AddMessage("\124cFF00FF00 Stat Weights Imported");
		else
			DEFAULT_CHAT_FRAME:AddMessage("\124cFFFF0000 ERROR importing Stat Weights");
		end
	else
		DEFAULT_CHAT_FRAME:AddMessage("\124cFFFF0000 ERROR importing Stat Weights");
	end

end

function extractStat(input, statName) -- for pawn import
    return input:match(statName .. '=([%a%d%.]+)')  -- Match alphanumeric + decimal for values
end

function hideButtons() -- for the tickboxes to hide elements
	SetCheckBoxes()
end

function moveSPDTButton_OnClick() -- options menu move button
	UnlockSPDT()
end

function  resetSPDTButton_OnClick()
	if InCombatLockdown() then 
		print("\124cFFFF0000 Cannot reset position while in combat")
		return 
	end
	ShadowPriestDoTTimerFrame:SetPoint("CENTER", 0, -70)

end


function SPDTScaleSlider_OnValueChanged(value)
	setSPDTScale(value)
end	

function setSPDTScale(scale)
	if InCombatLockdown() then
		if not inCombatFlag then
            print("\124cFFFF0000 Cannot change the scale while in combat")
            inCombatFlag = true;  -- Set the flag so we don't print again during the same combat
        end
        SPDTScaleSlider:SetValue(SPDTScale)
		return
    end
	 -- Proceed with updating the scale if we're out of combat
	 applySPDTScale(scale)
	 SPDTScaleSlider.ValueText:SetText(string.format("%d", math.floor(scale)))
end

function applySPDTScale(scale)
	inCombatFlag = false;
	if(scale == 1) then
		SPDTScale = 1;
		ShadowPriestDoTTimerFrame:SetScale(0.5);
	elseif(scale == 2) then
		SPDTScale = 2;
		ShadowPriestDoTTimerFrame:SetScale(0.6);
	elseif(scale == 3) then
		SPDTScale = 3;
		ShadowPriestDoTTimerFrame:SetScale(0.7);
	elseif(scale == 4) then
		SPDTScale = 4;
		ShadowPriestDoTTimerFrame:SetScale(0.8);
	elseif(scale == 5) then
		SPDTScale = 5;
		ShadowPriestDoTTimerFrame:SetScale(0.9);
	elseif(scale == 6) then
		SPDTScale = 6;
		ShadowPriestDoTTimerFrame:SetScale(1.0);
	elseif(scale == 7) then
		SPDTScale = 7;
		ShadowPriestDoTTimerFrame:SetScale(1.1);
	elseif(scale == 8) then
		SPDTScale = 8;
		ShadowPriestDoTTimerFrame:SetScale(1.2);
	elseif(scale == 9) then
		SPDTScale = 9;
		ShadowPriestDoTTimerFrame:SetScale(1.3);
	elseif(scale == 10) then
		SPDTScale = 10;
		ShadowPriestDoTTimerFrame:SetScale(1.4);
	elseif(scale == 11) then
		SPDTScale = 11;
		ShadowPriestDoTTimerFrame:SetScale(1.5);
	else
		print("\124cFFFF0000 Only a value of 1-11 is accepted. 6 is the default value") 
	end

	
end

-- Function to handle when the mouse enters the slider (show tooltip)
function SPDTScaleSlider_OnEnter()
    GameTooltip:SetOwner(SPDTScaleSlider, "ANCHOR_TOP")  -- Position the tooltip to the right of the slider
    GameTooltip:SetText("Default value is 6")  
    GameTooltip:Show()  
end

-- Function to handle when the mouse leaves the slider (hide tooltip)
function SPDTScaleSlider_OnLeave()
    GameTooltip:Hide()  
end