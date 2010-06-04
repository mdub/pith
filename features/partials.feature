Feature: partials

  I want to be able to include partials
  So that I can reuse template fragments

Scenario: Haml template including a Haml partial

  Given input file "index.html.haml" contains
    """
    %h1 With a partial
    = partial("_fragment.haml")
    """

  And input file "_fragment.haml" contains
    """
    %p blah blah
    """
   
  When I build the site
  
  Then output file "index.html" should contain
    """
    <h1>With a partial</h1>
    <p>blah blah</p>
    """
