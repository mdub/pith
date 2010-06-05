Feature: linking between files

  I want to be able to link pages easily

Scenario: link from one top-level page to another

  Given input file "index.html.haml" contains
    """
    = link("page.html", "Page")
    """

  When I build the site
  Then output file "index.html" should contain
    """
    <a href="page.html">Page</a>
    """
