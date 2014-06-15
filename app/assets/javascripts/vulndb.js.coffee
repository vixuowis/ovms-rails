# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  $('#sync-bar').hide()
  $('#sync').click ->
    $('#sync-bar').show()
    $('#sync-bar .bar').css("width","20%")
    $('#sync').attr("disabled",true)
    $('#sync').text("正在下载新条目……")
    $.read(
      '/sync_vuln?step=1'
      (response)->
        if response['success']
          $('#sync-bar .bar').css("width","60%")
          $('#sync').text("正在下载修订条目……")
          # alert("同步1完毕!")
          $.read(
            '/sync_vuln?step=2'
            (response)->
              if response['success']
                $('#sync-bar .bar').css("width","100%")
                $('#sync').text("同步完毕！")
                alert("同步完毕!")
                window.location.reload()
              else
                alert("同步暂停!")
          );
        else
          alert("同步暂停!")
    );