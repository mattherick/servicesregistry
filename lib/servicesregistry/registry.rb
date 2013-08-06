module Servicesregistry
  class Registry
    
    include Singleton
    
    ######### class methods #######################################################

    # register a new service
    def self.register(service)
      instance.register(service)
    end

    # get all registered services
    def self.services
      instance.services
    end
    
    # get a method by a given name
    def self.find(name, uuid)
      instance.find(name, uuid)
    end

    ###############################################################################

    ######### instance methods ####################################################

    # return all registered services 
    # to the services class method => Singleton
    # if empty, return empty array
    def services
      @services ||= []
    end

    # add a new service to the services
    # array => register new service
    # do not add if is already registered
    def register(service)
      raise "You can only register Servicesregistry::Service instances!" unless service.class == Servicesregistry::Service
      services << service unless services.include?(service)
    end
    
    # remove an existing service from the services
    # array => de-register this service
    # only do that if service was registered
    def de_register(service)
      services.delete(service) if services.include?(service)
    end
    
    # get a service by a given name
    def find(name, uuid)
      services.detect { |s| s.name == name.to_sym && s.uuid == uuid }
    end
    
    ###############################################################################

  end
end