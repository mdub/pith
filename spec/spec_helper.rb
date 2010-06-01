require "rubygems"
require "pathname"

$spec_dir = Pathname(__FILE__).expand_path.parent
$project_dir = $spec_dir.parent
$sample_input_dir = $spec_dir + "fixtures" + "sample"

$tmp_dir = $project_dir + "tmp"
