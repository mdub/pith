Feature: helper methods

  I want to extend Pith with helper methods
  So that I can use them in templates

Scenario: call a helper from a template

  Given input file "_pith/config.rb" contains
    """
    project.helpers do
      
      def greet(subject = "mate")
        "Hello, #{subject}"
      end
      
    end
    """

  And input file "index.html.haml" contains "= greet('World')"
   
  When I build the site
  
  Then output file "index.html" should contain "Hello, World"

Scenario: change a helper

  Given input file "_pith/config.rb" contains
    """
    project.helpers do
      def greet(subject)
        "Hello, #{subject}"
      end
    end
    """

  And input file "index.html.haml" contains "= greet('mate')"
   
  When I build the site

  And I change input file "_pith/config.rb" to contain
    """
    project.helpers do
      def greet(subject)
        "Gidday, #{subject}"
      end
    end
    """

  And I rebuild the site
  
  Then output file "index.html" should contain "Gidday, mate"
