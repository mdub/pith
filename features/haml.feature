Feature: support for Haml

  I want to build pages using Haml
  So that I can express markup succintly
  
Scenario: simple Haml page

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
