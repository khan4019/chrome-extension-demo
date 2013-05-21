ImageSaver = angular.module("ImageSaver", ["ng"])

ImageSaver.controller "Popup", ($scope) ->
  $scope.images = []

  sortByWidth = (collection) ->
    _(collection).sortBy (img) -> -1 * img.width

  $scope.savedImages = ->
    saved = _($scope.images).select((img) -> img.saved) || []
    sortByWidth saved

  $scope.unsavedImages = ->
    unsaved = _($scope.images).reject((img) -> img.saved) || []
    console.log "before", unsaved
    out = sortByWidth unsaved
    console.log "after", out
    out

  $scope.saveImage = (img) ->
    img.saved = true
    payload = _.extend {}, img, _action: "saveImage"
    chrome.extension.sendMessage payload

  $scope.unsaveImage = (img) ->
    img.saved = false
    payload = _.extend {}, img, _action: "unsaveImage"
    chrome.extension.sendMessage payload

  chrome.extension.sendMessage _action: "fetchImages", (payload) ->
    [err, images] = payload
    console.log "payload", err, images
    $scope.$apply ->
      $scope.images = images
