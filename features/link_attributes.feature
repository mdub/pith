Feature: link method with attributes

  I want to be able to pass arguments to the link method
  So that additional attributes are generated

Scenario: link with class attribute

  Given input file "index.html.haml" contains
    """
    = link("page.html", "Page", :class => 'active')
    """
  And input file "page.html" exists

  When I build the site
  Then output file "index.html" should contain /<a [class="active", href="page.html"]/

Scenario: link with title attribute

  Given input file "index.html.haml" contains
    """
    = link("page.html", "Page", :title => 'click me')
    """
  And input file "page.html" exists

  When I build the site
  Then output file "index.html" should contain /<a [title="click me", href="page.html"]/

Scenario: link with title and class attributes

  Given input file "index.html.haml" contains
    """
    = link("page.html", "Page", :title => 'click me', :class => 'active')
    """
  And input file "page.html" exists

  When I build the site
  Then output file "index.html" should contain /<a [title="click me", class="active", href="page.html"]/
