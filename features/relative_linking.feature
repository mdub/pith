Feature: linking between files

  I want to be able to generate relative reference to other pages
  So that the generated site is re-locateable

Scenario: link from one top-level page to another

  Given input file "index.html.haml" contains 
    """
    = link("page.html", "Page")
    """
  And input file "page.html" exists
   
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
  And input file "help.html" exists

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
  And input file "logo.png" exists

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

  And input file "subdir/other.html" exists

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

  And input file "stylesheets/app.css" exists

  When I build the site
  Then output file "subdir/page.html" should contain
    """
    <link href='../stylesheets/app.css' rel='stylesheet' type='text/css' />
    """

@wip
Scenario: use "title" meta-data attribute in link

  Given input file "index.html.haml" contains 
    """
    = link("page.html")
    """

  And input file "page.html.haml" contains
    """
    -# ---
    -# title: "Title from meta-data"
    -# ...
    """

  When I build the site

  Then output file "index.html" should contain
    """
    <a href="page.html">Title from meta-data</a>
    """
