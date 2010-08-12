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

Scenario: links included from a layout

  Given input file "subdir/page.html.haml" contains
    """
    = include "/common/_layout.haml" do
      %p Stuff
    """

  And input file "common/_layout.haml" contains
    """
    %html
      %head
        %link{ :href=>href("/stylesheets/app.css"), :rel=>"stylesheet", :type=>"text/css" }
      %body
        %img{:src => href("logo.png")}
        = yield
    """

  When I build the site
  Then output file "subdir/page.html" should contain
    """
    <html>
      <head>
        <link href='../stylesheets/app.css' rel='stylesheet' type='text/css' />
      </head>
      <body>
        <img src='../common/logo.png' />
        <p>Stuff</p>
      </body>
    </html>
    """
