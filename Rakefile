require 'bundler'

Bundler::GemHelper.install_tasks

task :default => :spec

require "rspec/core/rake_task"

RSpec::Core::RakeTask.new do |t|
  t.pattern = 'spec/**/*_spec.rb'
end

task :default => :cucumber

require 'cucumber/rake/task'

namespace :cucumber do

  [:wip, :default].each do |profile|

    Cucumber::Rake::Task.new(profile) do |t|
      t.fork = true
      t.profile = profile
    end

  end

end

task :cucumber => ["cucumber:wip", "cucumber:default"]
