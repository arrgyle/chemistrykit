Feature: Brewing a ChemistryKit project

  Running ckit brew runs the suite of tests.

  There are four different ways to run ChemistryKit:
    1. Locally on selenium-webdriver
    2. Selenium remote
    3. Selenium remote with Sauce Ondemand
    4. Selenium remote with Sauce Ondemand with Sauce Ondemand with Chrome

  Background: Setup the project
    Given I run `ckit new booker`
    And I cd to "booker"
    And a file named "formulas/bookie.rb" with:
      """
      module Formulas
        class Bookie
          def initialize(driver)
            @driver = driver
          end

          def open(url)
            @driver.get url
          end
        end
      end
      """
    And a file named "beaker/bookie_beaker.rb" with:
      """
      describe "Bookie", :depth => 'shallow' do
        let(:book) { Formulas::Bookie.new(@driver) }

        it "loads an external web page" do
          book.open "http://www.google.com"
        end
      end
      """

  Scenario: Run locally on selenium-webdriver
    When I overwrite "_config/chemistrykit.yaml" with:
      """
      chemistrykit: {
        project: Booker,
        capture_output: false,
        run_locally: true
        }

      webdriver: {
        browser: firefox,
        server_host: localhost,
        server_port: 4444
        }

      saucelabs: {
          ondemand: false,
          version: 18,
          platform: Windows 2008
          }
      """
    When I run `ckit brew`
    Then the stdout should contain "1 example, 0 failures"

  Scenario: Selenium remote with local server
    When I overwrite "_config/chemistrykit.yaml" with:
    """yaml
    ---
    chemistrykit: {
      project: Booker,
      capture_output: false,
      run_locally: false
    }

    webdriver: {
      browser: firefox,
      server_host: localhost,
      server_port: 4444
    }

    saucelabs: {
        ondemand: false,
        version: 18,
        platform: Windows 2008
    }
    """
    When I run `ckit brew`
    Then the stdout should contain "1 example, 0 failures"

  Scenario: Selenium remote with Sauce Ondemand
    When I overwrite "_config/chemistrykit.yaml" with:
    """yaml
    ---
    chemistrykit: {
      project: Booker,
      capture_output: false,
      run_locally: false
    }

    webdriver: {
      browser: firefox,
      server_host: localhost,
      server_port: 4444
    }

    saucelabs: {
        ondemand: true,
        version: 18,
        platform: Windows 2008
    }
    """
    And a file named "_config/saucelabs.yaml" with:
    """yaml
    ---
    username: 
    key: 
    """
    When I run `ckit brew`
    Then the stdout should contain "1 example, 0 failures"

  ## This test is problamatic, we should be checking Saucelabs to see if Chrome is being run
  ## I've manually checked for this and chrome is being used
  ## Disabling until we create a way to check
  #Scenario: Selenium remote with Sauce Ondemand with Sauce Ondemand with Chrome
  #  When I overwrite "_config/chemistrykit.yaml" with:
  #  """yaml
  #  ---
  #  chemistrykit: {
  #    project: Booker,
  #    capture_output: false,
  #    run_locally: false
  #  }

  #  webdriver: {
  #    browser: chrome,
  #    server_host: localhost,
  #    server_port: 4444
  #  }

  #  saucelabs: {
  #      ondemand: true,
  #      version: 18,
  #      platform: Windows 2008
  #  }
  #  """
  #  And a file named "_config/saucelabs.yaml" with:
  #  """yaml
  #  ---
  #  username: 
  #  key: 
  #  """
  #  When I run `ckit brew`
  #  Then the stdout should contain "1 example, 0 failures"
