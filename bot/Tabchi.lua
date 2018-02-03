json = dofile('./lib/JSON.lua')
serpent = dofile("./lib/serpent.lua")
local lgi = require ('lgi')
local notify = lgi.require('Notify')
notify.init ("Telegram updates")
require('./lib/lua-redis')
redis =  dofile("./lib/redis.lua")
bot_id = 0 -- bot id
http = require "socket.http"
https = require "ssl.https"
--require("./lib/TD")
sudo_id = {362270285,159127730,446287802} -- sudo id

function tdbot_update_callback(data)
	if (data._ == "updateNewMessage") or (data._ == "updateNewChannelMessage") then
		showedit(data.message,data)
		local msg = data.message
		print(msg)
	elseif (data._== "updateMessageEdited") then
		showedit(data.message,data)
		data = data
		local function Message(AliReza,Reza,Arshia)
			showedit(Reza,data)
		end
		assert (tdbot_function ({
			_ = "getMessage", 
			chat_id = data.chat_id, 
			message_id = data.message_id 
		}, Message, nil))
		assert (tdbot_function ({
			_ = "openChat", 
			chat_id = data.chat_id
		}, dl_cb, nil))
		assert (tdbot_function ({ 
			_ = 'openMessageContent', 
			chat_id = data.chat_id,
			message_id = data.message_id
		}, dl_cb, nil))
		assert (tdbot_function ({
			_="getChats", 
			offset_order="9223372036854775807", 
			offset_chat_id=0,
			limit=20
		}, dl_cb, nil))
	end
end

function dl_cb(arg, data)
end

