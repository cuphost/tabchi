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
	file = io.open("./data/config.lua", "r") --- You Can Use This Parameter
	config = ''
	repeat
		line = file:read ("*l")
		if line then
			line = string.gsub(line, "0", our_id)
			config = config.."\n"..line
		end
	until not line
		
	file:close()
	file = io.open("./data/config.lua", "w") --- Put Your Congfig Location
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

function Restrict(chat_id, user_id, Restricted, right) -- This Method Idea Is From CerNer Company ...
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