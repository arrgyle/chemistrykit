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
    And a file named "beaker/bookie_beaker.rb" with:
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
      jar: '../../../vendor/selenium-server-standalone-2.33.0.jar'
      log: 'evidence'
      host: 'localhost'
      """
    When I run `ckit brew`
    Then the stdout should contain "1 example, 0 failures"
    And the following files should exist:
      | evidence/SPEC-Bookie.xml  |
      | evidence/server.log       |


  Scenario: Saucelabs
    Given a file named "config.yaml" with:
      """
      log: 'evidence'
      host: 'saucelabs'
      brower: 'iexplore'
      os: 'windows 2003'
      sauce_username: 'dave_arrgyle'
      sauce_api_key: '58092e14-4e9c-4911-bfc4-a09ecc02db63'
      browser_version: '8'
      description: 'ckit feature check'
      """
    When I run `ckit brew`
    Then the stdout should contain "1 example, 0 failures"

  Scenario: Brew a single beaker
    Given a file named "config.yaml" with:
      """
      jar: '../../../vendor/selenium-server-standalone-2.33.0.jar'
      log: 'evidence'
      host: 'localhost'
      """
    And a file named "beaker/other_beaker.rb" with:
      """
      describe "Other", :depth => 'shallow' do
        let(:book) { Formulas::Bookie.new(@driver) }

        it "loads an external web page" do
          book.open "http://www.google.com"
        end
      end
      """
    When I run `ckit brew --beaker=beaker/other_beaker.rb`
    Then the stdout should contain "1 example, 0 failures"

