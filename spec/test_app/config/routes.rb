Rails.application.routes.draw do
  root to: 'dummy#index'

  mount EgovUtils::Engine => "/egov_utils"
end