function showedit(msg, data)
	if msg then
		if msg.chat_id then
			local id = tostring(msg.chat_id)
			if id:match('-100(%d+)') then
				chat_type = 'super'
			elseif id:match('^(%d+)') then
				chat_type = 'user'
			else
				chat_type = 'group'
			end
		end
		--------- Text Message --------
		local TabChi = msg.content.text
		function check_markdown(text) 
			str = text
			if str:match('_') then
				output = str:gsub('_',[[\_]])
			elseif str:match('*') then
				output = str:gsub('*','\\*')
			elseif str:match('`') then
				output = str:gsub('`','\\`')
			else
				output = str
			end
			return output
		end
		if msg.content._== "messageText" then
			Message_Type = 'text'
		end
		if msg.content.text then
			Message_Type = 'messageText'
		end
		if msg.content.caption then
			Message_Type = 'messageCaption'
		end
		if msg.content._ == "messageChatAddMembers" then
			Message_Type = 'AddUserTG'
		end
		if msg.content._ == "messageChatJoinByLink" then
			Message_Type = 'JoinedByLinkTG'
		end
		if msg.content._ == "messageDocument" then
			Message_Type = 'Document'
		end
		if msg.content._ == "messageSticker" then
			Message_Type = 'Sticker'
		end
		if msg.content._ == "messageAudio" then
			Message_Type = 'Audio'
		end
		if msg.content._ == "messageVoice" then
			Message_Type = 'Voice'
		end
		if msg.content._ == "messageVideo" then
			Message_Type = 'Video'
		end
		if msg.content._ == "messageAnimation" then
			Message_Type = 'Gif'
		end
		if msg.content._ == "messageLocation" then
			Message_Type = 'Location'
		end
		if msg.content._ == "messageForwardedFromUser" then
			Message_Type = 'messageForwardedFromUser'
		end
		if msg.content._ == "messageContact" then
			Message_Type = 'Contact'
		end
		if not msg.reply_markup and msg.via_bot_user_id ~= 0 then
			Message_Type = 'Markreed'
		end
		if msg.content.game then
			Message_Type = 'Game'
		end
		if msg.content._ == "messagePhoto" then
			Message_Type = 'Photo'
		end
		ViewMessages(msg.chat_id, {[0] = msg.id})
		ReadMark(msg.chat_id, msg.id)
		redis:incr('TotalMessages:'..bot_id)
		if msg.send_state._ == "messageIsSuccessfullySent" then
			return false 
		end
		if TabChi then
			local function cb(a,b,c)
			redis:set('bot_id',b.id)
		end
			GetMe(cb)
		end
		if TabChi then
			if is_sudo(msg) then
			
			else
			
			end
		end
        if not redis:get("AutoOpenChat:"..bot_id) or redis:ttl("AutoOpenChat:"..bot_id) == -2 then
			local open = redis:smembers("SuperGroup:"..bot_id)
			for k,v in pairs(open) do
				OpenChat(v)
				redis:setex("AutoOpenChat:"..bot_id, 3, true)
			end  
        end
		if msg.chat_id then
			local ID = tostring(msg.chat_id)
			if ID:match('-100(%d+)') then
				if not redis:sismember("SuperGroup:"..bot_id,msg.chat_id) then
					redis:sadd("SuperGroup:"..bot_id, msg.chat_id)
				end
			elseif ID:match('^-(%d+)') then
				if not redis:sismember("Group:"..bot_id,msg.chat_id) then
					redis:sadd("Group:"..bot_id, msg.chat_id)
				end
			elseif ID:match('') then
				if not redis:sismember("User:"..bot_id,msg.chat_id) then
					redis:sadd("User:"..bot_id, msg.chat_id)
				end
			else
				if not redis:sismember("SuperGroup:"..bot_id,msg.chat_id) then
					redis:sadd("SuperGroup:"..bot_id, msg.chat_id)
				end
			end
		end
		local JoinStats = (redis:get('JoinLink:'..bot_id) or 'no')
		if JoinStats == 'no' then
			JOINING = 'NO'
		else
			JOINING = 'YES'
		end
		local SGP = (redis:scard('SuperGroup:'..bot_id) or 0)
		local GP = (redis:scard('Group:'..bot_id) or 0)
		local U = (redis:scard('User:'..bot_id) or 0)
		local Link = (redis:scard('Links:'..bot_id) or 0)
		-----------------------------
		if TabChi and TabChi:match('^П (.*)') and is_sudo(msg) then
			local random = TabChi:match('П (.*)')
			SendMessage(msg.chat_id,random,'md')
		end
		if TabChi == 'وضعیت' and is_sudo(msg) then
			SendMessage(msg.chat_id,'• '..SGP..' سوپرگروه •\n• '..GP..' گروه •\n• '..U..' کاربر در پیوی •\n• '..Link..' لینک دریافتی •\n• '..JOINING..' وضعیت عضویت •','md')
		end
		if TabChi and TabChi:match('^فروارد (%d+)') and is_sudo(msg) then
			local random_sgp = TabChi:match('فروارد (%d+)')
			local FwdLimit = redis:ttl("FwdLimit:"..bot_id) or -2
			if FwdLimit == -2 then
				if tonumber(msg.reply_to_message_id) > 0 then
					if tonumber(random_sgp) <= tonumber(SGP) then
						function cb(a,b)
							local SGP = redis:srandmember('SuperGroup:'..bot_id, random_sgp)
							for k,Extra in pairs(SGP) do
								ForwardMessage(Extra, msg.chat_id,{[0] = b.id}, 1)
							end
							local TabChi = '• این پیام به تعداد گروه: '..random_sgp..' فروارد شد •'
							SendMessage(msg.chat_id, TabChi, 'md')
							redis:setex("FwdLimit:"..bot_id, 3600, true)
						end
						GetMessage(msg.chat_id, tonumber(msg.reply_to_message_id), cb)
					else
						SendMessage(msg.chat_id, '• ربات تبچی این تعداد گروه: '..random_sgp..' ندارد •', 'md')
					end
				else
					SendMessage(msg.chat_id, '• پیام ریپلی نشده •', 'md')
				end
			else
				SendMessage(msg.chat_id, '• محدوریت زمانی فعال است لطفا بعدا تلاش کنید •', 'md')
			end
		end
		---------- Add ----------
		if TabChi and TabChi:match('^(ادد) (%d+) (%d+)') and is_sudo(msg) then
			local match = {
				TabChi:match("^(ادد) (%d+) (%d+)")
			}
			local AddLimit = redis:ttl("AddLimit:"..bot_id) or -2
			if AddLimit == -2 then
				if tonumber(match[2]) <= tonumber(SGP) then
					function cb(a,b)
						local SGP = redis:srandmember('SuperGroup:'..bot_id, match[2])
						for k,Extra in pairs(SGP) do
							AddUser(Extra,tonumber(match[3]))
						end
						local TabChi = '• فرد با شناسه: '..match[3]..' به تعداد گروه: '..match[2]..' ادد شد •'
						SendMessage(msg.chat_id, TabChi, 'md')
						redis:setex("AddLimit:"..bot_id, 3600, true)
					end
					GetMessage(msg.chat_id, tonumber(msg.reply_to_message_id), cb)
				else
					SendMessage(msg.chat_id, '• ربات تبچی این تعداد گروه: '..random_sgp..' ندارد •', 'md')
				end
			else
				SendMessage(msg.chat_id, '• محدوریت زمانی فعال است لطفا بعدا تلاش کنید •', 'md')
			end
		end
		if TabChi == 'ریست' and is_sudo(msg) then
			redis:del("SuperGroup:"..bot_id)
			redis:del("Group:"..bot_id)
			redis:del("User:"..bot_id)
			SendMessage(msg.chat_id,'ربات تبچی ریست شد','md')
		end
		if TabChi == 'عضویت فعال' and is_sudo(msg) then
			if JoinStats == 'no' then
				redis:set('JoinLink:'..bot_id,'yes')
				SendMessage(msg.chat_id,'• عضویت فعال شد •','md')
			else
				SendMessage(msg.chat_id,'• عضویت فعال بود •','md')
			end
		end
		if TabChi == 'عضویت غیرفعال' and is_sudo(msg)then
			if JoinStats == 'yes' then
				redis:set('JoinLink:'..bot_id,'no')
				SendMessage(msg.chat_id,'• عضویت غیرفعال شد •','md')
			else
				SendMessage(msg.chat_id,'• عضویت غیرفعال بود •','md')
			end
		end
		if TabChi == 'ریستارت' and is_sudo(msg) then
			dofile('./bot/Tabchi.lua')
			--dofile("./lib/TD.lua")
			SendMessage(msg.chat_id,'• ربات دوباره راه اندازی شد •','md')
		end
		local JoinLink = (redis:get('JoinLink:'..bot_id) or 'no')
		if is_sudo(msg) then
			if TabChi and TabChi:match("https://telegram.me/joinchat/%S+") or TabChi and TabChi:match("https://t.me/joinchat/%S+") or TabChi and TabChi:match("https://t.me/joinchat/%S+") or TabChi and TabChi:match("https://telegram.dog/joinchat/%S+") or TabChi and TabChi:match("telegram.dog/joinchat/%S+") or TabChi and TabChi:match("telegram.me/joinchat/%S+") or TabChi and TabChi:match("t.dog/joinchat/%S+") or TabChi and TabChi:match("t.me/joinchat/%S+") or TabChi and TabChi:match("http://telegram.me/joinchat/%S+") or TabChi and TabChi:match("http://t.me/joinchat/%S+") or TabChi and TabChi:match("http://t.me/joinchat/%S+") or TabChi and TabChi:match("http://telegram.dog/joinchat/%S+")then
				local TabChi = TabChi:gsub("t.me","telegram.me")
				for link in TabChi:gmatch("(https://telegram.me/joinchat/%S+)") do
					if not redis:sismember("Links"..bot_id,link) then
						redis:sadd("Links:"..bot_id, link)
					end
				end
			end
		end
		local Limit = redis:ttl('JoinLimit:'..bot_id) or -2
		if JoinLink == 'yes' then
			if Limit == -2 then
				local Link = redis:srandmember("Links:"..bot_id) or 'notfound'
				if Link == 'notfound' then
				else
					ImportChatInviteLink(Link)
					redis:srem("Links:"..bot_id,Link)
					redis:setex('JoinLimit:'..bot_id, 120, true)
				end
			end
		end
	end
