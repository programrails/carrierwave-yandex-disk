RSpec.describe Carrierwave::Yandex::Disk do
  it 'has a version number' do
    expect(Carrierwave::Yandex::Disk::VERSION).not_to be nil
  end

  describe 'Disk methods' do
    before :each do
      @uploader = double('uploader')
      @file_string = double('file_string')
      @yandex_disk_client = double('yandex_disk_client')

      @disk = CarrierWave::Storage::Yandex::Disk.new @uploader

      allow(@uploader).to receive(:store_path) { 'good file path' }

      allow(@uploader).to receive(:store_dir) { 'good folder path' }

      allow(@disk).to receive(:yandex_disk_client) { @yandex_disk_client }

      allow(@yandex_disk_client).to receive(:mkdir_p)
        .with('/good folder path') { true }

      allow(@yandex_disk_client).to receive(:mkdir_p)
        .with('/bad folder path') { false }

      allow(@yandex_disk_client).to receive(:put)
        .with('file path', '/good file path') { true }

      allow(@yandex_disk_client).to receive(:put)
        .with('file path', '/bad file path') { false }

      allow(@file_string).to receive(:path) { 'file path' }

      allow(@yandex_disk_client).to receive(:make_public)
        .with('/good file path') { { public_url: true } }

      allow(@yandex_disk_client).to receive(:make_public)
        .with('/bad file path') { { public_url: nil } }
    end

    it 'throws an error when fails to create a remote folder' do
      allow(@uploader).to receive(:store_dir) { 'bad folder path' }

      expect { @disk.store! @file_string }.to \
        raise_error(CarrierWave::Storage::Yandex::Error, \
                    "The folder '/bad folder path' was not created")
    end

    it 'throws an error when fails to put a file to a remote storage' do
      allow(@uploader).to receive(:store_path) { 'bad file path' }

      expect { @disk.store! @file_string }.to \
        raise_error(CarrierWave::Storage::Yandex::Error, \
                    'The file was not uploaded to the ' \
                    "location '/bad file path'")
    end

    it 'throws an error when fails to publish a file on a remote storage' do
      allow(@yandex_disk_client).to \
        receive(:make_public).with('/good file path') { { public_url: nil } }

      expect { @disk.store! @file_string }.to \
        raise_error(CarrierWave::Storage::Yandex::Error, \
                    "The file '/good file path' was not published")
    end
  end
end
