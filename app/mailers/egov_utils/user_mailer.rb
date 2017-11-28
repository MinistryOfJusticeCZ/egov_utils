module EgovUtils
  class UserMailer < ApplicationMailer

    def confirmation_email(user)
      @user = user
      mail(to: user.mail, subject: t(:app_name))
    end

  end
end
