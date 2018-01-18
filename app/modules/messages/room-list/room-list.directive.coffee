
RoomListDirective = () ->
    return {
        templateUrl:"messages/room-list/room-list.html",
        controller: "RoomListCtrl",
        controllerAs: "vm",
        bindToController: true,
        scope: {
            room: '='
        }
    }


angular.module('taigaMessages').directive("tgRoomList", RoomListDirective)
