###
# File: rooms-resource.service.coffee
###

Resource = (urlsService, http) ->
    service = {}

    service.list = (userId) ->
        url = urlsService.resolve("rooms")

        params = {user: userId}

        return http.get(url, params)
            .then (result) ->
                return {
                    list: Immutable.fromJS(result.data)
                    headers: result.headers
                }

    service.getRoomByName = (roomname) ->
        url = "#{urlsService.resolve("rooms")}/by_slug"

        httpOptions = {
            headers: {
                "x-disable-pagination": "1"
            }
        }

        params = {
            slug: roomname
        }

        return http.get(url, params, httpOptions)
            .then (result) ->
                return Immutable.fromJS(result.data)

    return () ->
        return {"rooms": service}

Resource.$inject = ["$tgUrls", "$tgHttp"]

module = angular.module("taigaResources2")
module.factory("tgRoomsResource", Resource)
