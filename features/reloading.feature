Feature: incremental rebuilding

  I want to reload any altered Ruby code
  So that I can quickly iterate config and support libraries

@wip
Scenario: change a helper

  Given input file "_pith/config.rb" contains
    """
    lib_dir = File.expand_path("../lib", __FILE__)
    $: << lib_dir unless $:.member?(lib_dir)

    require 'stuff'

    project.helpers do
      include Stuff
    end
    """

  And input file "_pith/lib/stuff.rb" contains

    """
    module Stuff
      def greet(subject)
        "Hello, #{subject}"
      end
    end
    """

  And input file "index.html.haml" contains "= greet('mate')"

  When I build the site

  Then output file "index.html" should contain "Hello, mate"

  When I change input file "_pith/lib/stuff.rb" to contain
    """
    module Stuff
      def greet(subject)
        "Hola, #{subject}"
      end
    end
    """

  And I rebuild the site

  Then output file "index.html" should contain "Hola, mate"
