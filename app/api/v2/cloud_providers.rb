module V2
  class CloudProviders < Grape::API
    helpers V2::Helpers

    version 'v2'
    format :json

    resource :cloud_providers do
      before do
        api_enabled!
        authenticate!
	PaperTrail.request.whodunnit = params["idb_api_token"] ? params["idb_api_token"] : request.headers["X-Idb-Api-Token"] ? request.headers["X-Idb-Api-Token"] : nil
      end

      desc "Returns cloud providers by id, name or owner."
      get do
          can_read!

          m = nil
          case
          when params[:id]
            m = CloudProvider.find_by "id", params[:id]
          when params[:name]
            m = CloudProvider.where "name = ?", params[:name]
          when params[:owner]
            m = CloudProvider.where "owner_id = ?", params[:owner]
          else
            m = CloudProvider.all
          end

          if not m
            status 404
            return {}
          end

          status 200
          m
      end
    end
  end
end
