module EgovUtils
  module Helpers
    module Tags
      class FileuidField < ActionView::Helpers::Tags::TextField

        def render
          agendas = all_agendas
          agendas &= @options.delete('agendas') if @options['agendas']
          res = super
          index = name_and_id_index(@options)
          tag_id = @options.fetch("id") { tag_id(index) }
          res << @template_object.javascript_tag("$('##{tag_id}').fileUid({ available_agendas: #{ agendas.to_json } })")
          res
        end

        private
          def all_agendas
            ['T', 'Tm', 'INS', 'E'] # a dalsi
          end

      end
    end
  end
end
