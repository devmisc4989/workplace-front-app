

taiga = @.taiga

class MessagesService
    @.$inject = [
        'tgResources',
        'tgXhrErrorService',
        'tgAttachmentsService'
    ]

    constructor: (@resources, @xhrError, @attachmentsService) ->
        @.uploadingAttachments = []
        @.clear()

    clear: () ->
        @._loadingMessages = false

    sendMessage: (message) ->
        return @resources.messages.sendMessage(message)

    createMessage: (message) ->
        return @resources.messages.createMessage(message)

    publishMessage: (message) ->
        return @resources.messages.publishMessage(message)

    deleteMessage: (message) ->
        return @resources.messages.deleteMessage(message)

    addAttachment: (projectId, objId, type, file, editable = true, comment = false) ->
        return new Promise (resolve, reject) =>
            if @attachmentsService.validate(file)
                @.uploadingAttachments.push(file)
                
                promise = @attachmentsService.upload(file, objId, projectId, type, comment)
                promise.then (file) =>
                    @.uploadingAttachments = @.uploadingAttachments.filter (uploading) ->
                        return uploading.name != file.get('name')
                    resolve(file)
            else
                reject(new Error(file))

angular.module('taigaMessages').service('tgMessagesService', MessagesService)
