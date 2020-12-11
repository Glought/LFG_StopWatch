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
local Torghast = "Torghast"

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

--Shadowlands TorghastST
local torghastST = {
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
}

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

--Torghast
local TorghastLayerData = {
    [1] = {},
    [2] = {},
    [3] = {},
    [4] = {},
    [5] = {},
    [6] = {},
    [7] = {},
    [8] = {}
}

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

local torghastLayerNames = {
    [1] = "Layer_1",
    [2] = "Layer_2",
    [3] = "Layer_3",
    [4] = "Layer_4",
    [5] = "Layer_5",
    [6] = "Layer_6",
    [7] = "Layer_7",
    [8] = "Layer_8"
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

local groupListTorghast = {
    Torghast_Layer_1 = L["Layer"] .. " 1",
    Torghast_Layer_2 = L["Layer"] .. " 2",
    Torghast_Layer_3 = L["Layer"] .. " 3",
    Torghast_Layer_4 = L["Layer"] .. " 4",
    Torghast_Layer_5 = L["Layer"] .. " 5",
    Torghast_Layer_6 = L["Layer"] .. " 6",
    Torghast_Layer_7 = L["Layer"] .. " 7",
    Torghast_Layer_8 = L["Layer"] .. " 8"
}

local orderListTorghast = {
    "Torghast_Layer_1",
    "Torghast_Layer_2",
    "Torghast_Layer_3",
    "Torghast_Layer_4",
    "Torghast_Layer_5",
    "Torghast_Layer_6",
    "Torghast_Layer_7",
    "Torghast_Layer_8"
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

local timeTorghastCols = {
    {name = L["Torghast Wing Name"], width = 170, defaultsort = "dsc"},
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
    for i = 1, #torghastST do
        if torghastST[i] then
            torghastST[i]:Hide()
        end
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
        TORGHAST = function()
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
        end,
        Torghast_Layer_1 = function()
            LFGSW_TL_Frame:DrawGroups(container, Torghast, group, 1)
        end,
        Torghast_Layer_2 = function()
            LFGSW_TL_Frame:DrawGroups(container, Torghast, group, 2)
        end,
        Torghast_Layer_3 = function()
            LFGSW_TL_Frame:DrawGroups(container, Torghast, group, 3)
        end,
        Torghast_Layer_4 = function()
            LFGSW_TL_Frame:DrawGroups(container, Torghast, group, 4)
        end,
        Torghast_Layer_5 = function()
            LFGSW_TL_Frame:DrawGroups(container, Torghast, group, 5)
        end,
        Torghast_Layer_6 = function()
            LFGSW_TL_Frame:DrawGroups(container, Torghast, group, 6)
        end,
        Torghast_Layer_7 = function()
            LFGSW_TL_Frame:DrawGroups(container, Torghast, group, 7)
        end,
        Torghast_Layer_8 = function()
            LFGSW_TL_Frame:DrawGroups(container, Torghast, group, 8)
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
    LFGTabs:SetTabs(
        {
            {text = L["Dungeons"], value = "Dun"},
            {text = L["Raids"], value = "RAIDING"},
            {text = L["Torghast"], value = "TORGHAST"}
        }
    )
    LFGTabs:SetLayout("Flow")
    LFGTabs:SetWidth(470)
    LFGTabs:SetFullHeight(true)

    LFGTabs:SetCallback("OnGroupSelected", SelectGroup)
    LFGTabs:SelectTab("Dun")
    frame:AddChild(LFGTabs)
end

local function createDropdowns(self, grouplist, orderlist, defaultGroup, title)
    local self = AceGui:Create("DropdownGroup")
    self:SetTitle(title)
    self:SetGroupList(grouplist, orderlist)
    self:SetCallback("OnGroupSelected", SelectGroup)
    self:SetGroup(defaultGroup)

    self:SetLayout("flow")
    self:SetWidth(450)
    self:SetFullHeight(true)
    return self
end

function LFGSW_TL_Frame:createUpdateTimes(self, expansion, dataTable, updateType, torghastLayerNumber)
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
        elseif updateType == Torghast then
            instanceMapIDTable =
                LFGSW.dbpc.char.MapIDs.Expansion[expansionNames[expansion]].Torghast[
                torghastLayerNames[torghastLayerNumber]
            ].IDs
            instanceTable =
                LFGSW.dbpc.char.Expansion[expansionNames[expansion]].Torghast[torghastLayerNames[torghastLayerNumber]].IDs
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
                local LFGDunDropDown =
                    createDropdowns(LFGDunDropDown, groupList, orderList, "SHADOWLANDS", L["Expansion: "])
                container:AddChild(LFGDunDropDown)
            end,
            RAIDING = function()
                local LFGRaidsDropDown =
                    createDropdowns(
                    LFGRaidsDropDown,
                    groupListRaid,
                    orderListRaid,
                    "SHADOWLANDS_Raid",
                    L["Expansion: "]
                )
                container:AddChild(LFGRaidsDropDown)
            end,
            TORGHAST = function()
                local LFGTorghastDropDown =
                    createDropdowns(
                    LFGTorghastDropDown,
                    groupListTorghast,
                    orderListTorghast,
                    "Torghast_Layer_1",
                    L["Torghast Layers: "]
                )
                container:AddChild(LFGTorghastDropDown)
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
        },
        Torghast = {
            Torghast_Layer_1 = function()
                torghastST[1] = LFGSW_TL_Frame:createSTs(torghastST[1], timeTorghastCols, container)
            end,
            Torghast_Layer_2 = function()
                torghastST[2] = LFGSW_TL_Frame:createSTs(torghastST[2], timeTorghastCols, container)
            end,
            Torghast_Layer_3 = function()
                torghastST[3] = LFGSW_TL_Frame:createSTs(torghastST[3], timeTorghastCols, container)
            end,
            Torghast_Layer_4 = function()
                torghastST[4] = LFGSW_TL_Frame:createSTs(torghastST[4], timeTorghastCols, container)
            end,
            Torghast_Layer_5 = function()
                torghastST[5] = LFGSW_TL_Frame:createSTs(torghastST[5], timeTorghastCols, container)
            end,
            Torghast_Layer_6 = function()
                torghastST[6] = LFGSW_TL_Frame:createSTs(torghastST[6], timeTorghastCols, container)
            end,
            Torghast_Layer_7 = function()
                torghastST[7] = LFGSW_TL_Frame:createSTs(torghastST[7], timeTorghastCols, container)
            end,
            Torghast_Layer_8 = function()
                torghastST[8] = LFGSW_TL_Frame:createSTs(torghastST[8], timeTorghastCols, container)
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
    --Torghast Layers
    LFGSW_TL_Frame:createUpdateTimes(torghastST[1], 8, TorghastLayerData[1], Torghast, 1)
    LFGSW_TL_Frame:createUpdateTimes(torghastST[2], 8, TorghastLayerData[2], Torghast, 2)
    LFGSW_TL_Frame:createUpdateTimes(torghastST[3], 8, TorghastLayerData[3], Torghast, 3)
    LFGSW_TL_Frame:createUpdateTimes(torghastST[4], 8, TorghastLayerData[4], Torghast, 4)
    LFGSW_TL_Frame:createUpdateTimes(torghastST[5], 8, TorghastLayerData[5], Torghast, 5)
    LFGSW_TL_Frame:createUpdateTimes(torghastST[6], 8, TorghastLayerData[6], Torghast, 6)
    LFGSW_TL_Frame:createUpdateTimes(torghastST[7], 8, TorghastLayerData[7], Torghast, 7)
    LFGSW_TL_Frame:createUpdateTimes(torghastST[8], 8, TorghastLayerData[8], Torghast, 8)
end

--Ends of UpdateDungeon/Raids
function LFGSW_TL_Frame:OnTimeLogUpdate()
    LFGSW_TL_Frame:UpdateTimes()
end
