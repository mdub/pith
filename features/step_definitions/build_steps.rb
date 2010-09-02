Given /^input file "([^\"]*)" contains "([^\"]*)"$/ do |path, content|
  @inputs.write(path, content, :mtime => (Time.now - 5))
end

Given /^input file "([^\"]*)" contains$/ do |path, content|
  @inputs.write(path, content, :mtime => (Time.now - 5))
end

Given /^input file "([^\"]*)" exists$/ do |path|
  Given %{input file "#{path}" contains "something"}
end

Given "the site is up-to-date" do
  When "I build the site"
end

When /^I change input file "([^\"]*)" to contain "([^\"]*)"$/ do |path, content|
  @inputs[path] = content
end

When /^I change input file "([^\"]*)" to contain$/ do |path, content|
  @inputs[path] = content
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
