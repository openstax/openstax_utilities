class DummyAccessPolicy
  cattr_accessor :last_action, :last_requestor, :last_resource

  def self.action_allowed?(action, requestor, resource)
    @@last_action = action
    @@last_requestor = requestor
    @@last_resource = resource
    true
  end
end