--[[
*名称:MJSettingLayer
*描述:麻将设置
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

local MJSettingLayer      = class("MJSettingLayer", cc.load("mvc").ViewBase)

function MJSettingLayer:onConfig()
    self.widget             = {
        {"Image_bg"},
        {"slider_1"},
        {"Image_effect", "onEffect"},
        {"slider_2"},
        {"Image_music", "onMusic"},
        {"Panel_cardbg1", "onCardBg1"},
        {"Image_cardLight1"},
        {"Panel_cardbg2", "onCardBg2"},
        {"Image_cardLight2"},
        {"Panel_cardbg3", "onCardBg3"},
        {"Image_cardLight3"},
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

function MJSettingLayer:onEnter()
end

function MJSettingLayer:onExit()
end

function MJSettingLayer:onCreate(param)
	self.parentNode = param[1]
	Common:registerScriptMask(self.Image_bg, function() 
        self:removeFromParent()
    end)

	-- 声效
    self.music = Music:getVolumeMusic()
	self.effectMusic = Music:getVolumeSound()
	self:registerSliderEvent()

	--拍背
    local cardIndex = cc.UserDefault:getInstance():getIntegerForKey('mj_cardbg', 2)
    self:switchCardBg(cardIndex)

	--背景
    local bgIndex = cc.UserDefault:getInstance():getIntegerForKey(Default.UserDefault_ZiPaipaizhuo,2)
    self:switchBg(bgIndex, 'init')

    --语音
    local voiceIdx = cc.UserDefault:getInstance():getIntegerForKey('mj_voice', 0)
    self:switchVoice(voiceIdx)
end

-- 音效
function MJSettingLayer:onEffect()
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
function MJSettingLayer:onMusic()
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

function MJSettingLayer:onCardBg1()
	self:switchCardBg(0)
end

function MJSettingLayer:onCardBg2()
	self:switchCardBg(1)
end

function MJSettingLayer:onCardBg3()
	self:switchCardBg(2)
end

function MJSettingLayer:onSelectBg1()
	self:switchBg(0)
end

function MJSettingLayer:onSelectBg2()
	self:switchBg(1)
end

function MJSettingLayer:onSelectBg3()
	self:switchBg(2)
end

function MJSettingLayer:onNewVoice()
	self:switchVoice(0)
end

function MJSettingLayer:onOldVoice()
	self:switchVoice(1)
end

function MJSettingLayer:onDimiss()
	require("common.MsgBoxLayer"):create(1,nil,"是否确定解散房间？",function()
        NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GR_USER,NetMsgId.REQ_GR_DISMISS_TABLE,"")
    end)
end

function MJSettingLayer:onRelay()
	require("common.SceneMgr"):switchScene(require("app.MyApp"):create(true,true):createView("LoginLayer"),SCENE_LOGIN)
end

function MJSettingLayer:registerSliderEvent()
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

function MJSettingLayer:updateMusic(  )
	local press = self.Image_music:getChildByName('Image_close')
	press:setVisible(not self.isMusic)
end

function MJSettingLayer:updateEffectMusic( ... )
	local pressSec = self.Image_effect:getChildByName('Image_close')
	pressSec:setVisible(not self.isEffMusic)
end

function MJSettingLayer:switchCardBg(idx)
	for i=0,2 do
    	local bgname = 'Image_cardLight' .. i+1
    	if i == idx then
    		self[bgname]:setVisible(true)
    	else
    		self[bgname]:setVisible(false)
    	end
    end
    cc.UserDefault:getInstance():setIntegerForKey('mj_cardbg', idx)
end

function MJSettingLayer:switchBg(idx, flag)
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
        	uiPanel_bg:addChild(ccui.ImageView:create(string.format("mjtable/beijing_%d.png", idx)))
    	end
    end
end

function MJSettingLayer:switchVoice(idx)
	cc.UserDefault:getInstance():setIntegerForKey('mj_voice', idx)
	if idx == 0 then
		self.Image_newVoiceLight:setVisible(true)
		self.Image_oldVoiceLight:setVisible(false)
	else
		self.Image_newVoiceLight:setVisible(false)
		self.Image_oldVoiceLight:setVisible(true)
	end
end

return MJSettingLayer