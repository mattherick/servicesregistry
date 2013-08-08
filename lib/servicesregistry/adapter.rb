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
        else
          puts "Services.yml could not be updated: #{response}"
        end
      end
      
    end

  end
end