Feature: support for Haml templates

  I want files with a .haml extension to be formatted using Haml
  So that I can express markup succintly
  
Scenario: simple Haml template

  Given input file "index.html.haml" contains
    """
    %h1 Header
    
    %p
      Some text
    """
    
  When I build the site
  
  Then output file "index.html" should contain
    """
    <h1>Header</h1>
    <p>
      Some text
    </p>
    """
