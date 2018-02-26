ScrollBottomDirective = ($rootScope) ->
    link = (scope, element) ->
        scope.$watchCollection 'tgScrollBottom', (newValue, oldValue) ->
            if newValue && ((newValue[0] == oldValue[0])|| (oldValue.length == 0))
                setTimeout(
                    () ->
                        $(element).scrollTop $(element)[0].scrollHeight
                , 200)
            return

        container = angular.element(element)
        container.bind 'scroll', ->
            if (container.scrollTop() <= 0)
                $rootScope.$broadcast('fetchMessages', '')
        return        

    return {
        scope: {
            tgScrollBottom: '='
        },
        link: link
    }

ScrollBottomDirective.$inject = [
    "$rootScope"
]

angular.module('taigaMessages').directive("tgScrollBottom", ScrollBottomDirective)
