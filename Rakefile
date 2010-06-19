task :default => :spec

require 'spec/rake/spectask'

Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_opts << ["--color"]
end

task :default => :cucumber

require 'cucumber/rake/task'

Cucumber::Rake::Task.new(:cucumber) do |t|
  t.fork = true
  t.profile = 'default'
end
