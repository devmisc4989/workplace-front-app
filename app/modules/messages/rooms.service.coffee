

taiga = @.taiga

class RoomsService
    @.$inject = [
        'tgCurrentUserService',
        'tgResources',
        'tgXhrErrorService'
    ]

    constructor: (@currentUserService, @resources, @xhrError) ->
        @.clear()

        taiga.defineImmutableProperty @, 'rooms', () => return @._rooms

    clear: () ->
        @._loadingRooms = false
        @._rooms = Immutable.List()

    fetchRooms: (reset = false) ->
        @._loadingRooms = false
        return @resources.rooms.list(@currentUserService.getUser().get('id'))
            .then (result) =>
                if reset
                    @.clear()                    
                    @._rooms = result.list
                else
                    @._rooms = @._rooms.concat(result.list)

                @._loadingRooms = false
            .catch (xhr) =>
                @xhrError.response(xhr)

    getMessageRoomByName: (roomname) ->
        return @resources.rooms.getRoomByName(roomname)

    getUnreadRooms: (room_id) ->
        return @resources.rooms.getUnreadRooms(@currentUserService.getUser().get('id'), room_id)

    setUnreadRooms: (data) ->
        return @resources.rooms.setUnreadRooms(data)

angular.module('taigaMessages').service('tgRoomsService', RoomsService)
