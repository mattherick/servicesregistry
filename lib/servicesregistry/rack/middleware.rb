module Servicesregistry
  module Rack
    class Middleware
      
      ######### initializer #########################################################
      
      # normal rack middleware initializer
      # @config[:adapter_path] = path which gets all incoming soa requests from outside
      # Default adapter_path is "/soa-adapter"
      # Each service, should provide this url - if this rack middlware is used
      def initialize(app, config = {})
        @app = app
        @config = config
        @config[:adapter_path] ||= /^\/soa-adapter/
      end
      
      ###############################################################################

      # rack middlware call method
      def call(env)
        if env["PATH_INFO"] =~ @config[:endpoint_path]
          begin
            request = Rack::Request.new(env)
            params = request.params
            
            # find service
            service = Servicesregistry.find(params["name"])
            raise TypeError, "Service #{request.params["name"]} not found" unless service
            
            # check authentication status
            unless service.uuid == params["uuid"] && service.password == params["password"]
              raise UnauthorisedError, "Request is unauthorised, please provide valid access data"
            end
            
            # encoding/deconding stuff
            args = service.json_decode(params["args"])
            result_decoded = service.execute(*args)
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
            
        end
      end
      
      private
      
      def rack_output(status, message)
        [status, {'Content-Type' => 'application/json', 'Content-Length' => "#{message.length}"}, [message]]
      end

    end
  end
end