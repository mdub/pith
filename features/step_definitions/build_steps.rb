Given /^input file "([^\"]*)" contains "([^\"]*)"$/ do |file_name, content|
  @inputs[file_name] = content
end

Given /^input file "([^\"]*)" contains$/ do |file_name, content|
  @inputs[file_name] = content
end

When /^I build the site$/ do
  @project.build
end

class String
  def clean
    strip.gsub(/\s+/, ' ')
  end
end

Then /^output file "([^\"]*)" should contain "([^\"]*)"$/ do |file_name, content|
  @outputs[file_name].clean.should == content.clean
end

Then /^output file "([^\"]*)" should contain$/ do |file_name, content|
  @outputs[file_name].clean.should == content.clean
end

Then /^output file "([^\"]*)" should not exist$/ do |file_name|
  @outputs[file_name].should == nil
end
