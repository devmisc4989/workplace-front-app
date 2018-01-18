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
        @.lastMessageId = 1000000

        @socket.on 'message', (data) =>
            data.receivers.forEach (receiver) =>
                if receiver.id == @currentUserService.getUser().get('id')
                    if((data.sender.id != @currentUserService.getUser().get('id')) && (data.room == @currentRoom.get('id')))
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

        @.slug = @routeParams.slug
        @.currentRoom = ''
        @.roomTitle = ''
        @.roomProject = ''

        @.message_text = ''

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

    loadInitialData: () ->
        @roomsService.clear()
        @roomsService.fetchRooms()

        @resources.messages.getMessagesByRoom(@.slug, @.lastMessageId)
            .then (result) =>
                @._loadingMessages = false       
                @.messages = result.toJS().reverse()
                @.lastMessageId = if (@.messages[0]) then @.messages[0].id - 1 else 1000000
            .catch (xhr) =>
                @xhrError.response(xhr)

    getRoomName: (room) ->
        currentUserId = @currentUserService.getUser().get('id');
        users = room.get('users').filter (user) -> (user.get('id') != currentUserId)
        room_name = '';
        for i in [0...users.size]
            room_name += users.get(i).get('full_name') + ', '
        return room_name.substr(0, room_name.length - 2)
        
    getRoomProjectName: (room) ->
        return room.get('project_extra_info').get('name')

    sendMessage: (event) ->
        currentUserId = @currentUserService.getUser().get('id');
        if(event.which == 13)
            if(@.message_text)
                @messagesService.sendMessage({
                    room_slug: @.slug,
                    message: @.message_text
                })
                @.messages.push({
                    content: @.message_text,
                    sent_time: Math.floor(Date.now()),
                    sender: @currentUserService.getUser().toJS()
                })
            @.message_text = ''
            event.preventDefault()
            return false
        return true

angular.module("taigaMessages").controller("MessagesCtrl", MessagesController)
