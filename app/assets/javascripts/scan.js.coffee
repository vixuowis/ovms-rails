# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  # $('#connect-good').hide()
  # $('#connect-bad').show()

  # $('#connect-status').click ->
  #   # $.read({
  #   #   # url: 'http://'+$('#current_address').val()+':3000/calloval'
  #   #   url: 'http://192.168.117.128:3000/calloval?c=1'
  #   #   type: 'jsonp'
  #   #   success: (response)->
  #   #     # alert('good')
  #   #     $('#connect-status').removeClass('btn-danger')
  #   #     $('#connect-status').addClass('btn-success')
  #   #   error:(response)->
  #   #     # alert('bad')
  #   #     $('#connect-status').removeClass('btn-success')
  #   #     $('#connect-status').addClass('btn-danger')
  #   # });
  #   alert('call')
    
  #   $.ajax({
  #     url: 'http://192.168.117.128:3000/calloval'
  #     type: 'json'
  #     success: (response) -> 
  #       alert "123"
  #   });

  query = window.location.search.substring(1)
  raw_vars = query.split("&")
  params = {}
  for v in raw_vars
    [key, val] = v.split("=")
    params[key] = decodeURIComponent(val)

  $('#clientlist').change ->
    current_report = $("#clientlist option:selected").val()
    window.open("?c="+current_report,"_self")

  $('#addModal').modal('hide')
  $('#editModal').modal('hide')
  $('#deleteModal').modal('hide')

  $('#add-client').click ->
    $('#addModal').modal('show')
  
  $('#edit-client').click ->
    $('#editModal').modal('show')

  $('#delete-client').click ->
    $('#deleteModal').modal('show')

  $('#add-save-change').click ->
    name = $('#add-f_targetname').val()
    address = $('#add-f_ipaddress').val()
    $.read({
      url: '/add_client?address='+address+'&name='+name
      success: (response)->
        alert("添加成功！")
        window.location.reload()
      error:(response)->
        alert("添加失败！")
        window.location.reload()
    });

  $('#edit-save-change').click ->
    name = $('#edit-f_targetname').val()
    address = $('#edit-f_ipaddress').val()
    $.read({
      url: '/edit_client?id='+$('#current_report').val()+'&address='+address+'&name='+name
      success: (response)->
        alert("修改成功！")
        window.location.reload()
      error:(response)->
        alert("修改失败！")
        window.location.reload()
    });

  $('#delete-save-change').click ->
    $.read({
      url: '/delete_client?id='+$('#current_report').val()
      success: (response)->
        alert("删除成功！")
        window.location.reload()
      error:(response)->
        alert("删除失败！")
        window.location.reload()
    });