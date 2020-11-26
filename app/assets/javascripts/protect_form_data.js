$(function () {
  window.okToNavigateAway = false

  $('form.js-protect-data').each(function (_, form) {
    var $form = $(form)
    recordChecksum($form)
    $form.on('click', '.js-ok-to-navigate-away', function (evt) {
      window.okToNavigateAway = true
    })
  })

  window.onbeforeunload = function () {
    if (window.okToNavigateAway) {
      return undefined
    }

    forms = $('form.js-protect-data')
    for (var i = forms.length - 1; i >= 0; i--) {
      var form = forms[i]
      if (hasChanged($(form))) {
        return 'It looks like there are some unsaved changes in the form.\n\nLeaving the page will discard all unsaved changes.'
      }
    }
  }

  function hasChanged (form) {
    if (form) {
      var currentChecksum = checksum(form.serialize()).toString()
      var previousChecksum = form.attr('data-checksum')
      return currentChecksum != previousChecksum
    }
    return false
  }
})

function checksum (string) {
  var hashValue = 0; var i; var chr; var len
  if (string.length === 0) return hashValue
  for (i = 0, len = string.length; i < len; i++) {
    chr = string.charCodeAt(i)
    hashValue = ((hashValue << 5) - hashValue) + chr
    hashValue |= 0 // Convert to 32bit integer
  }
  return hashValue
}

function recordChecksum (form) {
  var checksumValue = checksum(form.serialize())
  form.attr('data-checksum', checksumValue)
}
