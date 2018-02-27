taiga = @.taiga


class MessagesController
    @.$inject = [
        "$rootScope",
        "$scope",
        "tgErrorHandlingService",
        "tgRoomsService",
        "tgMessagesService",
        "tgAppMetaService",
        "$translate",
        "$routeParams",
        "tgXhrErrorService",
        "tgCurrentUserService",
        "tgSocket",
        "tgResources"
    ]

    constructor: (@rootScope, @scope, @errorHandlingService, @roomsService, @messagesService, @appMetaService, @translate, @routeParams, @xhrError, @currentUserService, @socket, @resources) ->

        @.sectionName = "MESSAGES.SECTION_NAME"
        @appMetaService.setfn @._setMeta.bind(this)

        @.messages = []
        @.lastMessageId = 10000000

        @.slug = @routeParams.slug
        @.currentRoom = ''
        @.roomTitle = ''
        @.roomProject = ''
        @.message_text = ''
        @.unread_rooms = {}
        @.current_unread_count = 0

        @socket.on 'message', (data) =>
            data.receivers.forEach (receiver) =>
                if receiver.id == @currentUserService.getUser().get('id')
                    if((data.sender.id != @currentUserService.getUser().get('id')) && (data.room.id == @.currentRoom.get('id')))
                        @scope.$apply () =>
                            @.messages.push(data)
                            return                        
            return

        @scope.$on 'fetchMessages', (evt, data) =>
            @resources.messages.getMessagesByRoom(@.slug, @.lastMessageId)
                .then (result) =>
                    _messages = result.toJS().reverse()
                    @.lastMessageId = if (_messages[0]) then _messages[0].id - 1 else 0
                    @.messages = _messages.concat(@.messages)
                .catch (xhr) =>
                    @xhrError.response(xhr)
            return

        if @routeParams.slug
            @roomsService
                .getMessageRoomByName(@routeParams.slug)
                .then (room) =>
                    if !room
                        @xhrError.notFound()
                    else
                        if room.size
                            @.currentRoom = room.get('0')
                            @.roomTitle = @.getRoomName(@.currentRoom)
                            @.roomProject = @.getRoomProjectName(@.currentRoom)
                            return room.get('0')
                        else
                            return room
                .catch (xhr) =>
                    return @xhrError.response(xhr)

        else
            @.currentRoom = ''

    _setMeta: () ->
        return null if !@.project

        ctx = {
            projectName: @.project.get("name")
            projectDescription: @.project.get("description")
        }

        return {
            title: @translate.instant("MESSAGES.PAGE_TITLE", ctx)
            description: @translate.instant("MESSAGES.PAGE_DESCRIPTION", ctx)
        }

    getUnreadRooms: () ->
        currentRoomSlug = @.slug
        @resources.rooms.getUnreadRooms(@currentUserService.getUser().get('id'), @.slug)
            .then (result) =>
                rooms = result.toJS().reverse()
                for i in [0...rooms.length]
                    if(rooms[i].room_slug != currentRoomSlug)
                        @.unread_rooms[rooms[i].room_id] = rooms[i].unread_count
                    else
                        @.current_unread_count = rooms[i].unread_count
    loadInitialData: () ->
        @.getUnreadRooms()
        @roomsService.clear()
        @roomsService.fetchRooms()

        @resources.messages.getMessagesByRoom(@.slug, @.lastMessageId)
            .then (result) =>
                @._loadingMessages = false       
                @.messages = result.toJS().reverse()
                @.lastMessageId = if (@.messages[0]) then @.messages[0].id - 1 else 10000000
            .catch (xhr) =>
                @xhrError.response(xhr)

    getRoomName: (room) ->
        currentUserId = @currentUserService.getUser().get('id');
        if room.get('public_room') == 1
            return room.get('name')
        else
            users = room.get('users').filter (user) -> (user.get('id') != currentUserId)
            room_name = '';
            for i in [0...users.size]
                room_name += users.get(i).get('full_name') + ', '
            return room_name.substr(0, room_name.length - 2)
        
    getRoomProjectName: (room) ->
        if room.get('public_room') == 1
            return ""
        else
            return room.get('project_extra_info').get('name')

    sendMessageByEnter: (event) ->
        @.current_unread_count = 0
        currentUserId = @currentUserService.getUser().get('id');
        if(event.which == 13)
            if(@.message_text)
                @messagesService.sendMessage({
                    room_slug: @.slug,
                    message: @.message_text,
                    message_type: 'text'
                })
                @.messages.push({
                    content: @.message_text,
                    sent_time: Math.floor(Date.now()),
                    sender: @currentUserService.getUser().toJS(),
                    message_type: 'text'
                })
            @.message_text = ''
            event.preventDefault()
            return false
        return true

    sendMessage: () ->
        @.current_unread_count = 0
        currentUserId = @currentUserService.getUser().get('id');
        if(@.message_text)
            @messagesService.sendMessage({
                room_slug: @.slug,
                message: @.message_text,
                message_type: 'text'
            })
            @.messages.push({
                content: @.message_text,
                sent_time: Math.floor(Date.now()),
                sender: @currentUserService.getUser().toJS(),
                message_type: 'text'
            })
        @.message_text = ''

    uploadingAttachments: () ->
        return @messagesService.uploadingAttachments

    addAttachment: (fileList) ->
        @.current_unread_count = 0
        project_id = @.currentRoom.get('project')
        if (fileList.length) 
            file = fileList[0]
            @messagesService.createMessage({
                room_slug: @.slug,
                message: file.name,
                message_type: 'attachment'
            }).then (result) =>
                @messagesService.addAttachment(project_id, result.get('id'), 'message', file, false)
                .then (resp) =>
                    attached = resp;
                    @.messages.push({
                        content: file.name,
                        sent_time: Math.floor(Date.now()),
                        sender: @currentUserService.getUser().toJS(),
                        message_type: 'attachment',
                        attachment:{
                            url: attached.get('url')
                        }
                    })
                    @messagesService.publishMessage({
                        id: result.get('id')
                    })
                .catch () =>
                    @messagesService.deleteMessage({
                        id: result.get('id')
                    })

angular.module("taigaMessages").controller("MessagesCtrl", MessagesController)
