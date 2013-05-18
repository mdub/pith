Given /^input file "([^\"]*)" contains "([^\"]*)"$/ do |path, content|
  @inputs.write(path, content, :mtime => (Time.now - 5))
end

Given /^input file "([^\"]*)" contains$/ do |path, content|
  @inputs.write(path, content, :mtime => (Time.now - 5))
end

Given /^input file "([^\"]*)" exists$/ do |path|
  step %{input file "#{path}" contains "something"}
end

Given /^output file "([^\"]*)" exists$/ do |path|
  @outputs.write(path, "something", :mtime => (Time.now - 4))
end

Given "the site is up-to-date" do
  step "I build the site"
end

Given /^the config file contains$/ do |content|
  @inputs.write("_pith/config.rb", content, :mtime => (Time.now - 5))
end

When /^I change input file "([^\"]*)" to contain "([^\"]*)"$/ do |path, content|
  @inputs[path] = content
end

When /^I change input file "([^\"]*)" to contain$/ do |path, content|
  @inputs[path] = content
end

When /^I remove input file "([^\"]*)"$/ do |path|
  @inputs[path] = nil
end

When /^I (?:re)?build the site$/ do
  @project.logger.clear
  @project.build
end

class String
  def clean
    strip.gsub(/\s+/, ' ')
  end
end

Then /^output file "([^\"]*)" should contain "([^\"]*)"$/ do |path, content|
  @outputs[path].clean.should == content.clean
end

Then %r{^output file "([^\"]*)" should contain /([^\/]*)/$} do |path, regexp|
  @outputs[path].clean.should =~ Regexp.compile(regexp)
end

Then /^output file "([^\"]*)" should contain$/ do |path, content|
  @outputs[path].clean.should == content.clean
end

Then /^output file "([^\"]*)" should not exist$/ do |path|
  @outputs[path].should == nil
end

Then /^output file "([^"]*)" should be re\-generated$/ do |path|
  @project.logger.messages.should contain(/--> +#{path}/)
end

Then /^output file "([^"]*)" should not be re\-generated$/ do |path|
  @project.logger.messages.should_not contain(/--> +#{path}/)
end

Then /^output file "([^\"]*)" should contain an error$/ do |path|
  @outputs[path].clean.should == "foo"
end

Then /^the project should have errors$/ do
  @project.should have_errors
end
