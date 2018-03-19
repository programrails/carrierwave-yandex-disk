require 'yandex/disk'
require 'carrierwave/yandex/storage/error'

module CarrierWave
  module Storage
    module Yandex
      # The main functionality
      class Disk < Abstract
        # Stubs we must implement to create and save
        # files (here on Yandex.Disk)

        # Store a single file
        def store!(file)
          location = "/#{uploader.store_path}"
          location_path = "/#{uploader.store_dir}"

          unless yandex_disk_client.mkdir_p(location_path)
            raise CarrierWave::Storage::Yandex::Error,
                  "The folder '#{location_path}' was not created"
          end

          unless yandex_disk_client.put(file.path.to_s, location)
            raise CarrierWave::Storage::Yandex::Error,
                  "The file was not uploaded to the location '#{location}'"
          end

          make_public_res = yandex_disk_client.make_public(location)

          unless make_public_res[:public_url]
            raise CarrierWave::Storage::Yandex::Error,
                  "The file '#{location}' was not published"
          end

          public_url = ERB::Util.url_encode make_public_res[:public_url]

          file_id = { location: location, public_url: public_url }.to_json

          uploader.model.update_column uploader.mounted_as, file_id
        end

        # Retrieve a single file
        def retrieve!(file_id)
          file_id_hash = (JSON.parse file_id.gsub('=>', ':')).symbolize_keys

          public_url = file_id_hash[:public_url]

          location = file_id_hash[:location]

          CarrierWave::Storage::Yandex::Disk::File
            .new(public_url, location, yandex_disk_client)
        end

        def yandex_disk_client
          @yandex_disk_client ||= begin
            ::Yandex::Disk::Client.new(access_token: config[:access_token])
          end
        end

        private

        def config
          @config ||= {}

          @config[:access_token] ||= uploader.yandex_disk_access_token

          @config
        end
        # Helper class
        class File
          # alike http://www.rubydoc.info/gems/carrierwave/CarrierWave/Storage/Fog/File
          include CarrierWave::Utilities::Uri

          def initialize(public_url, location, yandex_disk_client)
            @public_url = public_url
            @location = location
            @yandex_disk_client = yandex_disk_client
          end

          def filename
            ::File.basename @location
          end

          def extension
            ::File.extname @location
          end

          def url
            query = 'https://cloud-api.yandex.net/v1/disk/public/resources/' \
            "download?public_key=#{@public_url}"
            uri = URI query
            res = Net::HTTP.get(uri)
            hash = JSON.parse(res)
            if hash['error']
              raise CarrierWave::Storage::Yandex::Error,
                    "Fetching the file url at '#{@location}' " \
                    "failed with the error: #{hash['error']}"
            else
              hash['href']
            end
          end

          def public_url
            CGI.unescape @public_url
          end

          def storage_path
            # deviation from http://www.rubydoc.info/gems/carrierwave/CarrierWave/Storage/Fog/File
            @location
          end

          def delete
            # Due to CarrierWave calling this method TWICE in a row (somewhy)
            # there is no point either to check the return values here
            # or try to RSpec test them
            @yandex_disk_client.delete @location
            @yandex_disk_client.delete(::File.dirname(@location))
          end
        end
      end
    end
  end
end
