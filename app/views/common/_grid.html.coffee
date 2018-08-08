$ ->
  <%
    grid ||= schema.outputs.grid
    page_size ||= 50
    additional_params ||= {}
  %>

  after_modal_submit = (evt, data)->
    grid = $("#<%= grid_id %>").swidget()
    $("#<%= grid_id %>").trigger('grid:inserted', [data]);
    grid.dataSource.read()

  $('body').off 'egov:submitted', after_modal_submit
  $('body').on 'egov:submitted', '#modal', after_modal_submit


  editRecord = (index)->
    grid = $("#<%= grid_id %>").swidget()
    item = grid.dataItem(index)
    $.ajax('<%= polymorphic_path(schema.model) %>/'+item.id+'/edit.js')

<% if local_assigns[:detail_for] %>
  <% detail_col = schema.column(detail_for) %>
  detailCreated = (evt)->
    $("<div/>").appendTo(evt.detailCell).shieldGrid
      dataSource:
        remote:
          read:
            type: 'GET'
            url: '<%= polymorphic_path(schema.model) %>/'+evt.item.id+'<%= polymorphic_path(detail_for, format: :json) %>'
            dataType: 'json'
      paging:
        pageSize: 5
      columns: [
        <% detail_col.schema.columns.each do |col| %>
        <%= raw column_for_grid(detail_col.schema.outputs.grid, col) %>
        <% end %>
      ]
<% end %>

  dataSource = new shield.DataSource
    schema:
      data: 'entities'
      total: 'count'
      fields:
        <% grid_necessary_fields(schema).each do |column| %>
        <%= raw field_for_grid(column) %>
        <% end %>
    events:
      error: (event) ->
        if event.errorType == 'transport'
          alert("Write error: " + event.error.statusText )
          if event.operation == 'save'
            this.read()
        else
          alert( event.errorType + " error: " + event.error )
    remote:
      read:
        type: 'GET'
        url: '<%= polymorphic_path(schema.model, schema.to_param.merge(additional_params).merge(format: :json)) %>'
        dataType: 'json'
        data: (params)->
          dataObject = $.extend({}, params)
          dataObject.offset = params.skip if params.skip
          dataObject.limit = params.take if params.take
          delete dataObject.skip
          delete dataObject.take
          dataObject
      modify:
        remove: (items, success, error) ->
          $.ajax(
            type: "DELETE"
            url: "<%= polymorphic_path(schema.model) %>/" + items[0].data.id + '.json'
            dataType: 'json'
          ).then(success, error)
      operations: ['sort', 'skip', 'take']

  $('#<%= grid_id %>').shieldGrid({
    noRecordsText: '<%= t('label_no_records') %>'
    dataSource: dataSource,
    paging:
      pageSize: <%= page_size %>
      messages:
        infoBarTemplate: "<%= t('schema_outputs.shield_grid.paging.info_bar') %>"
        firstTooltip: "<%= t('schema_outputs.shield_grid.paging.tooltips.first') %>"
        previousTooltip: "<%= t('schema_outputs.shield_grid.paging.tooltips.previous') %>"
        nextTooltip: "<%= t('schema_outputs.shield_grid.paging.tooltips.next') %>"
        lastTooltip: "<%= t('schema_outputs.shield_grid.paging.tooltips.last') %>"
    columns: [
      <% schema.columns.each do |col| %>
      <%= raw column_for_grid(grid, col) %>
      <% end %>
      <% if can?(:update, schema.model) || (local_assigns.fetch(:allow_delete, false) && can?(:destroy, schema.model)) %>
      {
        width: 150
        title: "<%= t('label_actions') %>"
        buttons: [
          <% if can?(:update, schema.model) %>
          {cls: 'btn btn-sm btn-primary', caption: '<%= t('label_edit') %>', click: editRecord},
          <% end %>
          <%= additional_grid_edit_buttons(schema) %>
          <% if local_assigns.fetch(:allow_delete, false) && can?(:destroy, schema.model) %>
          {commandName: 'delete', caption: '<%= t('label_delete') %>'}
          <% end %>
        ]
      }
      <% end %>
    ],
    sorting:
      multiple: false
    editing:
      enabled: <%= can?(:update, schema.model) || can?(:destroy, schema.model) %>
      type: 'row',
      confirmation:
        "delete":
          enabled: true
          template: "<%= t('confirm_destroy', subject: '{'+schema.main_attribute_name+'}') %>"
    <% if local_assigns[:detail_for] %>
    events:
      detailCreated: detailCreated
    <% end %>
  });

  destroy_evt_method = (evt)->
    $('#<%= grid_id %>').shieldGrid('destroy')
    $(document).off 'turbolinks:before-cache', destroy_evt_method
  $(document).on 'turbolinks:before-cache', destroy_evt_method
