class ApplicationMailer < ActionMailer::Base
  # One sender for every mail: the address configured for Devise.
  default from: proc { Devise.mailer_sender }
  layout "mailer"
  helper MailerHelper
end
