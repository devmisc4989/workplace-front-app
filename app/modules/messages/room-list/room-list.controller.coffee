
taiga = @.taiga

class RoomListController
    @.$inject = [
        "$scope",
        "$tgConfirm",
        "tgRoomsService",
        "$timeout",
        "$tgStorage",
        "tgSocket",
        "tgCurrentUserService",
        "tgResources"
    ]
    constructor: (@scope, @confirm, @roomsService, @timeout, @storage, @socket, @currentUserService, @resources) ->
        taiga.defineImmutableProperty @, 'rooms', () => return @roomsService.rooms
        taiga.defineImmutableProperty @, 'loadingRooms', () => return @epicsService._loadingRooms    

        @socket.on 'message', (data) =>
            data.receivers.forEach (receiver) =>
                if receiver.id == @currentUserService.getUser().get('id')
                    if((data.sender.id != @currentUserService.getUser().get('id')) && (data.room.slug != @.room))
                        if(@.unreadrooms[data.room.id])
                            @.unreadrooms[data.room.id] = @.unreadrooms[data.room.id] + 1
                        else
                            @.unreadrooms[data.room.id] = 1
                        angular.element('#new-message-'+data.room.id).show()
                        angular.element('#new-message-'+data.room.id).html(@.unreadrooms[data.room.id])
                        @roomsService.setUnreadRooms({
                            room_id: data.room.id,
                            user_id: @currentUserService.getUser().get('id'),
                            unread_count: @.unreadrooms[data.room.id],
                            room_slug: data.room.slug
                        })
                        return
            return

    getUnreadRooms: () ->
        @resources.rooms.getUnreadRooms(@currentUserService.getUser().get('id'), @.room)
            .then (result) =>
                rooms = result.toJS().reverse()
                for i in [0...rooms.length]
                    @.unreadrooms[rooms[i].room_id] = rooms[i].unread_count
                    angular.element('#new-message-'+rooms[i].room_id).show()
                    angular.element('#new-message-'+rooms[i].room_id).html(rooms[i].unread_count)

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
    
    getRoomMember: (room) ->
        currentUserId = @currentUserService.getUser().get('id');
        users = room.get('users').filter (user) -> (user.get('id') != currentUserId)
        return users.get(0)

    getRoomProjectName: (room) ->
        if room.get('public_room') == 1
            return "Public Chatting Room"
        else
            return room.get('project_extra_info').get('name')

    getUnreadMessage: (room) ->
        return 1 #(@.unreadrooms[room]) ? 0 : @.unreadrooms[room]

angular.module("taigaMessages").controller("RoomListCtrl", RoomListController)
