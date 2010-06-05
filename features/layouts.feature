Feature: templates can be used as layouts

  I want to be able to apply a layout
  So that I can reuse template patterns

Scenario: Haml template with a layout

  Given input file "index.html.haml" contains
    """
    = include "layouts/_simple.haml" do
      blah blah
    """
  And input file "layouts/_simple.haml" contains 
    """
    %p= yield
    """
   
  When I build the site
  Then output file "index.html" should contain 
    """
    <p>blah blah</p>
    """

Scenario: instance variable assigned within the layed-out block

  Given input file "index.html.haml" contains
    """
    = include "layouts/_with_header.haml" do
      - @title = "XXX"
      %p blah blah
    """
  And input file "layouts/_with_header.haml" contains
    """
    %h1= @title
    = yield
    """
   
  When I build the site
  Then output file "index.html" should contain
    """
    <h1>XXX</h1>
    <p>blah blah</p>
    """
