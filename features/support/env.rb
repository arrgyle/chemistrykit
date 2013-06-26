require 'aruba/cucumber'

Before do
  @aruba_timeout_seconds = 90
  @dirs = ["build/tmp"]
end

After('@clear_tmp') do
  FileUtils.rm_rf("build/tmp")
end
