require "rubygems"

require "fileutils"

$project_dir = Pathname(__FILE__).expand_path.parent.parent
$tmp_dir = $project_dir + "tmp"
$input_dir = $tmp_dir + "input"
$output_dir = $tmp_dir + "output"

RSpec.configure do |config|

  config.raise_errors_for_deprecations!

  config.before(:suite) do
    [$input_dir, $output_dir].each do |dir|
      dir.rmtree if dir.exist?
    end
    $input_dir.mkpath
  end

end
