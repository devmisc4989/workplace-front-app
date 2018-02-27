###
# File: rooms-resource.service.coffee
###

Resource = (urlsService, http) ->
    service = {}

    service.sendMessage = (message) ->
        url = "#{urlsService.resolve("rooms")}/send_message"
        params = message

        return new Promise (resolve, reject) =>
            promise = http.post(url, params)
            promise.then (result) =>
                resolve(Immutable.fromJS(result.data))
            promise.catch (error) =>
                reject(new Error(error))
        # return http.post(url, params)
        #     .then (result) ->
        #         return Immutable.fromJS(result.data)

    service.createMessage = (message) ->
        url = "#{urlsService.resolve("rooms")}/create_message"
        params = message

        return new Promise (resolve, reject) =>
            promise = http.post(url, params)
            promise.then (result) =>
                resolve(Immutable.fromJS(result.data))
            promise.catch (error) =>
                reject(new Error(error))

    service.publishMessage = (message) ->
        url = "#{urlsService.resolve("rooms")}/publish_message"
        params = message

        return new Promise (resolve, reject) =>
            promise = http.post(url, params)
            promise.then (result) =>
                resolve(Immutable.fromJS(result.data))
            promise.catch (error) =>
                reject(new Error(error))

    service.deleteMessage = (message) ->
        url = "#{urlsService.resolve("rooms")}/delete_message"
        params = message

        return new Promise (resolve, reject) =>
            promise = http.post(url, params)
            promise.then (result) =>
                resolve(Immutable.fromJS(result.data))
            promise.catch (error) =>
                reject(new Error(error))

    service.getMessagesByRoom = (room_slug, last_message_id) ->
        url = "#{urlsService.resolve("rooms")}/get_messages_by_room"

        httpOptions = {
            headers: {
                "x-disable-pagination": "1"
            }
        }

        params = {
            slug: room_slug
            last_message_id: last_message_id
        }

        return http.get(url, params, httpOptions)
            .then (result) ->
                return Immutable.fromJS(result.data)

    return () ->
        return {"messages": service}

Resource.$inject = ["$tgUrls", "$tgHttp"]

module = angular.module("taigaResources2")
module.factory("tgMessagesResource", Resource)
