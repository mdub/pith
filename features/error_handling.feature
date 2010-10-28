Feature: error handling

  I want to be told when something goes wrong
  
Scenario: bad haml

  Given input file "index.html.haml" contains
    """
    %h2{class="this is not valid ruby"} Heading
    
    %p Content
    """
    
  When I build the site
  
  Then output file "index.html" should contain /syntax error/
