require "yaml"

module Servicesregistry
  class Adapter
    
    def initialize(service, master, adapter_url)
      @service_name = service[:name]
      @service_uuid = service[:uuid]
      @service_password = service[:password]
      @master_name = master[:name]
      @master_password = master[:password]
      @adapter_url = adapter_url
    end
    
    # renew the services.yml under /config/services.yml
    # in the service
    # creates a Typhoeus::Request to the servicesmaster
    # returns new services.yml in json format
    # write new services.yml
    def renew
      request = Typhoeus::Request.new(@adapter_url, :method => :post, :body => "Renew services yml.",
                                      :params => 
                                        { 
                                          :service_name => @service_name, :service_uuid => @service_uuid, 
                                          :service_password => @service_password, :master_name => @master_name,
                                          :master_password => @master_password
                                        },
                                        :headers => { Accept: "application/json"}
                                      )
      request.run
      response = request.response
      if response.code == 200
        begin
          response = JSON.parse(response.body)
        rescue JSON::ParserError => e
          raise e
        end
        if response["status"] == 200
          File.open(File.join("config", "services.yml"), "w") { |f| f << response["message"] }
          
          config = YAML::load_file(File.join("config", "services.yml"))
          Servicesregistry::Registry.clear_services

          config["services"].each do |service|
            service_name = service[0]
            service_klass_name = service[1]["klass_name"]
            service_uuid = service[1]["uuid"]
            service_password = service[1]["password"]
            service_url = service[1]["environments"][ENV['RACK_ENV']]["url"]
            service = { :name => service_name, :klass_name => service_klass_name, :uuid => service_uuid, :password => service_password, :url => service_url }
            Servicesregistry::Registry.register(Servicesregistry::Service.new(service))
          end

        else
          puts "Services.yml could not be updated: #{response}"
        end
      end
      
    end

  end
end