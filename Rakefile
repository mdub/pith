task :default => :spec

require 'spec/rake/spectask'

Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_opts << ["--color"]
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
