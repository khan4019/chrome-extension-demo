if raw = localStorage.getItem("savedImages")
  savedImages = JSON.parse raw
else
  savedImages = {}

persist = ->
  localStorage.setItem "savedImages", JSON.stringify(savedImages)

chrome.extension.onMessage.addListener (payload, sender, cb) ->
  switch payload._action
    when "fetchImages"
      chrome.tabs.getSelected null, (tab) ->
        if /^chrome/.test tab.url
          out = []
          out.push img for key, img of savedImages
          cb [null, out]
        else
          chrome.tabs.sendMessage tab.id, _action: "fetchImages", (payload) ->
            [err, pageImages] = payload
            console.log "hit", pageImages, savedImages
            keys = Object.keys(savedImages)
            pageImages = _(pageImages).reject (img) -> _(keys).include img.src
            pageImages.push(img) for key, img of savedImages
            cb [err, pageImages]
      true

    when "saveImage"
      savedImages[payload.src] =
        src: payload.src
        width: payload.width
        height: payload.height
        saved: true
      persist()

    when "unsaveImage"
      delete savedImages[payload.src]
      persist()
