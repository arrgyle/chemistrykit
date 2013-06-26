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

  Scenario Outline: Run All Configurations
    When I overwrite _config.yaml with:
      """
      log: 'evidence'
      host: '<%= <hostname> %>'
      sauce_username: 'testing_arrgyle'
      sauce_api_key:  'ab7a6e17-16df-42d2-9ef6-c8d2539cc38a'
      """
    When I run `ckit brew`
    Then the stdout should contain "1 example, 0 failures"
    And the following files should exist:
      | evidence/SPEC-Bookie.xml  |
      | evidence/server.log       |

    Examples:
    | hostname    |
    | "localhost" |
#    | "saucelabs" |


