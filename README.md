# Yandex.Disk storage plugin for CarrierWave

This gem allows you to set [Yandex.Disk](https://en.wikipedia.org/wiki/Yandex_Disk) (free of charge) as an online storage for the files you upload to your site with [CarrierWave](https://github.com/carrierwaveuploader/carrierwave). It is analogous to the [fog gems family](https://github.com/fog) and is especially useful for using CarrierWave on [Heroku](https://en.wikipedia.org/wiki/Heroku) (where the common file storage is [not supported](https://github.com/carrierwaveuploader/carrierwave/wiki/How-to%3A-Make-Carrierwave-work-on-Heroku)).

This gem is NOT intended for an industry-scale cloud files storage (due to the possible Yandex.Disk bandwidth and other limitations). But it's a right fit for your (Heroku-based) job application test work, educational projects, etc.

## Installation

Set up a Yandex.Disk free account as described on the [Yandex::Disk gem page](https://github.com/anjlab/yandex-disk).

Add this line to your application's Gemfile:

```ruby
gem 'carrierwave-yandex-disk', '~> 0.1.0'
```

Set up your Rails application:

* Write your OAuth2 token (generated on the Yandex.Disk setup step) into the `config/secrets.yml` file like this:

```ruby
development:
  yandex_disk_access_token: 'AQAAAAAND3AxAATUPz31jhEFF0P_gltPlOFGi-4'

test:
  yandex_disk_access_token: 'AQAAAAAND3AxAATUPz31jhEFF0P_gltPlOFGi-4'

production:
  yandex_disk_access_token: <%= ENV["YANDEX_DISK_ACCESS_TOKEN"] %>
```

See [more info about secrets.yml usage](http://guides.rubyonrails.org/4_1_release_notes.html#config-secrets-yml).

* Add your `config/secrets.yml` to the `.gitignore` file (if you haven't done it previously).

* Create a file `config/initializers/carrierwave.rb` with the following content:

```ruby
CarrierWave.configure do |config|

  config.yandex_disk_access_token = Rails.application.secrets.yandex_disk_access_token
 
end
```

**NOTE**: You may use whatever other token initialization source here (if you don't like `secrets.yml`).

In the target uploader set the storage like this:

```ruby
# app/uploaders/avatar_uploader.rb
class AvatarUploader < CarrierWave::Uploader::Base
  #storage :file
  storage :yandex_disk
end
```

Set up the [Carrierwave](https://github.com/carrierwaveuploader/carrierwave) gem.

## Usage

The usage is basically the same as in the regular (file-storage) CarrierWave case. The uploaded files get immediately "published" (e.g. available to anyone) on Yandex.Disk.

**NOTE**: Do not manually operate with the CarrierWave-uploaded files on your Yandex.Disk account!

Imagine you defined a model with an uploader:

```ruby
class User < ApplicationRecord
	
  mount_uploader :avatar, AvatarUploader

end
```

Then (in your views) you can access the following methods:

**url**:

```ruby
@user.avatar.url
```

or

```ruby
@user.avatar.file.url
```

Return example:

```ruby
https://downloader.disk.yandex.ru/disk/25e9fa3c40ea7e440029923e4a4c63e2f01cb66be3cda8cd1a756b8d2f46000f/5a934e46/jP34-9cszbD04Qaxa28_KP9GIgRMt42Dc_8aZRK8u2QXMsbsCPO6xe254apPTxbNg5jWPBB01aCTbWcWJo_f4g%3D%3D?uid=0&filename=user.png&disposition=attachment&hash=aHZ5UF177vQMTgCaLYPLS/VKtUrFKs/wlXlPu%2B7jXUw%3D%3A&limit=0&content_type=image%2Fpng&fsize=21128&hid=662f9a494d1d41839c86afd9c1de6afc&media_type=image&tknv=v2
```

Yields the direct URL (for your uploaded file) which is dynamically fetched from the server on every view rendering. This is a Yandex.Disk direct link policy limitation.

**public_url**:

```ruby
@user.avatar.file.public_url
```

Return example:

```ruby
https://yadi.sk/i/H_D62-Ln3SmAhc
```

Yields the public URL (for your uploaded file). You may use this value for distributing the uploaded file beyond your site (on forums, blogs, etc).

**storage_path**:

```ruby
@user.avatar.file.storage_path
```

Return example:

```ruby
/uploads/user/avatar/1/user.png
```

Yields the internal storage path (for your uploaded file). You would hardly need this value. It's format depends on the uploader's `store_dir` function.

**filename**:

```ruby
@user.avatar.file.filename
```

Return example:

```ruby
user.png
```

Yields the filename (for your uploaded file).

**extension**:

```ruby
@user.avatar.file.extension
```

Return example:

```ruby
.png
```

Yields the extension (for your uploaded file).


## Special thanks

This project is highly based on the [carrierwave-dropbox](https://github.com/robin850/carrierwave-dropbox) gem.

Thanks to its author and contributors!

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/programrails/carrierwave-yandex-disk.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
