if not window.__category_builder_id_count
  window.__category_builder_id_count = 0

class @CategoryBuilder

  @new_id: ->
    window.__category_builder_id_count += 1
    return window.__category_builder_id_count

  # -- ID string creators --

  @field_id: (i) ->
    'field' + i

  @field_name_id: (i) ->
    @field_id(i) + '_name'

  @field_optional_id: (i) ->
    @field_id(i) + '_is_optional'

  @field_selectable_id: (i) ->
    @field_id(i) + '_is_selectable'

  @field_selectables_wrap_id: (i) ->
    @field_id(i) + '_selectables'

  @field_selectables_list_id: (i) ->
    @field_id(i) + '_selectables_list'

  @field_selectable_item_id: (fieldi, itemi) ->
    @field_id(fieldi) + '_s' + itemi

  @field_selectable_item_text_id: (fieldi, itemi) ->
    @field_id(fieldi) + '_s' + itemi + '_text'

  # -------------------------

  # -- Element creation methods --

  # Create initial visible form. Anchor it to an
  # element with id #category_builder_form_anchor
  @create_form: () ->
    html = "
<div class='category_builder_form'>
  <div class='form-group'>
    <div class='panel panel-default'>
      <div class='panel-heading'>
        <label>Category Fields</label>
        <a class='btn btn-success btn-xs pull-right' onclick='CategoryBuilder.add_field_container();' href='javascript:void(0);'>Add field</a>
      </div>
      <ul id='fields' class='list-group'>
      </ul>
    </div>
  </div>
</div>
    "
    $('#category_builder_form_anchor').append(html)

    fieldsjson = $('#category_fields').val()

    if fieldsjson != ''
      obj = $.parseJSON(fieldsjson)
      for k,v of obj
        fieldi = @add_field_container()
        $('#'+@field_name_id(fieldi)).val(k)
        if 'optional' of v
          $('#'+@field_optional_id(fieldi)).prop('checked', v['optional']);

        if 'select' of v
          $('#'+@field_selectable_id(fieldi)).prop('checked', true);
          $('#'+@field_selectables_wrap_id(fieldi)).show()
          for s in v['select']
            itemi = @add_empty_selectable_to(fieldi)
            $('#'+@field_selectable_item_text_id(fieldi, itemi)).val(s)

    sel = $('#category_parent_id')[0]

    if sel.selectedIndex > 0
      $.ajax(url: "/categories/#{sel.options[sel.selectedIndex].value}/ancestor_fields").done (html) ->
        if html.length > 0
          $('#inherited-fields').html("Inherited Fields: (#{html})")
    else
      $('#inherited-fields').html('')

  # Add a field container to the category
  @add_field_container: ->
    i = @new_id()
    html = "
<li id='#{@field_id(i)}' class='list-group-item'>
  <div class='form-group' style='margin-bottom:0;'>
    <div class='col-sm-3'>
      <input class='name_box form-control' id='#{@field_name_id(i)}' name='name' placeholder='Field name' type='text' value=''></input>
    </div>
    <div class='col-sm-1' style='width: auto'>
      <div class='checkbox'>
        <label>
          <input checked='checked' class='optional_box' id='#{@field_optional_id(i)}' name='optional' type='checkbox' value='Optional'></input>
          Optional
        </label>
      </div>
    </div>
    <div class='col-sm-2' style='width: auto'>
      <div class='checkbox'>
        <label>
          <input id='#{@field_selectable_id(i)}' onclick='CategoryBuilder.toggle_selectable(#{i});' name='selectable' type='checkbox' value='Select from list'></input>
          Select from list
        </label>
      </div>
    </div>
    <div class='col-sm-3 pull-right' style='width: auto'>
      <a class='btn btn-danger btn-xs' onclick='CategoryBuilder.remove_field_container(#{i});' href='javascript:void(0);'>Remove</a>
    </div>
  </div>
  <div class='form-group' id='#{@field_selectables_wrap_id(i)}' style='display: none; margin-bottom:0;'>
    <div class='col-sm-6'>
      <div class='panel panel-default' style='margin-bottom:0; margin-top: 10px;'>
        <div class='panel-heading'>
          <label>Selectable Items</label>
          <a class='btn btn-success btn-xs pull-right' onclick='CategoryBuilder.add_empty_selectable_to(#{i});' href='javascript:void(0);'><i class='fa fa-plus'></i></a>
        </div>
        <ul id='#{@field_selectables_list_id(i)}' class='list-group'></ul>
      </div>
    </div>
  </div>
</li>
        "
    $('#fields').append(html)
    return i

  # Remove the field container with the given id
  @remove_field_container: (i) ->
    $('#'+@field_id(i)).remove()

  # When a selectable checkbox is toggled, do the correct action
  @toggle_selectable: (i) ->
    if $('#'+@field_selectable_id(i)).is ':checked'
      $('#'+@field_selectables_wrap_id(i)).show()
      @add_empty_selectable_to(i)
    else
      $('#'+@field_selectables_list_id(i)).empty()
      $('#'+@field_selectables_wrap_id(i)).hide()


  # Add another blank item to a selectables list
  @add_empty_selectable_to: (i) ->
    selectables_list = $('#'+@field_selectables_list_id(i))
    c = @new_id()
    selectables_list.append("
        <li id='#{@field_selectable_item_id(i, c)}' class='list-group-item' style='padding: 3px;'>
            <div class='input-group input-group-sm'>
              <input id='#{@field_selectable_item_text_id(i, c)}'
                    class='selectable_item form-control'
                    type='text' value=''
                    name='item' />
              <span class='input-group-btn'>
                <a class='btn btn-default' onclick='CategoryBuilder.remove_sel_item(#{i}, #{c});' href='javascript:void(0);'>x</a>
              </span>
            </div>
        </li>"
    )
    return c

  # Remove the selectable with the given id
  @remove_sel_item: (i, id) ->
    # count items in selection set
    selectables_list = $('#'+@field_selectables_list_id(i))
    if selectables_list.children().length > 1
      $('#'+@field_selectable_item_id(i, id)).remove()
    else
      alert 'Cannot have an empty selection list.'

  # -------------------------------

  # -- Saving and Filling methods --
  @generate_params: ->
    fieldsdict = {}
    $('#fields').children().each (index, element) =>
      field = $(element)
      i = field.attr('id').substring(5)
      n = $('#'+@field_name_id(i)).val().trim()
      o = $('#'+@field_optional_id(i)).is ':checked'

      if n == ''
        alert 'Cannot save blank field names'
        return false

      fieldsdict[n] = {}
      fieldsdict[n]['optional'] = o

      s = $('#'+@field_selectable_id(i)).is ':checked'
      if s
        slist = []
        $('#'+@field_selectables_list_id(i)).children().each (index2, element2) =>
          t = $('#' + $(element2).attr('id') + '_text').val().trim()
          if t != ''
            slist.push $('#' + $(element2).attr('id') + '_text').val()

        if slist.length == 0
          alert 'Selection list must contain text items!'
          return false

        fieldsdict[n]['select'] = slist

    json = JSON.stringify(fieldsdict)
    console.log(json)
    # apply values to form fields
    $('#category_fields').val(json)

    return true

  @save: ->
    r = @generate_params()
    if r
      frm = $('#form-wrapper').children('form')[0]
      frm.submit()

  @getInheritedFields: (sel) ->
    if sel.selectedIndex > 0
      $.ajax(url: "/categories/#{sel.options[sel.selectedIndex].value}/ancestor_fields").done (html) ->
        if html.length > 0
          $('#inherited-fields').html("Inherited Fields: (#{html})")
    else
      $('#inherited-fields').html('')