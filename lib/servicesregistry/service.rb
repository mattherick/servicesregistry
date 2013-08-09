module Servicesregistry
  class Service
    include ActiveModel::Model
    
    ######### accessor stuff ######################################################
    
    # name => name of the service class to call
    attr_accessor :name
    
    # klass_name => class of the service class to call (incl. modules, etc.)
    attr_accessor :klass_name
    
    # uuid  => of the service to call
    attr_accessor :uuid
    
    # password  => of the service to call
    attr_accessor :password
    
    # for remote_calls
    # request_method => :get, :post, :put/:patch, :delete => for Typhoeus curl requests
    attr_accessor :request_method
    
    # rabbitmq => turn on/off messaging for the service call via rabbitmq amqp messaging
    # rabbitmq => name of the worker
    attr_accessor :rabbitmq
    
    # url => of the service call, for remote service calls
    attr_accessor :url
    
    # raw_url => incoming url with request_method prefixed
    attr_reader :raw_url
    
    ###############################################################################
    
    ######### validations #########################################################
    
    validates :name, :klass_name, :uuid, :password, :url, :presence => true
    
    ###############################################################################
    
    ######### initializer #########################################################
    
    # pass all necessary attributes as hash
    # => name, uuid, password, url
    # raw_url, request_method => not necessary => are set in the url setter
    def initialize(attributes = {})
      attributes.each do |name, value|
        send("#{name}=", value)
      end
      self.name = attributes[:name].to_sym
      self.request_method = attributes[:request_method].to_sym if attributes[:request_method]
    end
    
    ###############################################################################
    
    ######### instance methods ####################################################
    
    # override url setter, and set all url´s attributes
    # url_as_string => service location to call
    # raw_url can contain the request method
    # for example:
    # "GET http://www.my-service.com/callme"
    # "POST http://www.my-service.com/callme"
    def url=(url_as_string)
      @raw_url = url_as_string
      request_method = url_as_string[/^(GET|POST|PUT|PATCH|DELETE)/i, 0]
      @request_method = request_method ? request_method.downcase.to_sym : :post
      @url = url_as_string[/http.*/i, 0]
    end
    
    def communication_url
      "#{url}/sr-communication"
    end
    
    # call a remote service through a reqeust to the url
    def to_remote(*args)
      body = "this is a request body"
      headers = { "User-Agent" => "servicesregistry-frick", :Accept => "application/json" }
      followlocation = true
      request = Typhoeus::Request.new(self.communication_url, :method => self.request_method, 
                                      :body => body, :params => params(args), 
                                      :headers => headers, :followlocation => followlocation)
      request.run
      response = request.response
      return response.body
    end
    
    def to_rabbitmq(*args)
      # TODO implement
      raise "TODO implement rabbitmq messaging"
    end

    # executing calls:
    # => enqueue to rabbitmq messaging system => to_rabbitmq
    # => call a remote service over http      => to_remote
    # => call a local service directly        => send(:execute_communication)
    def execute(*args)
      if self.rabbitmq
        self.to_rabbitmq(*args)
        return nil
      else
        call = self.local_class ? local_class.send(:execute, *args) : self.to_remote(*args)
        return call
      end
    end

    # check if service, which will be called is a local class
    # or not => local service vs remote service
    def local_class
      begin
        self.klass_name.to_s.camelize.constantize
      rescue NameError => e
        false
      end
    end

    # prepare params for call
    # name => name of the soa class, which will be called
    # uuid => uuid of the soa class, which will be called
    # password => password of the soa class, which will be called
    # args => args for the soa class method
    def params(payload)
      { "name"    => name.to_s,
        "uuid"    => uuid.to_s,
        "klass_name"   => klass_name.to_s,
        "password"    => password,
        "args"    => json_encode(payload)
      }
    end

    # encode the given string to json format
    def json_encode(string)
      string.to_json
    end
    
    # decode the given string to json format
    def json_decode(string)
      begin
        JSON.parse(string)
      rescue JSON::ParserError => e
        raise e
      end
    end
      
    ###############################################################################

  end
end