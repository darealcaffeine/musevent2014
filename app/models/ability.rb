class Ability
  include CanCan::Ability

  # Sets all necessary permissions.
  #
  # According to specification, guest(not registered) users can view non-archive events and also venues and bands.
  # Registered users can additionally create and manage their own payments. Users with Admin rights can manage
  # everything.
  def initialize(user)
    user ||= User.new(role: 'guest')
    can :list, Event
    can :show, Event, state: %w(raising planned)
    can [:show, :list], Band
    can [:show, :list], Venue
    if user.user?
      can :create, Payment
      can [:show, :reserve, :destroy], Payment, user_id: user.id
    end
    if user.admin?
      can :manage, :all
    end
    if user.venue_manager?
      can :manage, Venue, user_id: user.id
      can :manage, Event, venue: user.venue
    end

  end
end
