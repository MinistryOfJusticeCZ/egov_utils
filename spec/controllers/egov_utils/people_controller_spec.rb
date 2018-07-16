require 'rails_helper'

module EgovUtils
  RSpec.describe PeopleController, type: :controller do
    routes { EgovUtils::Engine.routes }

    describe '#index - search' do
      let(:pavel) { FactoryBot.create(:natural_person, natural_attributes: {firstname: 'Pavel', lastname: 'Hron'}) }
      let(:franta) { FactoryBot.create(:natural_person, natural_attributes: {firstname: 'Franta', lastname: 'Hron'}) }

      context 'with logged user', logged: true do
        it 'finds person by name' do
          pavel; franta
          get :index, params: {type: '_query', q: 'Pavel Hron', format: 'json'}
          expect(response).to be_successful
          json_response = JSON.parse(response.body)
          expect(json_response.count).to eq(2)
        end
        it 'finds person by firstname' do
          pavel; franta
          get :index, params: {type: '_query', q: 'Pavel', format: 'json'}
          expect(response).to be_successful
          json_response = JSON.parse(response.body)
          expect(json_response.count).to eq(1)
        end
        it 'finds person by lastname' do
          pavel; franta
          get :index, params: {type: '_query', q: 'Hron', format: 'json'}
          expect(response).to be_successful
          json_response = JSON.parse(response.body)
          expect(json_response.count).to eq(2)
        end
      end
    end

  end
end
