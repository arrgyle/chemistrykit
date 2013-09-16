@announce
Feature: Brewing a ChemistryKit project

  Running ckit brew runs the suite of tests.

  ckit can run in a couple of different ways:
    1. Locally
    2. With Sauce Ondemand

  Background: Setup the project
    Given I run `ckit new booker`
    And I cd to "booker"
    And a file named "formulas/bookie.rb" with:
      """
      module Formulas
        class Bookie < Formula
          def open(url)
            @driver.get url
          end
        end
      end
      """
    And a file named "beakers/bookie_beaker.rb" with:
      """
      describe "Bookie", :depth => 'shallow' do
        let(:book) { Formulas::Bookie.new(@driver) }

        it "loads an external web page" do
          book.open "http://www.google.com"
        end
      end
      """

  Scenario: Localhost
    Given a file named "config.yaml" with:
      """
      selenium_connect:
          host: 'localhost'
      """
    When I run `ckit brew`
    Then the stdout should contain "1 example, 0 failures"
    And the following files should exist:
      | evidence/junit_0.xml |
      | evidence/bookie/bookie_loads_an_external_web_page/server.log        |

  Scenario: Brew a single beaker
    Given a file named "config.yaml" with:
      """
      selenium_connect:
          host: 'localhost'
      """
    And a file named "beakers/other_beaker.rb" with:
      """
      describe "Other" do
        let(:book) { Formulas::Bookie.new(@driver) }

        it "loads an external web page" do
          book.open "http://www.google.com"
        end
      end
      """
    When I run `ckit brew --beakers=beakers/other_beaker.rb`
    Then the stdout should contain "1 example, 0 failures"

  Scenario: Brew beakers where the beakers directory contains a sub-directory
    Given a file named "config.yaml" with:
      """
      selenium_connect:
          log: 'evidence'
          host: 'localhost'
      """
    And a file named "beakers/sub/other_beaker.rb" with:
      """
      describe "SubDirectory" do
        let(:book) { Formulas::Bookie.new(@driver) }

        it "loads an external web page" do
          book.open "http://www.google.com"
        end
      end
      """
    When I run `ckit brew --all`
    Then the stdout should contain "2 example, 0 failures"

  Scenario: Run all the tests regardless of tag
    Given a file named "config.yaml" with:
      """
      selenium_connect:
          host: 'localhost'
      """
    And a file named "beakers/other_beaker.rb" with:
      """
      describe "Other" do
        let(:book) { Formulas::Bookie.new(@driver) }

        it "loads an external web page" do
          book.open "http://www.google.com"
        end
      end
      """
    When I run `ckit brew --all`
    Then the stdout should contain "2 examples, 0 failures"

  Scenario: Saucelabs
    Given a file named "config.yaml" with:
      """
      screenshot_on_fail: true
      selenium_connect:
          host: 'saucelabs'
          browser: 'iexplore'
          os: 'windows 2003'
          sauce_username: 'testing_arrgyle'
          sauce_api_key: 'ab7a6e17-16df-42d2-9ef6-c8d2539cc38a'
          browser_version: '8'
          description: 'ckit feature check'
      """
    And a file named "beakers/failure.rb" with:
    """
    describe "Failing Beaker", :depth => 'shallow' do
      it "loads an external web page" do
        @driver.get "http://www.google.com"
        @driver.title.should_not include("Google")
      end
    end
    """
    When I run `ckit brew --beakers=beakers/failure.rb`
    Then the stdout should contain "1 example, 1 failure"
    And there should be "1" "failed image" log files in "evidence/failing_beaker/failing_beaker_loads_an_external_web_page"
    And there should be "1" "report" log files in "evidence/failing_beaker/failing_beaker_loads_an_external_web_page"
    And there should be "1" "sauce log" log files in "evidence/failing_beaker/failing_beaker_loads_an_external_web_page"

  Scenario: Retry a test on failure based on config file
    Given a file named "config.yaml" with:
      """
      retries_on_failure: 3
      selenium_connect:
          host: 'localhost'
      """
    And a file named "beakers/other_beaker.rb" with:
      """
      describe "Other" do
        let(:book) { Formulas::Bookie.new(@driver) }

        it "loads an external web page" do
          book.open "http://www.google.com"
          @driver.title.should_not include("Google")
        end
      end
      """
    When I run `ckit brew --beakers=beakers/other_beaker.rb`
    Then the stdout should contain "RSpec::Retry: 2nd try"
    Then the stdout should contain "RSpec::Retry: 3rd try"

  Scenario: Retry a test on failure based on run time parameter
    Given a file named "config.yaml" with:
      """
      retries_on_failure: 2
      selenium_connect:
          log: 'evidence'
          host: 'localhost'
      """
    And a file named "beakers/other_beaker.rb" with:
      """
      describe "Other" do
        let(:book) { Formulas::Bookie.new(@driver) }

        it "loads an external web page" do
          book.open "http://www.google.com"
          @driver.title.should_not include("Google")
        end
      end
      """
    When I run `ckit brew --beakers=beakers/other_beaker.rb --retry=3`
    Then the stdout should contain "RSpec::Retry: 2nd try"
    Then the stdout should contain "RSpec::Retry: 3rd try"


