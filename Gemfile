source "https://rubygems.org"

gemspec

group :test do
  gem "rake", "~> 10.0.0"
  gem "rspec", "~> 3.7.0"
  gem "cucumber", "~> 3.1.0"
  gem "haml"
  gem "haml-contrib"
  gem "sass"
  gem "RedCloth"
  gem "kramdown"
  gem "compass", ">= 1.0.3"
  gem "listen", "~> 3.1.5"
  if tilt_version = ENV["TILT_VERSION"]
    gem "tilt", tilt_version
  end
end
