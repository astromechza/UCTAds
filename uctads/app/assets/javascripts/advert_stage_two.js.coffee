class @AdvertStageTwoBuilder

  @submit: ->
    fieldvals = {}
    $('.field-value-input').each (index, element) ->
      field = element.name
      value = element.value
      fieldvals[field] = value

    json = JSON.stringify(fieldvals)
    $('#advert_fieldvalues').val(json)

    frm = $('#form-wrapper').children('form')[0]
    frm.submit()

  @fillvalues: ->
    fieldvalsjson = $('#advert_fieldvalues').val()
    if fieldvalsjson != ''
      fieldvals = $.parseJSON(fieldvalsjson)
      for k,v of fieldvals
        name = '#field_' + k.replace(' ','__')
        $(name).val(v)

  @updatePriceField: ->
    ntype = $('#advert_price_type').val() != 'exact'
    $('#advert_price').prop('disabled', ntype)
    if ntype
      $('#advert_price').val('')

