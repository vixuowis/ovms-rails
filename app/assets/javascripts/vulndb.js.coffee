# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  $('#sync').click ->
    $.read(
      '/sync_vuln'
      (response)->
        if response['success']
          alert("同步完毕!")
          window.location.reload()
        else
          alert("同步暂停!")
    );