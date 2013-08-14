source "https://rubygems.org"

gemspec

group :test do
  gem "rake", "~> 10.0.0"
  gem "rspec", "~> 2.11.0"
  gem "cucumber", "~> 1.2.0"
  gem "haml", "~> 3.1.7"
  gem "sass"
  gem "RedCloth"
  gem "kramdown"
  gem "compass"
  if tilt_version = ENV["TILT_VERSION"]
    gem "tilt", tilt_version
  end
end
