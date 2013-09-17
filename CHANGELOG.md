#3.10.0 (2013-09-17)
Merged various pull requests including subfolders in beaker directory

- Bumped version to 3.10.0 to prepare for release.
- fixed small typo with tests
- updated docs to detail catalyst usage
- updated template not to include depracated log configuration to close #73
- fixed typo with test, updated variable to be more verbose, changed all the ckit executions in the cucumber tests to use bundle exec
- updated rvm rbenv managment to new mode
- locked ruby version until clearing up how that can be managed
- updated rubo and fixed some code quality issues
- added contribution clarity to readme docs
- add a test to run beakers from a sub-directory
- bump selenium-webdriver to overcome a loading error for rubyzip
- Beaker directory now supports sub-directories

#3.9.1 (2013-08-26)
small fix to gemfile

- Bumped version to 3.9.1 to prepare for release.
- updated gemfile
- removed dupe log from changelog

#3.9.0 (2013-08-26)
Improved reporting features and configuration for sauce permissions

- gg
- Bumped version to 3.9.0 to prepare for release.
- updated rake file to override build verify in special cases
- final fix to a test
- fixed issues causing tests to fail
- updated docs to reflect recent changes and future release
- updated report generation to include dom dumps for all available windows
- upgraded SC version and added hooks to handle tagging sauce jobs and setting the team permission via a beaker tag, plus tests
- screenshots front and center, hiding of success
- now hiding success by default with off switch
- removed specific log specification from system tests, cleaned up log configuration to just default to evidence and refactoried the cli a small bit to support it.
- updated bundle and fixed new code quality error

#3.9.0-rc.3 (2013-08-19)
- added toggle for parts of html reports
- added a fix to allow jenkins ci server to show the html report images
- integrated new selenium connect
- updates to configurations
- integrated optimizely opt out

#3.9.0-rc.2 (2013-08-14)
- Added Basic Auth Support. Preserving release candidate numbering since there are improvements to be made to HTTP reporting

#3.9.0-rc.1 (2013-08-12)
Release candidate with new features including
- Consolidated html report
- Updates to chemists to support multiple chemists from being joined

###Known Issues
- When running chrome locally the chromedriver logs do not always get placed in the correct places, likely due to the current approach of moving them around
- There is a lack of sufficient tests around the reporting functionality, so there could be some sporadic behavior when it comes to the consolidation and formatting of the main html report
- Configuration of specific log_path locations and output names is not fully supported at this time. Both an html report and junit.xml are output by default.

#3.8.1 (2013-08-09)
Cleaned up chemists to use same instance in the formulas and bug fixes

- Bumped version to 3.8.1 to prepare for release.
- updated docs and moved the chemist aware module require to the base class
- updated tests and chemist to reflect the mutability of type but not key
- improved chemists by ensuring the same chemist object is always in play so that different formulas that update it state work together, also fixed a small bug with the loading of formulas by name

#3.8.0 (2013-08-05)
Implemented the chemists feature to add user data management as well as a simplified strategy for loading formulas

- Bumped version to 3.8.0 to prepare for release.
- cleaned up docs a little and ensured the default chemists csv file wouldn't cause a failure if left unpopulated
- added a uuid injector for a token in csv files
- integrated the fomula lab into the suite runner and added basic cucumber tests
- built out the rest of the formula lab and integration tests
- updated templates to create the default chemists folder
- upped the flog limits... still need to understand how that will help
- updated chemist and chemist repository to include key, as well as selection by key, random, or first of type
- updated documentation of new changes
- built out the rest of the csv chemist repository
- started building out the user data repository from a csv file.
- built out a basic chemist class
- added module to define chemist aware for the formulas to include
- added reek and rubocop to the guard file
- moved dev dependencies to gemfile, added in new code quality checks, fixed some code issues found by rubocop, updated rake tasks
- updated selenium connect version
- added animoto mention to friends section

#3.7.0 (2013-07-24)
updated evidence to put in test based folders and added configuration for the retry functionality

- Bumped version to 3.7.0 to prepare for release.
- updated integration tests for new evidence directory format
- updated config template and made some tests pass
- updated readme to add usergroup link
- added folder hierachy for evidence and slug formatter, fixed code quality issues
- added slugification to junit formatter to support attachment plugin
- added retry to configuration file and run time parameters updated docs and tests
- updated sc version

#3.6.0 (2013-07-20)
Added the ability for tests to be retried on failure. A single retry will be attempted by default and the output will be verbose.

- Bumped version to 3.6.0 to prepare for release.
- Bumped version to  to prepare for release.
- Updated the brew test to remove a redundant sauce test and to update the asset check to account for the retried test runs on failure
- Fixing rubocop message
- Added a default retry count, so it will retry a failed test once.
- Added a config attribute to brew for verbose retry
- Added rspec-retry

#3.5.0 (2013-07-15)
updated logging to store assets in a per beaker folder

- Bumped version to 3.5.0 to prepare for release.
- updated docs
- updated ckit to use latest sc with cleaner log storage and added a flag for the screenshot download