end

function is_sudo(msg)
	local var = false
	for v,user in pairs(sudo_id) do
		if user == msg.sender_user_id then
			var = true
		end
	end
	return var
end

function SendMessage(chat_id, text, parse)
    assert( tdbot_function ({
    	_ = "sendMessage",
    	chat_id = chat_id,
    	reply_to_message_id = 0,
    	disable_notification = 0,
    	from_background = 1,
    	reply_markup = nil,
    	input_message_content = {
    		_ = "inputMessageText",
    		text = text,
    		disable_web_page_preview = 1,
    		clear_draft = 0,
    		parse_mode = GetParse(parse),
    		entities = {}
    	}
    }, dl_cb, nil))

end

function GetParse(parse)
	if parse  == 'md' then
		return {_ = "textParseModeMarkdown"}
	elseif parse == 'html' then
		return {_ = "textParseModeHTML"}
	else
		return nil
	end
end

function ViewMessages(chat_id, message_ids)
  	tdbot_function ({
    	_ = "viewMessages",
    	chat_id = chat_id,
    	message_ids = message_ids
  }, dl_cb, nil)
end

function AddUser(chat_id, user_id)
  	tdbot_function ({
    	_ = "addChatMember",
    	chat_id = chat_id,
    	user_id = user_id,
    	forward_limit = 0
  	}, dl_cb, nil)
