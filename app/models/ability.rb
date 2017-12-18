ActiveSupport::Reloader.to_prepare do
  begin
    require_dependency "#{Rails.application.class.parent_name.underscore}/roles"
  rescue LoadError => e
    Rails.logger.warn "!! You have not defined roles."
    Rails.logger.warn "!! Please define it in lib/#{Rails.application.class.parent_name.underscore}/roles."
    Rails.logger.warn "!! EgovUtils roles management will not work without it."
  end
end

class Ability
  include CanCan::Ability

  def initialize(user)
    can :create, EgovUtils::User if user.has_role?('anonymous') && EgovUtils::Settings.allow_register?

    user.all_roles.each do |role|
      role.define_abilities(self, user)
    end
  end
end
