--[[
*名称:PHZSettingLayer
*描述:跑胡子设置
*作者:admin
*创建日期:2019-05-15 11:07:14
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

local PHZSettingLayer      = class("PHZSettingLayer", cc.load("mvc").ViewBase)

function PHZSettingLayer:onConfig()
    self.widget             = {
        {"Image_bg"},
        {"slider_1"},
        {"Image_effect", "onEffect"},
        {"Image_eClose"},
        {"slider_2"},
        {"Image_music", "onMusic"},
        {"Image_mClose"},
        {"Panel_right", "onRight"},
        {"Image_rightLight"},
        {"Panel_custom", "onCustom"},
        {"Image_customLight"},
        {"Panel_speed1", "onSpeed1"},
        {"Image_speedLight1"},
        {"Panel_speed2", "onSpeed2"},
        {"Image_speedLight2"},
        {"Panel_speed3", "onSpeed3"},
        {"Image_speedLight3"},
        {"Panel_speed4", "onSpeed4"},
        {"Image_speedLight4"},
        {"Panel_bg1", "onSelectBg1"},
        {"Image_bgLight1"},
        {"Panel_bg2", "onSelectBg2"},
        {"Image_bgLight2"},
        {"Panel_bg3", "onSelectBg3"},
        {"Image_bgLight3"},
        {"Panel_newVoice", "onNewVoice"},
        {"Image_newVoiceLight"},
        {"Panel_oldVoice", "onOldVoice"},
        {"Image_oldVoiceLight"},
        {"Button_dimiss", "onDimiss"},
        {"Button_relay", "onRelay"},
    }
end

function PHZSettingLayer:onEnter()
end

function PHZSettingLayer:onExit()
end

function PHZSettingLayer:onCreate()
	Common:registerScriptMask(self.Image_bg, function() 
        self:removeFromParent()
    end)

    local bgIndex = cc.UserDefault:getInstance():getIntegerForKey(Default.UserDefault_ZiPaipaizhuo,2)
    self:switchBg(bgIndex, 'init')
end

function PHZSettingLayer:onEffect()
end

function PHZSettingLayer:onMusic()
end

function PHZSettingLayer:onRight()
end

function PHZSettingLayer:onCustom()
end

function PHZSettingLayer:onSpeed1()
end

function PHZSettingLayer:onSpeed2()
end

function PHZSettingLayer:onSpeed3()
end

function PHZSettingLayer:onSpeed4()
end

function PHZSettingLayer:onSelectBg1()
	self:switchBg(0)
end

function PHZSettingLayer:onSelectBg2()
	self:switchBg(1)
end

function PHZSettingLayer:onSelectBg3()
	self:switchBg(2)
end

function PHZSettingLayer:onNewVoice()
end

function PHZSettingLayer:onOldVoice()
end

function PHZSettingLayer:onDimiss()
	require("common.MsgBoxLayer"):create(1,nil,"是否确定解散房间？",function()
        NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GR_USER,NetMsgId.REQ_GR_DISMISS_TABLE,"")
    end)
end

function PHZSettingLayer:onRelay()
	require("common.SceneMgr"):switchScene(require("app.MyApp"):create(true,true):createView("LoginLayer"),SCENE_LOGIN)
end

function PHZSettingLayer:switchBg(idx, flag)
	for i=0,2 do
    	local bgname = 'Image_bgLight' .. i+1
    	if i == idx then
    		self[bgname]:setVisible(true)
    	else
    		self[bgname]:setVisible(false)
    	end
    end

    if not flag then
    	cc.UserDefault:getInstance():setIntegerForKey(Default.UserDefault_ZiPaipaizhuo, idx)
    	local uiPanel_bg = ccui.Helper:seekWidgetByName(self:getParent(),"Panel_bg")
    	if uiPanel_bg then
    		uiPanel_bg:removeAllChildren()
        	uiPanel_bg:addChild(ccui.ImageView:create(string.format("phz/beijing_%d.jpg", idx)))
    	end
    end
end

return PHZSettingLayer