Feature: ignore supporting files

  I want any file beginning with "_" to be ignored
  So that I can place supporting files anywhere within the input directory
  
Scenario: a layout template at the input root

  Given input file "_layout.haml" contains
    """
    Blah de blah
    """
    
  When I build the site
  
  Then output file "_layout" should not exist

Scenario: a partial in a subdirectory

  Given input file "_partials/foo.html.haml" contains
    """
    Blah de blah
    """
    
  When I build the site
  
  Then output file "_partials/foo.html" should not exist
