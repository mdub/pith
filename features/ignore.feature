Feature: ignore partials and layouts

  I want any file beginning with "_" to be ignored
  
Scenario: layout

  Given input file "_layout.haml" contains
    """
    Blah de blah
    """
    
  When I build the site
  
  Then output file "_layout" should not exist
