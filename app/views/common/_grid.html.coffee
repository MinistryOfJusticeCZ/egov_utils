$ ->
  <%
    grid ||= schema.outputs.grid
    additional_params ||= {}
    create_attributes ||= {}
  %>

  after_modal_submit = (evt, data)->
    grid = $("#<%= grid_id %>").swidget()
    grid.dataSource.read()

  $('body').off 'egov:submitted', after_modal_submit
  $('body').on 'egov:submitted', '#modal', after_modal_submit

  <%# would be a bit cleaner to give the filled form to the shield grid create method, then send the form by ajax %>
  createRecord = (evt)->
    $.ajax('<%= new_polymorphic_path(schema.model, create_attributes.merge(format: :js)) %>')


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

  $('#<%= grid_id %>').shieldGrid({
    noRecordsText: '<%= t('label_no_records') %>'
    dataSource: {
      schema:
        fields:
          <% schema.available_columns.each do |column| %>
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
      remote: {
        read: {
          type: 'GET'
          url: '<%= polymorphic_path(schema.model, schema.to_param.merge(additional_params).merge(format: :json)) %>'
          dataType: 'json'
        }
        modify: {
          create: (items, success, error) ->
            newItem = items[0]
            $.ajax
              url: '<%= polymorphic_path(schema.model, format: :json) %>'
              type: 'POST'
              dataType: 'json'
              data: { <%= grid.model_name.name.underscore %>: newItem.data }
              complete: (xhr) ->
                if xhr.readyState == 4 and xhr.status == 201
                  newItem.data.id = xhr.responseJSON.id
                  success()
                  return
                error(xhr)
          # remove: (items, success, error) ->
          #   $.ajax(
          #     type: "DELETE"
          #     url: "<%= polymorphic_path(schema.model) %>/" + items[0].data.id + '.json'
          #     dataType: 'json'
          #   ).then(success, error)
        }
        operations: ['sort']
      }
    },
    columns: [
      <% schema.columns.each do |col| %>
      <%= raw column_for_grid(grid, col) %>
      <% end %>
      <% if can?(:update, schema.model) || can?(:destroy, schema.model) %>
      {
        width: 150
        title: " "
        buttons: [
          <% if can?(:update, schema.model) %>
          {cls: 'btn btn-sm btn-primary', caption: '<%= t('label_edit') %>', click: editRecord},
          <% end %>
         <%= additional_grid_edit_buttons(schema) %>
          # <% if can?(:destroy, schema.model) %>
          # {commandName: 'delete', caption: '<%= t('label_delete') %>'}
          # <% end %>
        ]
      }
      <% end %>
    ],
    sorting:
      multiple: false
    editing:
      enabled: <%= can?(:update, schema.model) || can?(:destroy, schema.model) %>
      type: 'row'
    <% if local_assigns[:detail_for] %>
    events:
      detailCreated: detailCreated
    <% end %>
    <% if can? :create, schema.model %>
    toolbar: [
      {
        buttons: [
          { cls: 'btn btn-primary', caption: '<%= t('helpers.submit.create', model: grid.model_name.human) %>', click: createRecord }
        ],
        position: 'top'
      }
    ]
    <% end %>
  });

  destroy_evt_method = (evt)->
    $('#<%= grid_id %>').shieldGrid('destroy')
    $(document).off 'turbolinks:before-cache', destroy_evt_method
  $(document).on 'turbolinks:before-cache', destroy_evt_method
