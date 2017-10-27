module EgovUtils
  module Helpers
    module Tags
      class FileuidField < ActionView::Helpers::Tags::TextField

        def render
          res = super
          res << @template_object.javascript_tag(javascript_str(@options))
          res
        end

        private
          def all_agendas
            ['T', 'Tm', 'INS', 'E'] # a dalsi
          end

          def javascript_str(options)
            agendas = all_agendas
            agendas &= @options.delete('agendas') if @options['agendas']
            index = name_and_id_index(options)
            tag_id = @options.fetch("id") { tag_id(index) }

            str = "$(function(){"
            str << "  $('##{tag_id}').fileUid({ available_agendas: #{ agendas.to_json } });"
            str << "  var destroy_evt_method = function(evt){"
            str << "    $('##{tag_id}').fileUid('destroy');"
            str << "    $(document).off('turbolinks:before-cache', destroy_evt_method);"
            str << "  };"
            str << "  $(document).on('turbolinks:before-cache', destroy_evt_method);"
            str << "});"
            str
          end

      end
    end
  end
end