end

function ReadMark(chat_id, message_ids)
  	tdbot_function ({
    	_ = "ViewMessages",
    	chat_id = chat_id,
    	message_ids = message_ids
  	}, dl_cb, nil)
end

function GetMessage(chat_id, message_id, cb_function)
  	tdbot_function ({
    	_ = "getMessage",
    	chat_id = chat_id,
    	message_id = message_id
  	}, cb_function, nil)
end

function GetChats(offset_order, offset_chat_id, limit)
  	if not limit or limit > 20 then
    	limit = 20
  	end
	tdbot_function ({
	    _ = "getChats",
	    offset_order = offset_order or 9223372036854775807,
	    offset_chat_id = offset_chat_id or 0,
	    limit = limit
  	}, dl_cb, nil)
end

function GetMe(cb)
  	tdbot_function ({
    	_ = "getMe",
  	}, cb or dl_cb, nil)
end

function GetMeCb(extra, result)
	our_id = result.id
	print("Our id: "..our_id)
	file = io.open("./data/config.lua", "r") 
	config = ''
	repeat
		line = file:read ("*l")
		if line then
			line = string.gsub(line, "0", our_id)
			config = config.."\n"..line
		end
	until not line
		
	file:close()
	file = io.open("./data/config.lua", "w") 
	file:write(config)
	file:close()	
end

function OpenChat(chat_id)
	tdbot_function ({
    	_ = "openChat",
    	chat_id = chat_id
	}, dl_cb, nil)
end

function AddChatMember(chat_id, user_id)
	tdbot_function ({
		_ = "addChatMember",
		chat_id = chat_id,
		user_id = user_id,
		forward_limit = 50
	}, dl_cb, nil)
end

function Restrict(chat_id, user_id, Restricted, right) 
	local chat_member_status = {}
	if Restricted == 'Restricted' then
		chat_member_status = {
			is_member = right[1] or 1,
			restricted_until_date = right[2] or 0,
			can_send_messages = right[3] or 1,
			can_send_media_messages = right[4] or 1,
		    can_send_other_messages = right[5] or 1,
			can_add_web_page_previews = right[6] or 1
        }
		chat_member_status._ = 'chatMemberStatus' .. Restricted

		assert (tdbot_function ({
			_ = 'changeChatMemberStatus',
			chat_id = chat_id,
			user_id = user_id,
			status = chat_member_status
		}, dl_cb, nil))
	end
end

function GetChat(chat_id, cb)
	tdbot_function ({
    	_ = "getChat",
    	chat_id = chat_id
	}, cb or dl_cb, nil)
end

function ForwardMessage(chat_id, from_chat_id, message_id, from_background)
    tdbot_function ({
        _ = "forwardMessages",
		message_id = message_id,
        chat_id = chat_id,
        from_chat_id = from_chat_id,
        message_ids = message_id,
        disable_notification = 0,
        from_background = from_background
    }, dl_cb, nil)
end

function GetInputFile(file)
    if file:match('/') then
        infile = {_ = "InputFileLocal", path = file}
    elseif file:match('^%d+$') then
        infile = {_ = "InputFileId", id = file}
    else
        infile = {_ = "InputFilePersistentId", persistent_id = file}
    end
    return infile
end

function cbsti(a,b)

end

function ImportChatInviteLink(invitelink)
  assert (tdbot_function ({
    _ = "importChatInviteLink",
    invite_link = tostring(invitelink)
  }, dl_cb, nil))
end