// This is a modified version of https://github.com/stuartnelson3/blog/blob/master/public/js/script.js

function ImageUploadMarkdown (files) {
  var that = this

  this.init = function () {
    this.$textarea = $('.js-markdown-image-upload')

    this.addUploadPlaceholders()
    for (var i = 0; i < files.length; i++) {
      this.handleFileUpload(files[i])
    }
  }

  this.addUploadPlaceholders = function () {
    var placeholders = []
    for (var i = 0; i < files.length; i++) {
      var fileName = files[i].name
      placeholders.push(this.placeholderValue(fileName))
    }

    var selectionStart = this.$textarea[0].selectionStart
    var uploadsPlaceholder = placeholders.join('\r\n')
    this.$textarea.val(
      [this.$textarea.val().slice(0, selectionStart), uploadsPlaceholder, this.$textarea.val().slice(selectionStart)].join('')
    )
  }

  this.replaceImageMarkdownPlaceholder = function (newValue, fileName) {
    var oldPlaceholder = this.placeholderValue(fileName)
    this.$textarea.val(
      this.$textarea.val().replace(oldPlaceholder, newValue)
    )
  }

  this.placeholderValue = function (fileName) {
    return '![Uploading ' + fileName + '...]()'
  }

  this.handleFileUpload = function (file) {
    var formData = new FormData()
    formData.append('format', 'js')
    formData.append('file', file)

    formData.append('authenticity_token', $('meta[name="csrf-token"]').attr('content'))

    var request = new XMLHttpRequest()
    request.open('POST', '/uploads')

    request.onloadend = (function (fileName) {
      return function (e) {
        if (e.currentTarget.status == 201) { // eslint-disable-line eqeqeq
          var filePath = e.currentTarget.response
          that.replaceImageMarkdownPlaceholder('![' + fileName + '](' + filePath + ')', fileName)
        } else {
          that.replaceImageMarkdownPlaceholder('', fileName)
          window.alert('File upload failure\n\n' + e.currentTarget.response)
        }
        that.$textarea.keyup()
      }
    }(file.name))

    request.send(formData)
  }

  return this
}

$(document).on('click', '.js-markdown-file-input-trigger', function () {
  $('.js-markdown-file-input').click()
})

$(document).on('change', '.js-markdown-file-input', function (e) {
  ImageUploadMarkdown(e.target.files).init()
})

$(document).on('drop', '.js-markdown-image-upload', function (e) {
  e.preventDefault()
  ImageUploadMarkdown(e.originalEvent.dataTransfer.files).init()
})
