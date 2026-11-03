class DeviseMailerPreview < ActionMailer::Preview
  def reset_password_instructions
    user = User.new(email: "ayako@example.com")
    Devise::Mailer.reset_password_instructions(user, "preview-token")
  end
end
