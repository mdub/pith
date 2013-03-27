source "https://rubygems.org"

gemspec

group :test do
  gem "rake", "~> 0.9.2"
  gem "rspec", "~> 2.11.0"
  gem "cucumber", "~> 1.2.0"
  gem "haml"
  gem "sass"
  gem "RedCloth"
  gem "rdiscount"
  gem "compass"
  if tilt_version = ENV["TILT_VERSION"]
    gem "tilt", tilt_version
  end
end
