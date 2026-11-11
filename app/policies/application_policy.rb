# Everything is refused until a policy says otherwise: each policy opens only what it needs.
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index? = false

  def show? = false

  def create? = false

  def new? = create?

  def update? = false

  def edit? = update?

  def destroy? = false
end
