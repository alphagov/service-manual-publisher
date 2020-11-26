/* globals dragula */

$(function () {
  var $topics = $('.js-topic-section-list')

  $topics.on('click', '.js-delete-list-group-item', function (e) {
    var $item = $(this).parents('.list-group-item')
    $item.find('.js-destroy').val('1')
    $item.hide()
    e.preventDefault()
  })

  // Set up dragula on the overall section list
  var sectionList = dragula($('.js-topic-section-list').get(), {
    moves: function (el, source, handle, sibling) {
      return $(handle).hasClass('js-topic-section-handle')
    }
  })

  sectionList.on('dragend', function () {
    $('.js-section-position').each(function (index) {
      $(this).val(index)
    })
  })

  // Individual instances of dragula for each section's guide list
  $('.js-guide-list').each(function () {
    var $guideList = $(this)
    var guideListDragula = dragula([this], {
      moves: function (el, source, handle, sibling) {
        return $(handle).hasClass('js-guide-handle')
      }
    })

    guideListDragula.on('dragend', function () {
      $guideList.find('.js-guide-position').each(function (index) {
        $(this).val(index)
      })
    })
  })
})