#3.4.2 (2013-07-14)
fixed typo

- Bumped version to 3.4.2 to prepare for release.
- fixed dumb typo

#3.4.1 (2013-07-14)
minor update to sc

- Bumped version to 3.4.1 to prepare for release.
- bumped sc version for bug fix

#3.4.0 (2013-07-14)
upgrade to use new selenium connect and integrated sauce lab job failures screenshots and ci reporting

- small patch to the rake file
- Bumped version to 3.4.0 to prepare for release.
- updated sc to fix bug
- updated tests to look for job assets on concurency
- updated cli to use the new sc with test pass or fail and screenshot grab
- updated selenium connect to latest version
- updated rake file for ckit readme update and standard title format on readme
- updated build process to use standard rspec convention and added coverage and spec reporting
- turned off travis email notifications
- added dynamic naming for sauce runs, and a dump of the video url on failure

#3.3.1 (2013-07-11)
Fixed bugs related to tagging and alternate configuration files in concurrent runs

- Bumped version to 3.3.1 to prepare for release.
- final code quality check
- fixed issue where --all was not getting passed forward in parallel tests and the same with an alternative config file, added tests for those as well
- fixed duplicate alias for brew option

#3.3.0 (2013-07-09)
Fixed bugs with tagging and concurrency

- Bumped version to 3.3.0 to prepare for release.
- added the ckit tags command to list all tags in the harness
- consolidated documentation into the readme file
- fixed code quality issues and a bug with the tag filtering
- added the --all flag and tests to run all beakers
- fixed tagging issues for concurrent runs, now a beaker specification will override the default tag unless it is explicitly specified.
- removed debug info
- initial cut on tagging updates

#3.2.0 (2013-07-08)
Updated Selenium Connect

- Bumped version to 3.2.0 to prepare for release.
- updated selenium connect to latest version

#3.1.0 (2013-07-07)
Updated logging mechanism for concurrent tests and to output junit xml.

- Bumped version to 3.1.0 to prepare for release.
- cleaned out some random debug code
- fixed code quality issues and removed some debugging information
- updated concurency to use uuid for partial logs, cleaned up tests
- fixed other features so they would pass
- fixed more code quality issues
- added facility that would create partial test output for concurrent tests
- ensured all log files could be directed to the same directory
- fixed code quality issue and added test to ensure html report output would work
- added in configurable junit export with stdout
- added logging feature and tests, and expanded the configuration for logging

#3.0.1 (2013-07-05)
Made the base url available in the env for formula usage

- Bumped version to 3.0.1 to prepare for release.
- removed unused shared context file, and updated config parameter passing
- Added an environment variable setter for base_url based on the config object in a before(:each) block

#3.0.0 (2013-07-04)
Now with concurrent tests

- Bumped version to 3.0.0 to prepare for release.
- included message into changelog update and added a test for specific concurrency feature
- integrated config driven concurrency, cleaned up some tests
- abstracted out config loading into brew
- learning how to spell concurrency correctly
- fixed a minor typo in a feature and added a todo comment
- updated feature files to have correct directory, added a test for concurrency
- upgraded the global config into the shared context
- updated all tests to match new configuration format
- added back updated configuration object
- removed local references to selenium server and updated tests accordingly
- updated to latest build of selenium connect, fixed a small bug in a feature file, and updated the rakefile to handle find tags correctly
- Code quality fixes
- Wired up --processes to adjust number of processes when running --parallel, defaulting the number to 5
- Updated comment
- Updated sauce brew scenario to use our sauce account
- Test group execution working
- Renamed parallel to parallel_tests_mods for better explicitness. Got ckit brew running with parallel_tests (WOOT!). Now just need to figure out how to execute tests within a group for each thread rather than all tests in each thread.
- removed branch restriction on travis so all feature branches would be tested
- Fixed all code quality issues, added custom options file to tweek method length and line length cops, updated build system
- added rubocop to the build process
- Added a monkey patch for parallel_tests' RSpec runner to override its defaults with ours and wired it up in the parallel execution hook. It runs but gives an argument error from ckit. Also, took a first crack at setting the base_url via config.yaml and the shared_context
- Added parallel_tests and parallel to repo. Wired up a command argument for ckit brew (--parallel) to execute the wip progress concurrency method.
- Downgraded the required ruby version to just 1.9.3
- one small edit because of a bug with git flow #62

#2.1.0 (2013-06-28)
- Updated documentation for #62 release process.
- Bumped version to 2.1.0 to prepare for release.
- Changed the oder of branch updates in rakefile #62
- #62 fixed another small issue with rakefile
- fixed small typo in Rakefile per #62
- updated a note to the change log and built out the rake tasks to close #62
- updated gemspec to remove the ext, cleaned up the base class.
-  updated rvm version files and removed the ext directory
- moved the build dir deletion to the before so that post test inspection could be carried out, also added a rough implementation to close #63

