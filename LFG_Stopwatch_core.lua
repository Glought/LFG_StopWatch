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

LFGSW = LibStub("AceAddon-3.0"):NewAddon("LFGStopWatch", "AceEvent-3.0", "AceConsole-3.0", "AceTimer-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("LFGStopWatch")
local AceDBOptions = LibStub("AceDBOptions-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0", true)
local AceGui = LibStub("AceGUI-3.0")

--local mainframe
local TimeLogFrameLFGSW

--Options
LFGSWoptions = {
    name = L["LFG StopWatch"],
    handler = LFGSW,
    type = "group",
    args = {
        lfgswmainheader = {
            order = 1,
            name = L["Main Settings"],
            width = "double",
            type = "header"
        },
        delay = {
            name = L["StopWatch Start Delay"],
            desc = L["Set the start delay to shortest time possable for the most accurate time. Default is 15 secs."],
            order = 3,
            width = "double",
            type = "range",
            min = 5,
            max = 120,
            get = "GetDelay",
            set = "SetDelay"
        },
        toggleonoff = {
            name = L["Enable Lfg Stopwatch"],
            desc = L[
                "If ON it will start the stopwatch when entering a lfg .If OFF it will not start the stopwatch. Default is ON"
            ],
            order = 4,
            width = "double",
            type = "toggle",
            get = function()
                return LFGSW.dbpc.char.offon
            end,
            set = function(self, value)
                LFGSW.dbpc.char.offon = value
            end
        },
        enableMessage = {
            name = L["Enable the 'Time it took to complete this dungeon' Message"],
            desc = L["If checked it will enable the message.Default : enabled"],
            order = 5,
            width = "full",
            type = "toggle",
            get = function()
                return LFGSW.dbpc.char.enablemessage
            end,
            set = function(self, value)
                LFGSW.dbpc.char.enablemessage = value
            end
        },
        hideminimapIcon = {
            name = L["Hide StopWatch Time Log Minimap Icon"],
            desc = L[
                "If checked it will hide the MiniMap icon,if you want to see the Time Log use the /lfgswtime chat command"
            ],
            order = 6,
            width = "double",
            type = "toggle",
            get = function()
                return LFGSW.dbpc.char.minimap.hide
            end,
            set = function(self, value)
                LFGSW.dbpc.char.minimap.hide = value
            end
        }
    }
}
--Defaults
local defaults = {
    global = {
        inprogress = false
    }
}

local charsettings = {
    char = {
        offon = true,
        delay = 15,
        enablemessage = true,
        minimap = {
            hide = false
        },
        MapIDs = {
            TimeWalkingRaids = {
                ["*"] = {}
            },
            Expansion = {
                ["*"] = {
                    Dungeons = {},
                    Raids = {}
                }
            }
        },
        TimeWalking = {
            Raids = {
                ["*"] = {
                    mapID = nil,
                    Name = nil,
                    TimesCompleted = 0,
                    TimeCurr = "00h:00m:00s",
                    TimeOld = "00h:00m:00s",
                    Difficulty = nil,
                    Expanion = nil
                }
            }
        },
        Expansion = {
            ["*"] = {
                --< Expansion
                Dungeons = {
                    ["*"] = {
                        --< Dungeon
                        mapID = nil,
                        Name = nil,
                        TimesCompleted = 0,
                        TimeCurr = "00h:00m:00s",
                        TimeOld = "00h:00m:00s",
                        Difficulty = nil,
                        Expanion = nil
                    }
                },
                Raids = {
                    ["*"] = {
                        mapID = nil,
                        Name = nil,
                        TimesCompleted = 0,
                        TimeCurr = "00h:00m:00s",
                        TimeOld = "00h:00m:00s",
                        Difficulty = nil,
                        Expanion = nil
                    }
                }
            }
        }
    }
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

function LFGSW:GetDelay(info)
    return LFGSW.dbpc.char.delay
end

function LFGSW:SetDelay(info, value)
    LFGSW.dbpc.char.delay = value
end

function LFGSW:OnInitialize()
    LFGSW:Print("LFG Stop Watch Enabled")
    LFGSW.db = LibStub("AceDB-3.0"):New("LfdLfrStopwatchDB", defaults, true)
    LFGSW.db:RegisterDefaults(defaults)
    LFGSW.dbpc = LibStub("AceDB-3.0"):New("LfgStopwatchCharDB", charsettings)
    local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(LFGSW.db)
    AceConfig:RegisterOptionsTable("LFGSW", LFGSWoptions, {"lfgswsettings", "lfgswset"})
    AceConfigDialog:AddToBlizOptions("LFGSW", "LFG StopWatch")
    TimeLogFrameLFGSW = LFGSW:GetModule("TimeLogFrameLFGSW")
end

function LFGSW:OnEnable()
    LFGSW:RegisterEvent("PLAYER_ENTERING_WORLD", "startLfgStopWatch")
    LFGSW:RegisterEvent("SCENARIO_COMPLETED", "pauseLfgStopWatch")
    LFGSW:RegisterChatCommand("lfgsw", "toggleLfgStopWatch", true)
    TimeLogFrameLFGSW:Enable()
end

function LFGSW:OnDisable()
    LFGSW:UnregisterChatCommand("LFGSW")
    LFGSW:UnregisterEvent("PLAYER_ENTERING_WORLD")
    LFGSW:UnregisterEvent("SCENARIO_COMPLETED")
    TimeLogFrameLFGSW:Disable()
end

function LFGSW:lfgswtimer()
    if IsInGroup() and HasLFGRestrictions() then
        StopwatchFrame:Show()
        Stopwatch_Play()
        LFGSW.db.global.inprogress = true
    else
        StopwatchFrame:Hide()
        LFGSW.db.global.inprogress = false
    end
end

function LFGSW:toggleLfgStopWatch()
    if LFGSW.dbpc.char.offon then
        LFGSW.dbpc.char.offon = false
        LFGSW:Print("Off")
    else
        LFGSW.dbpc.char.offon = true
        LFGSW:Print("On")
    end
end

function LFGSW:SendTimeMessage()
    local SEC_TO_MINUTE_FACTOR = 1 / 60
    local SEC_TO_HOUR_FACTOR = SEC_TO_MINUTE_FACTOR * SEC_TO_MINUTE_FACTOR
    local timer = StopwatchTicker.timer
    local hour = min(floor(timer * SEC_TO_HOUR_FACTOR), 99)
    local minute = mod(timer * SEC_TO_MINUTE_FACTOR, 60)
    local second = mod(timer, 60)

    local hoursplit = string.split(".", hour)
    local minsplit = string.split(".", minute)
    local secsplit = string.split(".", second)

    local hoursplitToNum = tonumber(hoursplit)
    local hoursplitFormat
    local minsplitToNum = tonumber(minsplit)
    local minsplitFormat
    local secsplitFormat
    local secsplitToNum = tonumber(secsplit)

    if hoursplitToNum <= 9 then
        hoursplitFormat = "0" .. hoursplit
    else
        hoursplitFormat = hoursplit
    end

    if minsplitToNum <= 9 then
        minsplitFormat = "0" .. minsplit
    else
        minsplitFormat = minsplit
    end

    if secsplitToNum <= 9 then
        secsplitFormat = "0" .. secsplit
    else
        secsplitFormat = secsplit
    end

    local timemessage = string.format("%sh:%sm:%ss", hoursplitFormat, minsplitFormat, secsplitFormat)
    if minsplit ~= 0 and hoursplit ~= 0 then
        if LFGSW.dbpc.char.enablemessage == true then
            SendChatMessage(
                L["Time taken to complete this instance(When i joined): "] .. timemessage,
                "INSTANCE_CHAT",
                nil,
                nil
            )
        end
    end
    LFGSW:UpdateTimeLog(timemessage)
end

function LFGSW:UpdateTimeLog(timemessage, id)
    local LfgDungeonID
    
    if id ~= nil then
      LfgDungeonID = id
    else
      LfgDungeonID = select(10,GetInstanceInfo())
    end
    
    local name,
        typeID,
        subtypeID,
        minLevel,
        maxLevel,
        recLevel,
        minRecLevel,
        maxRecLevel,
        expansionLevel,
        groupID,
        textureFilename,
        difficulty,
        maxPlayers,
        description,
        isHoliday,
        bonusRepAmount,
        minPlayers,
        isTimeWalker,
        name2,
        minGearLevel = GetLFGDungeonInfo(LfgDungeonID)

    local expanName = expansionNames[expansionLevel]
    local oldTime
    local newTime
    local timesCompleted
    local timesCompletedFormat
    local instanceTable

    local _MapidsDungeons =
        setmetatable(
        {},
        {
            __newindex = function(table, key, value)
                LFGSW.dbpc.char.MapIDs.Expansion[expanName].Dungeons[key] = value
            end
        }
    )

    local _MapidsRaids =
        setmetatable(
        {},
        {
            __newindex = function(table, key, value)
                LFGSW.dbpc.char.MapIDs.Expansion[expanName].Raids[key] = value
            end
        }
    )

    local _MapidsTimewalking =
        setmetatable(
        {},
        {
            __newindex = function(table, key, value)
                LFGSW.dbpc.char.MapIDs.TimeWalkingRaids[key] = value
            end
        }
    )

    if subtypeID == 1 or subtypeID == 2 then
        _MapidsDungeons[LfgDungeonID] = LfgDungeonID
        instanceTable = LFGSW.dbpc.char.Expansion[expanName].Dungeons
        if subtypeID == 2 then
            if (isTimeWalker) then
                instanceTable[LfgDungeonID].Name = name .. " (Timewalking)"
            else
                instanceTable[LfgDungeonID].Name = name .. " (Heroic)"
            end
        else
            instanceTable[LfgDungeonID].Name = name
        end
    elseif subtypeID == 3 or subtypeID == 5 and isTimeWalker == false then
        _MapidsRaids[LfgDungeonID] = LfgDungeonID
        instanceTable = LFGSW.dbpc.char.Expansion[expanName].Raids
        instanceTable[LfgDungeonID].Name = name
    elseif subtypeID == 3 or subtypeID == 5 and isTimeWalker == true then
        _MapidsTimewalking[LfgDungeonID] = LfgDungeonID
        instanceTable = LFGSW.dbpc.char.TimeWalking.Raids
        instanceTable[LfgDungeonID].Name = name
    end

    instanceTable[LfgDungeonID].Expanion = expanName
    timesCompleted = instanceTable[LfgDungeonID].TimesCompleted
    instanceTable[LfgDungeonID].TimesCompleted = timesCompleted + 1
    instanceTable[LfgDungeonID].Difficulty = difficulty
    if instanceTable[LfgDungeonID].TimeCurr == "00h:00m:00s" then
        newTime = timemessage
        instanceTable[LfgDungeonID].TimeCurr = newTime
    elseif timemessage <= instanceTable[LfgDungeonID].TimeCurr then
        oldTime = instanceTable[LfgDungeonID].TimeCurr
        newTime = timemessage
        instanceTable[LfgDungeonID].TimeOld = oldTime
        instanceTable[LfgDungeonID].TimeCurr = newTime
    end

    LFGSW:SendMessage("OnLFG_SW_TimeUpdate")
end

function LFGSW:startLfgStopWatch()
    if LFGSW.dbpc.char.offon then
        if LFGSW.db.global.inprogress ~= true then
            LFGSW:ScheduleTimer("lfgswtimer", LFGSW:GetDelay())
            Stopwatch_Clear()
        end
        if IsInGroup() ~= true then
            LFGSW.db.global.inprogress = false
        end
    end
end

function LFGSW:pauseLfgStopWatch()
    if LFGSW.dbpc.char.offon then
        if IsInGroup() and HasLFGRestrictions() then
            Stopwatch_Pause()
            LFGSW:SendTimeMessage()
            LFGSW.db.global.inprogress = false
            StopwatchFrame:Hide()
        end
    end
end
