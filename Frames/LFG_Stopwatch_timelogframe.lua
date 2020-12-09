-------------------------------------------------------------------------------
-- LFG StopWatch
--Copyright (C) 2020  Thoughts of Glought

--This program is free software: you can redistribute it and/or modify
--it under the terms of the GNU General Public License as published by
--the Free Software Foundation, either version 3 of the License, or
--(at your option) any later version.
--------------------------------------------------------------------------------
--This program is distributed in the hope that it will be useful,
--but WITHOUT ANY WARRANTY; without even the implied warranty of
--MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--GNU General Public License for more details.
---------------------------------------------------------------------------------
--You should have received a copy of the GNU General Public License
--along with this program.  If not, see <http://www.gnu.org/licenses/>.
----------------------------------------------------------------------------------

LFGSW = LibStub("AceAddon-3.0"):GetAddon("LFGStopWatch")
LFGSW_TL_Frame = LFGSW:NewModule("TimeLogFrameLFGSW", "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("LFGStopWatch")
local ScrollTable = LibStub("ScrollingTable")
local AceGui = LibStub("AceGUI-3.0")
local mainframe

local LFGStopWatchLDB =
    LibStub("LibDataBroker-1.1"):NewDataObject(
    "LFGStopWatchTimeLog",
    {
        type = "data source",
        Text = L["LFG StopWatch Time Log"],
        icon = "Interface\\Icons\\Spell_Shadow_LastingAffliction.png",
        OnClick = function()
            LFGSW_TL_Frame:TimeLog()
        end
    }
)
local icon = LibStub("LibDBIcon-1.0")

function LFGStopWatchLDB.OnTooltipShow(tt)
    tt:AddLine("LFG StopWatch TimeLog")
    tt:AddLine(" ")
    tt:AddLine("Show the LFG StopWatch Time Log")
end

local Raids = "Raids"
local Dungeons = "Dungeons"
local TimeWalking = "TimeWalking"

--DungeonST
local classicST = false
local tbcST = false
local wotlkST = false
local cataST = false
local mopST = false
local wodST = false
local legionST = false
local bfaST = false
local shadowlandsST = false

--RaidSTs
local timewalkingRaidST = false
local shadowlandsRaidST = false

--Dungeons
local classicData = {}
local tbcData = {}
local wotlkData = {}
local cataData = {}
local mopData = {}
local wodData = {}
local LegionData = {}

--Raids
local TimewalkingRaidData = {}
local ShadowlandRaidData = {}

local expansionNames = {
    [0] = "Classic",
    "TBC",
    "WOTLK",
    "CATA",
    "MOP",
    "WOD",
    "LEGION",
    "BFA",
    "SHADOWLANDS",
    "??",
    "???"
}

local groupList = {
    CLASSIC = L["Classic"],
    TBC = L["The Burning Crusade"],
    WOTLK = L["Wrath of the Lich King"],
    CATA = L["Cataclysm"],
    MOP = L["Mists of Pandaria"],
    WOD = L["Warlords of Draenor"],
    LEGION = L["Legion"],
    BFA = L["Battle for Azeroth"],
    SHADOWLANDS = L["Shadowlands"]
}

local orderList = {
    "CLASSIC",
    "TBC",
    "WOTLK",
    "CATA",
    "MOP",
    "WOD",
    "LEGION",
    "BFA",
    "SHADOWLANDS"
}

local groupListRaid = {
    TIMEWALKING_Raid = L["TimeWalking"],
    SHADOWLANDS_Raid = L["Shadowlands"]
}

local orderListRaid = {
    "TIMEWALKING_Raid",
    "SHADOWLANDS_Raid"
}

local timeDunCols = {
    {name = L["Dungeon Name"], width = 170, defaultsort = "dsc"},
    {name = L["Current Time"], width = 80, defaultsort = "dsc"},
    {name = L["Old Time"], width = 80, defaultsort = "dsc"},
    {name = L["Times Completed"], width = 100, defaultsort = "dsc"}
}

local timeRaidCols = {
    {name = L["Raid Name"], width = 170, defaultsort = "dsc"},
    {name = L["Current Time"], width = 80, defaultsort = "dsc"},
    {name = L["Old Time"], width = 80, defaultsort = "dsc"},
    {name = L["Times Completed"], width = 100, defaultsort = "dsc"}
}

function LFGSW_TL_Frame:OnInitialize()
    icon:Register("LFGStopWatchTimeLog", LFGStopWatchLDB, LFGSW.dbpc.char.minimap)
    LFGSW_TL_Frame:OnTimeLogUpdate()
end

function LFGSW_TL_Frame:OnEnable()
    LFGSW_TL_Frame:RegisterEvent("PLAYER_ENTERING_WORLD", "OnTimeLogUpdate")
    LFGSW_TL_Frame:RegisterChatCommand("lfgswtime", "TimeLog", true)
    LFGSW_TL_Frame:RegisterMessage("OnLFG_SW_TimeUpdate", "OnTimeLogUpdate")
    LFGSW_TL_Frame:SetUpFrames()

    if LFGSW.dbpc.char.minimap.hide == true then
        icon:Hide("LFGStopWatchTimeLog")
    else
        icon:Show("LFGStopWatchTimeLog")
    end
end

function LFGSW_TL_Frame:OnDisable()
    LFGSW_TL_Frame:UnregisterChatCommand("lfgswtime")
    LFGSW_TL_Frame:UnregisterEvent("PLAYER_ENTERING_WORLD")
    LFGSW_TL_Frame:UnregisterMessage("OnLFG_SW_TimeUpdate")
    icon:DisableLibrary()
end

function LFGSW_TL_Frame:TimeLog()
    if mainframe:IsShown() ~= true then
        mainframe:Show()
    else
        mainframe:Hide()
    end
end

function LFGSW_TL_Frame:hideSTs()
    --DungeonSTS
    if classicST then
        classicST:Hide()
    end
    if tbcST then
        tbcST:Hide()
    end
    if wotlkST then
        wotlkST:Hide()
    end
    if cataST then
        cataST:Hide()
    end
    if mopST then
        mopST:Hide()
    end
    if wodST then
        wodST:Hide()
    end
    if legionST then
        legionST:Hide()
    end
    if bfaST then
        bfaST:Hide()
    end
    if shadowlandsST then
        shadowlandsST:Hide()
    end
    --RaidSTs
    if timewalkingRaidST then
        timewalkingRaidST:Hide()
    end
    if shadowlandsRaidST then
        shadowlandsRaidST:Hide()
    end
end

--SelectGroupFuntions---
local function SelectGroup(container, event, group)
    container:ReleaseChildren()
    LFGSW_TL_Frame:hideSTs()

    local GroupSwitch = {
        Dun = function()
            LFGSW_TL_Frame:DrawGroups(container, "MAIN", group)
        end,
        RAIDING = function()
            LFGSW_TL_Frame:DrawGroups(container, "MAIN", group)
        end,
        CLASSIC = function()
            LFGSW_TL_Frame:DrawGroups(container, Dungeons, group)
        end,
        TBC = function()
            LFGSW_TL_Frame:DrawGroups(container, Dungeons, group)
        end,
        WOTLK = function()
            LFGSW_TL_Frame:DrawGroups(container, Dungeons, group)
        end,
        CATA = function()
            LFGSW_TL_Frame:DrawGroups(container, Dungeons, group)
        end,
        MOP = function()
            LFGSW_TL_Frame:DrawGroups(container, Dungeons, group)
        end,
        WOD = function()
            LFGSW_TL_Frame:DrawGroups(container, Dungeons, group)
        end,
        LEGION = function()
            LFGSW_TL_Frame:DrawGroups(container, Dungeons, group)
        end,
        BFA = function()
            LFGSW_TL_Frame:DrawGroups(container, Dungeons, group)
        end,
        SHADOWLANDS = function()
            LFGSW_TL_Frame:DrawGroups(container, Dungeons, group)
        end,
        TIMEWALKING_Raid = function()
            LFGSW_TL_Frame:DrawGroups(container, Raids, group)
        end,
        SHADOWLANDS_Raid = function()
            LFGSW_TL_Frame:DrawGroups(container, Raids, group)
        end
    }
    GroupSwitch[group]()
    
end
--End of SelectGroupFuntions---

--SetupFrames/Draw
function LFGSW_TL_Frame:SetUpFrames()
    local frame = AceGui:Create("Frame")
    mainframe = frame
    frame:SetTitle(L["LFG StopWatch TimeLog"])
    frame:SetStatusText(L["LFG StopWatch TimeLog"])
    frame:SetLayout("Flow")
    frame:SetWidth(500)
    frame:SetHeight(400)
    frame:EnableResize(false)
    frame:Hide()

    local LFGTabs = AceGui:Create("TabGroup")
    LFGTabs:SetTabs({{text = L["Dungeons"], value = "Dun"}, {text = L["Raids"], value = "RAIDING"}})
    LFGTabs:SetLayout("Flow")
    LFGTabs:SetWidth(470)
    LFGTabs:SetFullHeight(true)

    LFGTabs:SetCallback("OnGroupSelected", SelectGroup)
    LFGTabs:SelectTab("Dun")
    frame:AddChild(LFGTabs)
end

local function createDropdowns(self, grouplist, orderlist, defaultGroup)
    local self = AceGui:Create("DropdownGroup")
    self:SetTitle(L["Expansion: "])
    self:SetGroupList(grouplist, orderlist)
    self:SetCallback("OnGroupSelected", SelectGroup)
    self:SetGroup(defaultGroup)

    self:SetLayout("flow")
    self:SetWidth(450)
    self:SetFullHeight(true)
    return self
end

function LFGSW_TL_Frame:createUpdateTimes(self, expansion, dataTable, updateType)
    if self then
        dataTable = {}
        local times = {}
        local instanceTable
        local instanceMapIDTable
        local instanceName

        if updateType == Dungeons then
            instanceMapIDTable = LFGSW.dbpc.char.MapIDs.Expansion[expansionNames[expansion]].Dungeons
            instanceTable = LFGSW.dbpc.char.Expansion[expansionNames[expansion]].Dungeons
        elseif updateType == Raids then
            instanceMapIDTable = LFGSW.dbpc.char.MapIDs.Expansion[expansionNames[expansion]].Raids
            instanceTable = LFGSW.dbpc.char.Expansion[expansionNames[expansion]].Raids
        elseif updateType == TimeWalking then
            instanceMapIDTable = LFGSW.dbpc.char.MapIDs.TimeWalkingRaids
            instanceTable = LFGSW.dbpc.char.TimeWalking.Raids
        end

        for key, value in pairs(instanceMapIDTable) do
            instanceName = instanceTable[value].Name
            if not times[instanceName] then
                times[instanceName] = {currentTime = "", oldTime = "", timesCompleted = ""}
            end
            times[instanceName].currentTime = instanceTable[value].TimeCurr
            times[instanceName].oldTime = instanceTable[value].TimeOld
            times[instanceName].timesCompleted = instanceTable[value].TimesCompleted
        end

        for instanceName, data in pairs(times) do
            table.insert(
                dataTable,
                {
                    cols = {
                        {value = instanceName},
                        {value = data.currentTime},
                        {value = data.oldTime},
                        {value = data.timesCompleted}
                    }
                }
            )
        end
        self:SetData(dataTable)
    end
end

function LFGSW_TL_Frame:createSTs(self, Col, container)
    if self == false then
        local window = container.frame
        self = ScrollTable:CreateST(Col, 9, 20, nil, window)
        self.frame:SetPoint("BOTTOMLEFT", window, 10, 10)
        self.frame:SetPoint("TOP", window, 0, -70)
        self.frame:SetPoint("RIGHT", window, -10, 0)
    end
    self:Show()
    return self
end

function LFGSW_TL_Frame:DrawGroups(container, groupType, group)
    local DrawGroupSwitch = {
        MAIN = {
            Dun = function()
                local LFGDunDropDown = createDropdowns(LFGDunDropDown, groupList, orderList, "SHADOWLANDS")
                container:AddChild(LFGDunDropDown)
            end,
            RAIDING = function()
                local LFGRaidsDropDown =
                    createDropdowns(LFGRaidsDropDown, groupListRaid, orderListRaid, "SHADOWLANDS_Raid")
                container:AddChild(LFGRaidsDropDown)
            end
        },
        Dungeons = {
            CLASSIC = function()
                classicST = LFGSW_TL_Frame:createSTs(classicST, timeDunCols, container)
            end,
            TBC = function()
                tbcST = LFGSW_TL_Frame:createSTs(tbcST, timeDunCols, container)
            end,
            WOTLK = function()
                wotlkST = LFGSW_TL_Frame:createSTs(wotlkST, timeDunCols, container)
            end,
            CATA = function()
                cataST = LFGSW_TL_Frame:createSTs(cataST, timeDunCols, container)
            end,
            MOP = function()
                mopST = LFGSW_TL_Frame:createSTs(mopST, timeDunCols, container)
            end,
            WOD = function()
                wodST = LFGSW_TL_Frame:createSTs(wodST, timeDunCols, container)
            end,
            LEGION = function()
                legionST = LFGSW_TL_Frame:createSTs(legionST, timeDunCols, container)
            end,
            BFA = function()
                bfaST = LFGSW_TL_Frame:createSTs(bfaST, timeDunCols, container)
            end,
            SHADOWLANDS = function()
                shadowlandsST = LFGSW_TL_Frame:createSTs(shadowlandsST, timeDunCols, container)
            end
        },
        Raids = {
            TIMEWALKING_Raid = function()
                timewalkingRaidST = LFGSW_TL_Frame:createSTs(timewalkingRaidST, timeRaidCols, container)
            end,
            SHADOWLANDS_Raid = function()
                shadowlandsRaidST = LFGSW_TL_Frame:createSTs(shadowlandsRaidST, timeRaidCols, container)
            end
        }
    }

    DrawGroupSwitch[groupType][group]()
    LFGSW_TL_Frame:UpdateTimes()
end

--Start of UpdateDungeon/Raids Times
function LFGSW_TL_Frame:UpdateTimes()
    LFGSW_TL_Frame:createUpdateTimes(classicST, 0, classicData, Dungeons)
    LFGSW_TL_Frame:createUpdateTimes(tbcST, 1, tbcData, Dungeons)
    LFGSW_TL_Frame:createUpdateTimes(wotlkST, 2, wotlkData, Dungeons)
    LFGSW_TL_Frame:createUpdateTimes(cataST, 3, cataData, Dungeons)
    LFGSW_TL_Frame:createUpdateTimes(mopST, 4, mopData, Dungeons)
    LFGSW_TL_Frame:createUpdateTimes(wodST, 5, wodData, Dungeons)
    LFGSW_TL_Frame:createUpdateTimes(legionST, 6, legionData, Dungeons)
    LFGSW_TL_Frame:createUpdateTimes(bfaST, 7, bfaData, Dungeons)
    LFGSW_TL_Frame:createUpdateTimes(shadowlandsST, 8, shadowlandsData, Dungeons)
    LFGSW_TL_Frame:createUpdateTimes(timewalkingRaidST, nil, TimewalkingRaidData, TimeWalking)
    LFGSW_TL_Frame:createUpdateTimes(shadowlandsRaidST, 8, ShadowlandRaidData, Raids)
end

--Ends of UpdateDungeon/Raids
function LFGSW_TL_Frame:OnTimeLogUpdate()
    LFGSW_TL_Frame:UpdateTimes()
end
