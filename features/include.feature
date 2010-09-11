Feature: templates can include other templates

  I want to be able to include partials
  So that I can reuse template fragments

Scenario: include a partial

  Given input file "index.html.haml" contains "= include('_fragment.haml')"
  And input file "_fragment.haml" contains "%p blah blah"
  When I build the site
  Then output file "index.html" should contain "<p>blah blah</p>"

Scenario: include a static resource

  Given input file "index.html.haml" contains "= include('_fragment.html')"
  And input file "_fragment.html" contains "<p>blah blah</p>"
  When I build the site
  Then output file "index.html" should contain "<p>blah blah</p>"

Scenario: include a partial in the same sub-directory

  Given input file "subdir/page.html.haml" contains "= include('_fragment.haml')"
  And input file "subdir/_fragment.haml" contains "%p blah blah"
  When I build the site
  Then output file "subdir/page.html" should contain "<p>blah blah</p>"

Scenario: nested includes, differing directories

  Given input file "page.html.haml" contains "= include('_partials/foo.haml')"
  And input file "_partials/foo.haml" contains "= include('bar.haml')"
  And input file "_partials/bar.haml" contains "bananas"
  When I build the site
  Then output file "page.html" should contain "bananas"

Scenario: include a partial located relative to site root

  Given input file "subdir/page.html.haml" contains "= include('/_partials/fragment.haml')"
  And input file "_partials/fragment.haml" contains "%p blah blah"
  When I build the site
  Then output file "subdir/page.html" should contain "<p>blah blah</p>"

Scenario: pass local variable to a partial

  Given input file "index.html.haml" contains
    """
    = include("_list.haml", :items => [1,2,3])
    """

  And input file "_list.haml" contains
    """
    %ul
      - items.each do |i|
        %li= i
    """
   
  When I build the site
  
  Then output file "index.html" should contain
    """
    <ul>
      <li>1</li>
      <li>2</li>
      <li>3</li>
    </ul>
    """

Scenario: use instance variable in a partial

  Given input file "index.html.haml" contains
    """
    - @items = [1,2,3]
    = include("_list.haml")
    """

  And input file "_list.haml" contains
    """
    %ul
      - @items.each do |i|
        %li= i
    """
   
  When I build the site
  
  Then output file "index.html" should contain
    """
    <ul>
      <li>1</li>
      <li>2</li>
      <li>3</li>
    </ul>
    """
