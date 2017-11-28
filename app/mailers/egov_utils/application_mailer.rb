module EgovUtils
  class ApplicationMailer < ActionMailer::Base
    default from: 'noreply@justice.cz'
    layout 'mailer'
  end
end
