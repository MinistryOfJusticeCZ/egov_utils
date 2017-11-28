module EgovUtils
  # Preview all emails at http://localhost:3000/rails/mailers/user
  class UserPreview < ActionMailer::Preview

    def confirmation_email
      UserMailer.confirmation_email(User.last)
    end

  end
end
