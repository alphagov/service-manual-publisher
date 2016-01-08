describe("Drag and drop image upload", function() {
  "use strict";

  var uploadableTextarea,
      mockDropEvent;

  beforeEach(function() {
    uploadableTextarea = $("<textarea class='js-markdown-image-upload'>First paragraph\n\nSecond paragraph</textarea>");

    $('body').append(uploadableTextarea);
    setCursorAfter("First paragraph\n");

    mockDropEvent = {
      preventDefault: function(){},
      currentTarget: $('body .js-markdown-image-upload'),
      originalEvent: {
        dataTransfer: {
          files: [{ name: "nice-pic.jpg"}]
        }
      }
    };

    jasmine.Ajax.install();
  });

  afterEach(function() {
    jasmine.Ajax.uninstall();
    uploadableTextarea.remove();
  });

  it("insert markdown of an uploaded image at the current cursor position", function() {
    jasmine.Ajax.stubRequest('/uploads').andReturn({
      response: 'http://asset-api.dev.gov.uk/nice-pic.jpg',
      status: '201'
    });

    var upload = new ImageUploadMarkdown(mockDropEvent);
    upload.init();
    var markdown = "First paragraph\n![nice-pic.jpg](http://asset-api.dev.gov.uk/nice-pic.jpg)\nSecond paragraph";
    expect($('body .js-markdown-image-upload').val()).toEqual(markdown);
  });

  it("show an alert and do not insert any markdown if upload fails", function() {
    jasmine.Ajax.stubRequest('/uploads').andReturn({
      response: 'File is too big',
      status: '422'
    });
    spyOn(window, 'alert');

    var upload = new ImageUploadMarkdown(mockDropEvent);
    upload.init();
    var markdown = "First paragraph\n\nSecond paragraph";

    expect(window.alert).toHaveBeenCalled();
    expect($('body .js-markdown-image-upload').val()).toEqual(markdown);
  });

  function setCursorAfter(value){
    var textarea = $('body textarea')[0];
    var cursorAt = value.length;
    textarea.selectionStart = cursorAt;
    textarea.selectionEnd = cursorAt;
  }
});
