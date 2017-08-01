require 'egon_gate/egsb/messages/e37_vyhledej_adresu'

module EgovUtils
  class AddressesController < ApplicationController

    def validate_ruian
      # TODO: shoud be in some validator - external class
      addr_params = params.require(:address).permit(:city, :postcode, :street, :orientation_number, :house_number)
      address = Address.new(addr_params)
      if (address.city || address.postcode) && (( address.street && address.orientation_number ) || address.house_number)
        message = EgonGate::Egsb::Messages::E37VyhledejAdresu.new
        address.prepare_egon_message(message)
        kobra_reqest = EgonGate::Kobra::Request.new
        response = kobra_reqest.send_message(message)
        if response.error?
          respond_to do |format|
            format.json { render json: { error: response.error_message }, status: 404 }
          end
        else
          egon_address_info = message.parse_response( response.egsb_response )
          address.from_egon_info(egon_address_info)
          respond_to do |format|
            format.json { render json: address }
          end
        end
      else
        respond_to do |format|
          format.json { render json: { error: t(:error_not_found) }, status: 404 }
        end
      end
    end

  end
end
