$.namespace = {
  activeTabId: null,
  activateTab: (tabId)->
    if $.namespace.activateTabId
      $("##{$.namespace.activateTabId}").removeClass('selected')
    $("##{tabId}").addClass('selected')
    $.namespace.activateTabId = tabId
}

addSubmitHandlers = ->
  $(".errors").hide()
  $(".post-form form .button").click ->
    $(".errors").hide()
    form = $(this).closest('form')
    formData = form.serialize()
    request = $.ajax(
      type: "POST",
      url: "/posts",
      data: formData
      success: ->
        $('#flash').text('Posted successfully')
        form.clearForm()
        $("#feed").children().remove()
        new PostsPager()
      error: (response, status) ->
        resp = $.parseJSON(response.responseText)
        $(".errors", form).show()
        for error in resp.errors
          $(".errors_list", form).html "<li>#{error}</li>"
    )


addTabMenuHandler = ->
  $('.tab-item').click ->
    $.namespace.activateTab(this['id'])
    tabId = "#{this['id']}-tab".toLowerCase()
    $('.tab-body ul').children().hide()
    $("##{tabId}").show()

addPreviewHandler = ->
  $('#image_url').blur ->
    $('#image_preview').attr('src', $('#image_url').val()).show()

addHandlers = ->
  addSubmitHandlers()
  addPreviewHandler()
  addTabMenuHandler()

jQuery ->
  $('.tab-body ul').children().hide()
  $('.tab-body ul').children().first().show()
  
  addHandlers()
  $.namespace.activateTab('Text')
  new PostsPager()

class PostsPager
  constructor: (@page=-1)->
    $(window).scroll(@check)
    @render()

  check: =>
    if @nearBottom()
      @render()

  render: =>
    @page++
    $(window).unbind('scroll', @check)
    $.getJSON($('#feed').data('json-url'), page: @page, @renderPosts)

  nearBottom: =>
    $(window).scrollTop() > $(document).height() - $(window).height() - 50

  renderPosts: (response, status, jqXHR) =>
    posts = response['posts']
    for post in posts
      type = post["type"]
      $("#feed").append Mustache.to_html($("##{type}_template").html(), post)
    $(window).scroll(@check) if posts && posts.length > 0
    