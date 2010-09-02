Feature: unrecognised input files are copied into output intact

  I want any unrecognised file to be copied into the site verbatim
  So that I can mix dynamic and static content
  
Scenario: text file

  Given input file "resource.txt" contains
    """
    Blah de blah
    """
    
  When I build the site
  
  Then output file "resource.txt" should contain
    """
    Blah de blah
    """

Scenario: file in subdirectory

  Given input file "blah/resource.txt" contains
    """
    Blah de blah
    """
    
  When I build the site
  
  Then output file "blah/resource.txt" should contain
    """
    Blah de blah
    """
