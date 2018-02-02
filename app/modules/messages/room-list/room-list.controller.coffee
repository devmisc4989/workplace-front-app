
taiga = @.taiga

class RoomListController
    @.$inject = [
        "$tgConfirm",
        "tgRoomsService",
        "$timeout",
        "$tgStorage",
        "tgCurrentUserService"
    ]
    constructor: (@confirm, @roomsService, @timeout, @storage, @currentUserService) ->
        taiga.defineImmutableProperty @, 'rooms', () => return @roomsService.rooms
        taiga.defineImmutableProperty @, 'loadingRooms', () => return @epicsService._loadingRooms    

    getRoomName: (room) ->
        currentUserId = @currentUserService.getUser().get('id');
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
        return room.get('project_extra_info').get('name')

angular.module("taigaMessages").controller("RoomListCtrl", RoomListController)
