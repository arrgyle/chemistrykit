[![Gem Version](https://badge.fury.io/rb/chemistrykit.png)](http://badge.fury.io/rb/chemistrykit)
[![Code Climate](https://codeclimate.com/github/arrgyle/chemistrykit.png)](https://codeclimate.com/github/arrgyle/chemistrykit)

ChemistryKit
============================================================

### A simple and opinionated web testing framework for Selenium WebDriver

This framework was designed to help you get started with Selenium WebDriver quickly, to grow as needed, and to avoid common pitfalls by following convention over configuration.

ChemistryKit's inspiration comes from the Saunter Selenium framework which is available in Python and PHP. You can find more about it [here](http://element34.ca/products/saunter).

## Getting Started

    $ gem install chemistrykit
    $ ckit new framework_name

This will create a new folder with the name you provide and it will contain all of the bits you'll need to get started.

    $ cd framework_name
    $ ckit generate beaker beaker_name

This will generate a beaker file (a.k.a. test script) with the name you provide (e.g. hello_world). Add your Selenium actions and assertions to it.

    $ ckit brew

This will run ckit and execute your beakers. By default it will run the tests locally by default. But you can change where the tests run and all other relevant bits in \_config.yaml. You can find out more about this [here](https://github.com/arrgyle/chemistrykit/wiki/Configs).


## Contributing

This project conforms to the [neverstopbuilding/craftsmanship](https://github.com/neverstopbuilding/craftsmanship) guidelines. Please see them for details.

### Install Dependencies

    bundle install

### Run rake task to test code

    rake build
