Given /^input file "([^\"]*)" contains$/ do |file_name, content|
  @inputs[file_name] = content
end

When /^I build the site$/ do
  @project.build
end

Then /^output file "([^\"]*)" should contain$/ do |file_name, content|
  @outputs[file_name].strip.should == content.strip
end
