module Servicesregistry
  module Rack
    module Middleware
      class Adapter
        
        # define custom error class for authorization
        class UnauthorisedError < StandardError; end
        
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
            begin
              request = ::Rack::Request.new(env)
              params = request.params
              
              if params["shutdown"] == "true"
                exit!
              else

                # find service
                service = Servicesregistry.find(params["service_name"])
                raise TypeError, "Service #{request.params["service_name"]} not found" unless service
                
                # check authentication status
                unless service.password == params["service_password"] && service.uuid == params["service_uuid"] && params["master_name"] == "ServicesmasterFrick" && params["master_password"] == "secret"
                  raise UnauthorisedError, "Request is unauthorised, please provide valid access data"
                end
                
                # write new services.yml file under /config/services.yml of the current service
                File.open(File.join("config", "services.yml"), "w") { |f| f << params["new_content"] }
                rack_output(200, service.json_encode({"result" => "Renew services yml."}))
                
              end

            rescue TypeError => e
              rack_output(500, {"error" => "An error occurred => #{e.message}"}.to_json)
            rescue UnauthorisedError => e
              rack_output(500, service.json_encode({"error" => e}))
            rescue Exception => e
              rack_output(500, service.json_encode({"error" => e}))
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