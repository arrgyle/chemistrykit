require 'aruba/cucumber'

Before do
  FileUtils.rm_rf("build/tmp")
  @aruba_timeout_seconds = 90
  @dirs = ["build/tmp"]
end
