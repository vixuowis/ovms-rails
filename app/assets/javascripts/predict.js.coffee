# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  $('#start').click ->
    $.read(
      '/learning'
      (response)->
        if response['success']
          alert("评估完毕!")
          window.location.reload()
        else
          alert("评估暂停!")
    );