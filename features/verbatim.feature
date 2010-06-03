Feature: copy unrecognised files intact

  I want any unrecognised file to be copied into the site verbatim
  So that I can mix dynamic and static content
  
Scenario: text file

  Given input file "verbatim.txt" contains
    """
    Blah de blah
    """
    
  When I build the site
  
  Then output file "verbatim.txt" should contain
    """
    Blah de blah
    """
