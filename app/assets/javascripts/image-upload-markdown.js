// This is a modified version of https://github.com/stuartnelson3/blog/blob/master/public/js/script.js

function ImageUploadMarkdown(event){
  var that = this;

  this.init = function(){
    event.preventDefault();
    this.$textarea = $(event.currentTarget);
    var dataTransfer = event.originalEvent.dataTransfer;

    this.addUploadPlaceholders(dataTransfer);
    for (var i = 0; i < dataTransfer.files.length; i++) {
      var file = dataTransfer.files[i];
      this.handleFileUpload(file);
    }
  };

  this.addUploadPlaceholders = function(dataTransfer) {
    var placeholders = [];
    for (var i = 0; i < dataTransfer.files.length; i++) {
      var fileName = dataTransfer.files[i].name;
      placeholders.push(this.placeholderValue(fileName));
    }

    var selectionStart = this.$textarea[0].selectionStart;
    var uploadsPlaceholder = placeholders.join("\r\n");
    this.$textarea.val(
      [this.$textarea.val().slice(0, selectionStart), uploadsPlaceholder, this.$textarea.val().slice(selectionStart)].join('')
    );
  };

  this.replaceImageMarkdownPlaceholder = function(newValue, fileName){
    var oldPlaceholder = this.placeholderValue(fileName);
    this.$textarea.val(
      this.$textarea.val().replace(oldPlaceholder, newValue)
    );
  };

  this.placeholderValue = function(fileName) {
    return "![Uploading " + fileName + "...]()";
  };

  this.handleFileUpload = function(file) {
    var formData = new FormData();
    formData.append("format", "js");
    formData.append("file", file);

    formData.append("authenticity_token", $('meta[name="csrf-token"]').attr("content"));

    var request = new XMLHttpRequest();
    request.open("POST", "/uploads");

    request.onloadend = function(fileName) {
      return function(e) {
        if(e.currentTarget.status == 201){
          var filePath = e.currentTarget.response;
          that.replaceImageMarkdownPlaceholder("!["+fileName+"]("+filePath+")", fileName);
        } else {
          that.replaceImageMarkdownPlaceholder("", fileName);
          window.alert("File upload failure\n\n" + e.currentTarget.response);
        }
        that.$textarea.keyup();
      };
    }(file.name);

    request.send(formData);
  };

  return this;
}

$(document).on('drop', '.js-markdown-image-upload', function(e) {
  ImageUploadMarkdown(e).init();
});
