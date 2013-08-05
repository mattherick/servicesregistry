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
    def self.by_name(name)
      instance.by_name(name)
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
    def register(service)
 #     services ||= []
      services << service
    end
    
    # get a service by a given name
    def by_name(name)
      services.detect { |s| s.name == name.to_sym }
    end
    
    ###############################################################################

  end
end