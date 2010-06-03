Feature: format Haml input

  I want file with a .html extension to be formatted using Haml
  
Scenario: Haml template with no layout

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
