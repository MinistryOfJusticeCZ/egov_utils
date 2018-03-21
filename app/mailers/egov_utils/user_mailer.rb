module EgovUtils
  class UserMailer < ApplicationMailer

    def confirmation_email(user)
      @user = user
      mail(to: user.mail, subject: t(:app_name))
    end

    def account_information(user, password)
      @user = user
      @password = password
      mail(to: user.mail, subject: t(:app_name))
    end

    def password_reset(user, token)
      @user, @token = user, token
      mail(to: user.mail, subject: t(:app_name))
    end

    def password_change_info(user)
      @user = user
      mail(to: user.mail, subject: t(:app_name))
    end

  end
end
