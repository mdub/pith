Feature: metadata

  I want extract metadata from page source
  So that I can use it elsewhere
  
Scenario: link from one top-level page to another

  Given input file "page.html.haml" contains
    """
    -# ---
    -# title: PAGE TITLE
    -# ...
    %h1= meta["title"]
    """

  When I build the site
  Then output file "page.html" should contain
    """
    <h1>PAGE TITLE</h1>
    """
