class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.admin == true
        can :manage, :all
    elsif user.admin == false
        can :read, User
        can :update, User, :id => user.id
        can [:read, :create], Event
        can :update, Event, :user_id => user.id
    else
        can [:read, :create], User
        can :read, Event
    end
  end
end
