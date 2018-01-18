
Socket = (@rootScope) ->
    socket = io.connect("https://project.joinbrix.com")

    on: (eventName, callback) ->
        socket.on(eventName, callback)

    emit: (eventName, data) ->
        socket.emit(eventName, data)

Socket.$inject = ["$rootScope"]

module = angular.module("taigaMessages")
module.factory("tgSocket", Socket)
