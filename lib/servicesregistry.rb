# version
require "servicesregistry/version"

# external gems
require "typhoeus"
require "active_model"
require "json"

# internal files
require "servicesregistry/rack/middleware/communication"
require "servicesregistry/service"
require "servicesregistry/registry"

module Servicesregistry
  
  # find a service by name and uuid
  def self.find(name, uuid)
    Registry.find(name, uuid)
  end
  
  # method missing
  # calls service.execute_communication
  def self.method_missing(method, *args, &block)
    if service = find(method)
      service.execute_communication(*args)
    else
      super(method, *args, &block)
    end
  end
  
end