require "rails_helper"

RSpec.describe ApplicationPolicy, type: :policy do
  subject(:policy) { described_class.new(User.new, Object.new) }

  %i[index? show? create? new? update? edit? destroy?].each do |action|
    it "refuses #{action} until a policy says otherwise" do
      expect(policy.public_send(action)).to be(false)
    end
  end
end
