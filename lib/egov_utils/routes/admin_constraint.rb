module EgovUtils
  class AdminConstraint
    def matches?(request)
      return false unless request.session[:user_id]
      user = EgovUtils::User.find request.session[:user_id]
      user && user.admin?
    end
  end
end
