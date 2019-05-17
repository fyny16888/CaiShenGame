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
local Music 				= require("app.user.UserData").Music

local PHZSettingLayer      = class("PHZSettingLayer", cc.load("mvc").ViewBase)

function PHZSettingLayer:onConfig()
    self.widget             = {
        {"Image_bg"},
        {"slider_1"},
        {"Image_effect", "onEffect"},
        {"slider_2"},
        {"Image_music", "onMusic"},
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

function PHZSettingLayer:onCreate(param)
	self.parentNode = param[1]
	Common:registerScriptMask(self.Image_bg, function() 
        self:removeFromParent()
    end)

	-- 声效
    self.music = Music:getVolumeMusic()
	self.effectMusic = Music:getVolumeSound()
	self:registerSliderEvent()

	--功能
	local funcIdx = cc.UserDefault:getInstance():getIntegerForKey('phz_function', 0)
	self:switchFuc(funcIdx)

	--出牌速度
	local speedIdx = cc.UserDefault:getInstance():getIntegerForKey('phz_speed', 1)
	self:switchSpeed(speedIdx)

	--背景
    local bgIndex = cc.UserDefault:getInstance():getIntegerForKey(Default.UserDefault_ZiPaipaizhuo,2)
    self:switchBg(bgIndex, 'init')

    --语音
    local voiceIdx = cc.UserDefault:getInstance():getIntegerForKey('phz_voice', 0)
    self:switchVoice(voiceIdx)
end

-- 音效
function PHZSettingLayer:onEffect()
	self.isEffMusic = not self.isEffMusic
	if self.isEffMusic then
		self.effectMusic = 100
	else
		self.effectMusic = 0
	end
	Music:setVolumeSound(self.effectMusic / 100)
	self.slider_1:setPercent(self.effectMusic)
	self:updateEffectMusic()
end

-- 音乐
function PHZSettingLayer:onMusic()
	self.isMusic = not self.isMusic
	if self.isMusic then
		self.music = 100
	else
		self.music = 0
	end
	Music:setVolumeMusic(self.music / 100)
	self.slider_2:setPercent(self.music)
	self:updateMusic()
end

function PHZSettingLayer:onRight()
	self:switchFuc(1)
end

function PHZSettingLayer:onCustom()
	self:switchFuc(0)
end

function PHZSettingLayer:onSpeed1()
	self:switchSpeed(1)
end

function PHZSettingLayer:onSpeed2()
	self:switchSpeed(2)
end

function PHZSettingLayer:onSpeed3()
	self:switchSpeed(3)
end

function PHZSettingLayer:onSpeed4()
	self:switchSpeed(4)
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
	self:switchVoice(0)
end

function PHZSettingLayer:onOldVoice()
	self:switchVoice(1)
end

function PHZSettingLayer:onDimiss()
	require("common.MsgBoxLayer"):create(1,nil,"是否确定解散房间？",function()
        NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GR_USER,NetMsgId.REQ_GR_DISMISS_TABLE,"")
    end)
end

function PHZSettingLayer:onRelay()
	require("common.SceneMgr"):switchScene(require("app.MyApp"):create(true,true):createView("LoginLayer"),SCENE_LOGIN)
end

function PHZSettingLayer:registerSliderEvent()
--音乐
	self.slider_2:setPercent(self.music * 100)
	self.slider_2:addEventListener(function(sender, eventType)
		local epsilon = sender:getPercent() / 100
		Music:setVolumeMusic(epsilon)
		self.music = epsilon
		if self.music > 0 then
			self.isMusic = true
		else
			self.isMusic = false
		end
		self:updateMusic()
	end)
	if self.music > 0 then
		self.isMusic = true
	else
		self.isMusic = false
	end
	self:updateMusic()

	--音效
	self.slider_1:setPercent(self.effectMusic * 100)
	self.slider_1:addEventListener(function(sender, eventType)
		local epsilon = sender:getPercent() / 100
		Music:setVolumeSound(epsilon)
		self.effectMusic = epsilon
		if self.effectMusic > 0 then
			self.isEffMusic = true
		else
			self.isEffMusic = false
		end
		self:updateEffectMusic()
	end)
	if self.effectMusic > 0 then
		self.isEffMusic = true
	else
		self.isEffMusic = false
	end
	self:updateEffectMusic()
end

function PHZSettingLayer:updateMusic(  )
	local press = self.Image_music:getChildByName('Image_close')
	press:setVisible(not self.isMusic)
end

function PHZSettingLayer:updateEffectMusic( ... )
	local pressSec = self.Image_effect:getChildByName('Image_close')
	pressSec:setVisible(not self.isEffMusic)
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
    	local uiPanel_bg = ccui.Helper:seekWidgetByName(self.parentNode,"Panel_bg")
    	if uiPanel_bg then
    		uiPanel_bg:removeAllChildren()
        	uiPanel_bg:addChild(ccui.ImageView:create(string.format("phz/beijing_%d.jpg", idx)))
    	end
    end
end

function PHZSettingLayer:switchFuc(idx)
	cc.UserDefault:getInstance():setIntegerForKey('phz_function', idx)
	if idx == 0 then
		self.Image_rightLight:setVisible(false)
		self.Image_customLight:setVisible(true)
	else
		self.Image_rightLight:setVisible(true)
		self.Image_customLight:setVisible(false)
	end
end

function PHZSettingLayer:switchSpeed(idx)
	cc.UserDefault:getInstance():setIntegerForKey('phz_speed', idx)
	for i=1,4 do
		if i == idx then
			self['Image_speedLight' .. i]:setVisible(true)
		else
			self['Image_speedLight' .. i]:setVisible(false)
		end
	end
end

function PHZSettingLayer:switchVoice(idx)
	cc.UserDefault:getInstance():setIntegerForKey('phz_voice', idx)
	if idx == 0 then
		self.Image_newVoiceLight:setVisible(true)
		self.Image_oldVoiceLight:setVisible(false)
	else
		self.Image_newVoiceLight:setVisible(false)
		self.Image_oldVoiceLight:setVisible(true)
	end
end

return PHZSettingLayer