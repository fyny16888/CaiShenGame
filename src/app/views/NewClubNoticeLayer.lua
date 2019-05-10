--[[
*名称:NewClubNoticeLayer
*描述:公告
*作者:admin
*创建日期:2018-06-14 18:07:55
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

local NewClubNoticeLayer      = class("NewClubNoticeLayer", cc.load("mvc").ViewBase)

function NewClubNoticeLayer:onConfig()
    self.widget             = {
        {"Image_frame"},
        {"Button_close", "onClose"},
        {"TextField_notice"},
        {"Button_save", "onSave"},
    }
end

function NewClubNoticeLayer:onEnter()
    EventMgr:registListener(EventType.RET_SETTINGS_CLUB,self,self.RET_SETTINGS_CLUB)
end

function NewClubNoticeLayer:onExit()
    EventMgr:unregistListener(EventType.RET_SETTINGS_CLUB,self,self.RET_SETTINGS_CLUB)
end

function NewClubNoticeLayer:onCreate(param)
    self.clubData = param[1]
    Log.d(self.clubData)
    Common:registerScriptMask(self.Image_frame, function() 
        self:removeFromParent()
    end)
    self.TextField_notice:setString(self.clubData.szAnnouncement)

    if self.clubData.dwUserID == UserData.User.userID or self:isAdmin(UserData.User.userID) then
        self.TextField_notice:setTouchEnabled(true)
        self.Button_save:setVisible(true)
    else
        self.TextField_notice:setTouchEnabled(false)
        self.Button_save:setVisible(false)
    end
end

function NewClubNoticeLayer:onClose()
    self:removeFromParent()
end

function NewClubNoticeLayer:onSave()
    self.isUseSave = false
    local noticeStr = self.TextField_notice:getString()
    if noticeStr ~= self.clubData.szAnnouncement then
        NetMgr:getLogicInstance():sendMsgToSvr(NetMsgId.MDM_CL_CLUB,NetMsgId.REQ_SETTINGS_CLUB3,"bdnsonsdod",
                5,self.clubData.dwClubID,32,nickName,isCustomRoom,256,noticeStr,0,bIsDisable,0)
        self.isUseSave = true
    end
    if not self.isUseSave then
        require("common.MsgBoxLayer"):create(0,nil,"设置信息没有变化")
    end
end

--是否是管理员
function NewClubNoticeLayer:isAdmin(userid, adminData)
    adminData = adminData or self.clubData.dwAdministratorID
    for i,v in ipairs(adminData or {}) do
        if v == userid then
            return true
        end
    end
    return false
end

--亲友圈设置返回
function NewClubNoticeLayer:RET_SETTINGS_CLUB(event)
    local data = event._usedata
    Log.d(data)
    if data.lRet ~= 0 then
        require("common.MsgBoxLayer"):create(0,nil,"设置亲友圈失败")
        return
    end
    require("common.MsgBoxLayer"):create(0,nil,"设置亲友圈成功")
    UserData.Guild:refreshClub(data.dwClubID)
    if self.isUseSave then
        self:removeFromParent()
    end
end

return NewClubNoticeLayer