#2.0.0 (2013-06-27)
- Updated to Selenium-Connect version to 2.0.0
- Improved performance with driver hooks
- Added the ability to specify config files on brew.
- NOTE: Updated default config file from `_config.yaml` to `config.yaml`
- Added the "catalyst" concept for injecting data into formulas.

#1.3.0 (2013-06-22)
- Added explicit recursive file loading process for formulas
- Cleaned up documentation
- Updated tests
- Cleaned up logging

#1.2.1 (2013-06-21)
- Bumping version number and adding Jason Fox as an author
- Making it so symbol values as tags in beakers will default to true if no value is set to them
- Pulled out the log value setter from shared_context and rolled this up into selenium-connect instead. Bumped to new version of selenium-connect to get this functionality
- Reworked the status check and exit logic order and implemented it as a ternary (effectively regressing back to what was there way back when). A better band-aid fix for now.
- added small tweak to catch the {} returned by calling ckit, which was giving an hash to integer conversion error
- Bumped version and removed the un-used spec dir
- Fixes #59. Will need to revisit the approach since it is a workaround given difficulties in getting Thor's self.exit_on_failure?; true; end to work properly Re: https://github.com/erikhuda/thor/issues/244
- Added a test to capture the exit status issue
- Updated the spec and moved it up a dir
- removed symlinking of historical log files and cleaned up the logging system to output the junit xml and the server log to the evidence directory. Added a bit of test for that.
- updated git ignore for build directory and changed the new feature to a different name to prevent conflicts
- removed non running spec
- added a few rake tasks and switched to standard build directory
#1.1.1 (2013-06-09)
- Bumping selenium-connect version to account for sauce gem breaking changes

#1.1.0 (2013-06-09)
- Added the ability to pass in environment variables with ckit brew --params=THING1:value THING2:value

#1.0.0 (2013-06-05)
- Removed a hard-coded exit code checker from the ckit binary, also adjusted the requires in it to use the top level chemistrykit file in lib. Had to rework that file as well. Also updated the readme
- Looks like my previous commit didn't include the cleanup of old files. Here you go! Also, updated the readme slightly
- Wired up selenium-connect and gladly gutted a heap of code that it replaced. Also, updated the readme and updated the gemspec.
- Readded the new commmand since someone got a little code clippy. Wired up the assertion in the "new" test so it actually works. And made the tmp directory listing explicit.
- Adding tmp directory to gitignore
- Updating gitignore for rvmrc
- Added string interpolation for doc strings with erb and consolidated the brew feature into a single scenario outline with an examples table
- Simplified ckit generate with a proper subcommand
- Tested on local branch, tests passing. Removed puts.
- Add the requires back to the method, not happy about it, but necessary for now
- Didn't comment out all of one scenario: fixed
- Disabled sauce with chrome scenario, without a way to check sauce to see if chrome is being used, it's the same as sauce with firefox
- All four scenarios working. Sacuelabs credentials needed in order for tests to run.
- Wait only 15 seconds intead of 30 seconds
- Passing selenium-webdriver and local selenium server scenarios
- Disabled new.feature, updated brew.feature with 4 types of scenarios
- Removed usage title, it already has a good title
- Brew cmd not default, updated documentation to reflect change
- Removed a duplicate if statement, added a lot of puts to see what's happening
- Added before(:all) hook to fix #48, refactored more logic out of before(:each)
- Condensed to methods for driver into one
- Updated the generated beaker with a formula to use the let incantation.
- Required formula in generator
- changelog updated to v0.1.1
- Added rake back to the gemspec becuase we are using it
- remove more self's
- You don't need to reference self so much, it will figure it out
- You don't need to initialize instance methods unless you want to set their value
- Passing variables from module Sauce to Ckit in a safer way, fixed bug where executor was being called twice per test
- Extracted sauce actions into a module
- Refactored logic out of after:each into methods
- Case statement for symlinking, added notes about they whys
- seperated rspec configuration from tagging logic
- log_timestamp was being called twice and creating two different values - fixed
- Removal of if statement, using ln_sf forces the creation of a symlink if one already exists
- Refactored logic for brew command into protected methods
- Added code climate badge
- Corrected version #
- Adding a tag for testing the testing of aruba
- Added a passing brew commit command and modified support.rb to env.rb like the docs say
- More updates to make it less overhead
- Simplified the new cli feature file, I think I'm starting to get aruba
- Told git to ignore the files that aruba is creating and updated new feature
- Cucumber spec for ckit new command
- Removed rake because we're not using it, added aruba and cucumber because living docs for the Cli is cool
- Please load aruba when you run feature files

#0.1.1 (2013-02-02)

* `ckit new` generates a chemistrykit project
* Execute tests in SauceLabs Ondemand
* Selenium server test execution
* Local test execution via selenium-webdriver
* Minimum page object model
* Page and beaker generation via `ckit generate`
* Discovery via tags
* Random execution
* Customization via yaml files
* Integration hook for CI
* Works from 'gem install' on both windows and unix
* Wrapper around WebDriver
