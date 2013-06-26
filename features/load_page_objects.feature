Feature: Load Page Objects
Formulas should be loaded in the correct order with thier dependencies

  Scenario: Load the libs first
    Given I run `ckit new big-project`
    And I cd to "big-project"
    And a file named "formulas/big.rb" with:
      """
      module Formulas
        class BigProject < Formula

          def open(url)
            helper_open(url)
          end

        end
      end
      """

    And a file named "formulas/lib/formula.rb" with:
      """
      module Formulas
        class Formula < ChemistryKit::Formula::Base
          def helper_open(url)
            @driver.get url
          end
        end
      end
      """

    And a file named "beaker/big_beaker.rb" with:
      """
      describe "Big", :depth => 'shallow' do
        let(:book) { Formulas::BigProject.new(@driver) }

        it "loads an external web page" do
          book.open "http://www.google.com"
        end
      end
      """

    When I run `ckit brew`
    Then the stdout should contain "1 example, 0 failures"
