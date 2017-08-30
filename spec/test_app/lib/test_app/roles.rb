require 'egov_utils/user_utils/role'

class UserRole < EgovUtils::UserUtils::Role

  add 'user'

  def define_abilities(ability, user)
    ability.can :read, :all
    ability.cannot :read, EgovUtils::User
    ability.cannot :read, EgovUtils::Group
    ability.can :read, EgovUtils::User, id: user.id
  end

end


class AdminRole < EgovUtils::UserUtils::Role

  add 'admin'

  def define_abilities(ability, user)
    ability.can :manage, :all
  end

end


