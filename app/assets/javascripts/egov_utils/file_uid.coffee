$ = jQuery

$.widget 'egov_utils.fileUid',
  options:
    available_agendas: ['T', 'TN']

  _create: ()->
    that = this

    @container = $('<span></span>', class: 'egov-file-uid', style: 'position: relative; display: block;')
    @file_uid_gui = @_create_file_uid_gui()

    @container.insertAfter(@element)
    @container.append(@element).append(@file_uid_gui)

    @element.css(position: 'absolute', top: 0, left: 0, 'background-color': 'transparent')
    @element.attr('tabindex', -1)

    @form = @element.closest('form')
    # @form.on 'submit', (evt)->
    #   that.element.val(that.getValue())

    if @element.val() != ''
      this.setValue( @element.val() )

    @file_uid_gui.on 'change', ':input', (evt)->
      evt.stopPropagation();
      that.element.val( that.getValue() )
      that.element.trigger('change')

  _destroy: ()->
    @element.attr('style', '')
    @element.insertAfter(@container)
    @container.remove()


  _create_file_uid_gui: (default_value)->
    container = $('<div></div>', class: 'court_file_uid input-group')
    @parts = [
      $('<input type="text" name="senat" class="form-control senat"><input type="hidden" value="-">'),
      $('<select type="text" name="agenda" class="form-control agenda"></select>'),
      $('<input type="hidden" value="-"><input type="text" name="cislo_pripadu" class="form-control cislo_pripadu"><div class="input-group-addon">/</div><input type="hidden" value="/">'),
      $('<input type="text" class="form-control">')
    ]
    for agenda in @options.available_agendas
      @parts[1].append('<option value="'+agenda+'">'+agenda+'</option>')

    for part in @parts
      container.append(part)
    container

  setValue: (value)->
    if value.indexOf('/') < 0
      console.warn('Value for file uid has to have a "/" in it')
      return false
    flvl_ary = value.split('/')
    @parts[@parts.length - 1].val(flvl_ary[1])
    slvl_ary = flvl_ary[0].split('-')
    if slvl_ary.length != 3
      console.warn('Value for file uid has to have 2times "-" in it')
      return false

    @file_uid_gui.find('.senat').val(slvl_ary[0])
    @file_uid_gui.find('.agenda').val(slvl_ary[1])
    @file_uid_gui.find('.cislo_pripadu').val(slvl_ary[2])

  getValue: ()->
    value = ''
    @file_uid_gui.find(':input').each (i, part)->
      value += $(part).val()
    value
