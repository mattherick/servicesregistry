module Servicesregistry
  module Rack
    module Middleware
      class Adapter
        
        ######### initializer #########################################################
        
        # normal rack middleware initializer
        # @config[:sr_adapter] => path which gets updates from the servicesmaster and
        # writes the services.yml new
        # Default sr_adapter => "/sr-adapter"
        # Each service, should provide this url - if this rack middleware is used
        def initialize(app, config = {})
          @app = app
          @config = config
          @config[:sr_adapter] ||= /^\/sr-adapter/
        end
      
        ###############################################################################
      
        # rack middleware call method
        def call(env)
          if env["PATH_INFO"] =~ @config[:sr_adapter]
            require "debugger"
            debugger
            begin
              request = ::Rack::Request.new(env)
              params = request.params
              
              # find service
              service = Servicesregistry.find(params["name"], params["uuid"])
              raise TypeError, "Service #{request.params["name"]} not found" unless service
              
              # check authentication status
              unless service.password == params["password"]
                raise UnauthorisedError, "Request is unauthorised, please provide valid access data"
              end

              # encoding/deconding stuff
              args = service.json_decode(params["args"])
              result_decoded = service.update_adapter(*args)
              result_encoded = service.json_encode({"result" => result_decoded})
              
              # rack middleware output
              rack_output(200, result_encoded)
              
            rescue TypeError => e
              rack_output(500, {"error" => "An error occurred => #{e.message}"}.to_json)
            rescue UnauthorisedError => e
              rack_output(500, service.encode({"error" => e}))
            rescue Exception => e
              rack_output(500, service.encode({"error" => e}))
            end
          else
            status, header, response = @app.call(env)
            [status, header, response]
          end
        end
      
        private
        
        def rack_output(status, message)
          [status, {'Content-Type' => 'application/json', 'Content-Length' => "#{message.length}"}, [message]]
        end
      
      end
    end
  end
end