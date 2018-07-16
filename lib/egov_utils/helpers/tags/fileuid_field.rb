module EgovUtils
  module Helpers
    module Tags
      class FileuidField < ActionView::Helpers::Tags::TextField

        def render
          res = super
          res << @template_object.javascript_tag(javascript_str(@options.stringify_keys))
          res
        end

        private
          def all_agendas
            %w(C Cd D Dt Dtm E EPR EVC EXE L Nc Nt Ntm P PP Rod Sd T Td Tm U)
          end

          def javascript_str(options)
            agendas = all_agendas
            agendas &= options.delete('agendas') if options['agendas']
            index = name_and_id_index(options)
            tag_id = options.fetch("id") { tag_id(index) }

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
