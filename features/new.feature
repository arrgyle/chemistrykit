Feature: ckit new

  Run "ckit new <project_name>" to generate a new ChemistryKit project

  Background: Running ckit new
    When I run `bundle exec ckit new new-project`
    And I cd to "new-project"

  @announce
  Scenario: Test Harness is created
    Then the following directories should exist:
      | beakers                 |
      | formulas                |
      | formulas/lib            |
      | formulas/lib/catalysts  |
      | evidence                |
    And the following files should exist:
      | _config.yaml            |
      | .rspec                  |
      | formulas/lib/formula.rb |
