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

Scenario: link from a sub-directory to a root-level page

  Given input file "subdir/page.html.haml" contains
    """
    = link("/help.html", "Help")
    """

  When I build the site
  Then output file "subdir/page.html" should contain
    """
    <a href="../help.html">Help</a>
    """

Scenario: link to an image

  Given input file "subdir/page.html.haml" contains
    """
    %img{:src => href("/logo.png")}
    """

  When I build the site
  Then output file "subdir/page.html" should contain
    """
    <img src='../logo.png' />
    """

Scenario: links within a layout block

  Given input file "subdir/page.html.haml" contains
    """
    = include "/common/_layout.haml" do
      = link "other.html", "Other page"
    """

  And input file "common/_layout.haml" contains
    """
    = yield
    """

  When I build the site
  Then output file "subdir/page.html" should contain
    """
    <a href="other.html">Other page</a>
    """

Scenario: links included from a partial

  Given input file "subdir/page.html.haml" contains
    """
    = include "/common/_partial.haml"
    """

  And input file "common/_partial.haml" contains
    """
    %link{ :href=>href("/stylesheets/app.css"), :rel=>"stylesheet", :type=>"text/css" }
    """

  When I build the site
  Then output file "subdir/page.html" should contain
    """
    <link href='../stylesheets/app.css' rel='stylesheet' type='text/css' />
    """
