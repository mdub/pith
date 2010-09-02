Feature: metadata

  I want extract metadata from page source
  So that I can use it elsewhere
  
Scenario: use meta-data from YAML comment

  Given input file "page.html.haml" contains
    """
    ---
    title: PAGE TITLE
    ---
    %h1= page.title
    """

  When I build the site
  Then output file "page.html" should contain
    """
    <h1>PAGE TITLE</h1>
    """

Scenario: corrupt meta-data

  Given input file "page.html.haml" contains
    """
    ---
    title: "This" is no well-formed YAML
    ...
    %p PAGE BODY
    """

  When I build the site
  Then output file "page.html" should contain
    """
    <p>PAGE BODY</p>
    """
