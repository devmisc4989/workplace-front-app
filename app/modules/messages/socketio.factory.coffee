
Socket = (@rootScope) ->
    socket = io.connect("http://localhost:8890")

    on: (eventName, callback) ->
        socket.on(eventName, callback)

    emit: (eventName, data) ->
        socket.emit(eventName, data)

Socket.$inject = ["$rootScope"]

module = angular.module("taigaMessages")
module.factory("tgSocket", Socket)
