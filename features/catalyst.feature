Feature: Inject a Catalyst
Using a catalyst to encapsulate arbitraty data from a csv file for data
driven tests.

  Scenario: Use a catalyst value to drive a test
    Given I run `ckit new catalyst-project`
    And I cd to "catalyst-project"

    And a file named "formulas/lib/catalysts/test_data.csv" with:
    """
    url,http://www.google.com
    """

    And a file named "formulas/big.rb" with:
      """
      module Formulas
        class CatProject < Formula

          def do_a_thing
            helper_open(catalyst.url)
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
      describe "Cat", :depth => 'shallow' do
        let(:book) { Formulas::CatProject.new(@driver) }

        it "loads an external web page" do
          meow_catalyst = ChemistryKit::Catalyst.new('formulas/lib/catalysts/test_data.csv')
          book.catalyst = meow_catalyst
          book.do_a_thing
        end
      end
      """

    When I run `ckit brew`
    Then the stdout should contain "1 example, 0 failures"


    # And a file named "formulas/lib/catalysts/test_data.csv" with:
    # """
    # url,http://www.google.com
    # """

    # And a file named "beaker/catalyst_beaker.rb" with:
    #   """
    #   describe "Meow", :depth => 'shallow' do
    #     let(:meow) { Formulas::Meow.new(@driver) }

    #     meow_catalyst = ChemistryKit::Catalyst.new('formulas/lib/catalysts/test_data.csv')
    #     meow.catalyst = meow_catalyst

    #     it "loads an external web page" do
    #       meow.do_a_thing
    #     end
    #   end
    #   """


    # And a file named "formulas/meow.rb" with:
    #   """
    #   module Formulas
    #     class Meow < Formula

    #       def do_a_thing
    #         helper_open(catalyst.url)
    #       end

    #     end
    #   end
    #   """

    # And a file named "formulas/lib/formula.rb" with:
    #   """
    #   module Formulas
    #     class Formula < ChemistryKit::Formula::Base
    #       def helper_open(url)
    #         @driver.get url
    #       end
    #     end
    #   end
    #   """
