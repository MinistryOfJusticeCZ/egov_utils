Rails.application.routes.draw do
  mount EgovUtils::Engine => "/egov_utils"
end
