Feature: ckit brew

  Running `ckit brew` runs the suite of tests.

  Background: Setup the project
    Given I run `ckit new booker`
    And a file named "booker/formulas/bookie.rb" with:
      """ruby
      module PageObjects
        class Bookie
          def initialize(driver)
            @driver = driver
          end
        end
      end
      """
    And a file named "booker/beaker/bookie_beaker.rb" with:
      """ruby
      describe "Bookie", :depth => 'shallow' do
        before(:each) do
          @book = PageObjects::Bookie.new(@driver)
        end

        it "check on sauce" do
          true
        end
      end
      """

  @announce
  Scenario: Returns true
    Given I cd to "booker"
    When I run `ckit brew`
    Then the stdout should contain "1 example, 0 failures"
