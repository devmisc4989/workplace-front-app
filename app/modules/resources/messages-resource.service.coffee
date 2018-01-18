###
# File: rooms-resource.service.coffee
###

Resource = (urlsService, http) ->
    service = {}

    service.sendMessage = (message) ->
        url = "#{urlsService.resolve("rooms")}/send_message"
        params = message

        return http.post(url, params)
            .then (result) ->
                return Immutable.fromJS(result.data)

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
