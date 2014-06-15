# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  query = window.location.search.substring(1)
  raw_vars = query.split("&")
  params = {}
  for v in raw_vars
    [key, val] = v.split("=")
    params[key] = decodeURIComponent(val)
  
  # 态势评估
  $('#cb1').change ->
    params_temp = {};
    jQuery.extend(params_temp,params);
    if this.checked
      params_temp['predict'] = 1
    else
      params_temp['predict'] = 0
    href_temp = "?"+jQuery.param(params_temp)
    # alert(href_temp)
    window.open(href_temp,"_self")

  # 漏洞同步
  $('#cb2').change ->
    params_temp = {};
    jQuery.extend(params_temp,params);
    if this.checked
      params_temp['sync'] = 1
    else
      params_temp['sync'] = 0
    href_temp = "?"+jQuery.param(params_temp)
    # alert(href_temp)
    window.open(href_temp,"_self")

  # 漏洞同步
  $('#cb3').change ->
    params_temp = {};
    jQuery.extend(params_temp,params);
    if this.checked
      params_temp['sys'] = 1
    else
      params_temp['sys'] = 0
    href_temp = "?"+jQuery.param(params_temp)
    # alert(href_temp)
    window.open(href_temp,"_self")