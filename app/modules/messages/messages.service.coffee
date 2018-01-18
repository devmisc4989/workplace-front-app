

taiga = @.taiga

class MessagesService
    @.$inject = [
        'tgResources',
        'tgXhrErrorService'
    ]

    constructor: (@resources, @xhrError) ->
        @.clear()

    clear: () ->
        @._loadingMessages = false

    sendMessage: (message) ->
        return @resources.messages.sendMessage(message)

angular.module('taigaMessages').service('tgMessagesService', MessagesService)
