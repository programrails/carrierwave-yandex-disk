require 'carrierwave'
require 'carrierwave/yandex/storage/disk'

require 'carrierwave/yandex/disk/version'

module CarrierWave
  module Uploader
    # The base class
    class Base
      add_config :yandex_disk_access_token

      configure do |config|
        config.storage_engines[:yandex_disk] =
          'CarrierWave::Storage::Yandex::Disk'
      end
    end
  end
end
