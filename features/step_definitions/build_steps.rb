Given /^(?:I change )?input file "([^\"]*)" (?:contains|to contain) "([^\"]*)"$/ do |file_name, content|
  @inputs[file_name] = content
end

Given /^input file "([^\"]*)" contains$/ do |file_name, content|
  @inputs[file_name] = content
end

Given /^output file "([^\"]*)" contains "([^\"]*)"$/ do |file_name, content|
  @outputs[file_name] = content
end

Given /^output file "([^\"]*)" contains$/ do |file_name, content|
  @outputs[file_name] = content
end

When /^I (?:re)?build the site$/ do
  @project.logger.clear
  @project.build
end

Given "the site is up-to-date" do
  sleep(1) # TODO: stop sleeping
  When "I build the site"
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

Then /^output file "([^"]*)" should be re\-generated$/ do |file_name|
  @project.logger.messages.should contain(/--> +#{file_name}/)
end

Then /^output file "([^"]*)" should not be re\-generated$/ do |file_name|
  @project.logger.messages.should_not contain(/--> +#{file_name}/)
end
