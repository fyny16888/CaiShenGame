--[[
*名称:NewClubQuickRoomLayer
*描述:快速加入游戏
*作者:admin
*创建日期:2019-05-17 18:07:55
*修改日期:
]]

local EventMgr              = require("common.EventMgr")
local EventType             = require("common.EventType")
local NetMgr                = require("common.NetMgr")
local NetMsgId              = require("common.NetMsgId")
local StaticData            = require("app.static.StaticData")
local UserData              = require("app.user.UserData")
local Common                = require("common.Common")
local Default               = require("common.Default")
local GameConfig            = require("common.GameConfig")
local Log                   = require("common.Log")

local NewClubQuickRoomLayer = class("NewClubQuickRoomLayer", cc.load("mvc").ViewBase)

function NewClubQuickRoomLayer:onConfig()
    self.widget             = {
        {"Image_bg"},
        {"Button_close", "onClose"},
        {"ScrollView_playList"},
        {"Button_playItem"},
    }
end

function NewClubQuickRoomLayer:onEnter()
end

function NewClubQuickRoomLayer:onExit()
end

function NewClubQuickRoomLayer:onCreate(param)
    self.clubData = param[1]
    local waynum = param[2]
    local tables = param[3]
    Log.d(self.clubData)
    Common:registerScriptMask(self.Image_bg, function() 
        self:removeFromParent()
    end)

    self.ScrollView_playList:removeAllChildren()
    local index = 0
    for i,v in ipairs(self.clubData.wKindID) do
        local gameinfo = StaticData.Games[v]
        if v ~= 0 and gameinfo then
            index = index + 1
            local btn = self.Button_playItem:clone()
            self.ScrollView_playList:addChild(btn)
            local row = index % 2
            if row == 0 then
                row = 2
            end
            local col = math.ceil(index / 2)
            local x = 106 + (col - 1) * 284
            local y = 270 - (row - 1) * 100
            btn:setPosition(x, y)

            if self.clubData.szParameterName[i] ~= "" and self.clubData.szParameterName[i] ~= " " then
                btn:setTitleText(self.clubData.szParameterName[i])
            else
                local kindid = self.clubData.wKindID[i]
                btn:setTitleText(StaticData.Games[kindid].name)
            end

            btn:setPressedActionEnabled(true)
            btn:addClickEventListener(function(sender)
                require("common.Common"):playEffect("common/buttonplay.mp3")
                if i <= waynum then
                    for _,v in ipairs(tables) do
                        if v.data and v.data.wTableSubType == self.clubData.dwPlayID[i] then
                            local data = v.data
                            local wKindID = math.floor(data.dwTableID/10000)
                            if (wKindID == 51 or wKindID == 53 or wKindID == 55 or wKindID == 56 or wKindID == 57 or wKindID == 58 or wKindID == 59) and data.tableParameter.bCanPlayingJoin == 1 and data.wCurrentChairCount < data.wChairCount  then
                                require("common.SceneMgr"):switchTips(require("app.MyApp"):create(v.data.dwTableID):createView("InterfaceJoinRoomNode"))
                                return
                            elseif data.bIsGameStart == false and data.wCurrentChairCount < data.wChairCount then
                                require("common.SceneMgr"):switchTips(require("app.MyApp"):create(v.data.dwTableID):createView("InterfaceJoinRoomNode"))
                                return
                            end
                        end
                    end
                    require("common.SceneMgr"):switchTips(require("app.MyApp"):create(-2,self.clubData.dwPlayID[i],self.clubData.wKindID[i],self.clubData.wGameCount[i],self.clubData.dwClubID,self.clubData.tableParameter[i]):createView("InterfaceCreateRoomNode"))
                else
                    for i,v in ipairs(tables) do
                        if v.data and v.data.dwTableID then
                            if v.data.bIsGameStart == false and v.data.wCurrentChairCount < v.data.wChairCount then
                                require("common.SceneMgr"):switchTips(require("app.MyApp"):create(v.data.dwTableID):createView("InterfaceJoinRoomNode"))
                                return
                            end
                        end
                    end
                    require("common.MsgBoxLayer"):create(0,nil,'没有桌子')
                end
            end)
        end
    end
end

function NewClubQuickRoomLayer:onClose()
    self:removeFromParent()
end

return NewClubQuickRoomLayer