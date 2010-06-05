Feature: layouts

  I want to be able to apply a layout
  So that I can reuse template patterns

Scenario: Haml template with a layout

  Given input file "layouts/_simple.haml" contains
    """
    %p= yield
    """

  And input file "index.html.haml" contains
    """
    = include "layouts/_simple.haml" do
      blah blah
    """
   
  When I build the site
  
  Then output file "index.html" should contain
    """
    <p>blah blah</p>
    """

Scenario: refer to a instance variable

  Given input file "layouts/_with_header.haml" contains
    """
    %h1= @title
    = yield
    """

  And input file "index.html.haml" contains
    """
    = include "layouts/_with_header.haml" do
      - @title = "XXX"
      %p blah blah
    """
   
  When I build the site
  
  Then output file "index.html" should contain
    """
    <h1>XXX</h1>
    <p>blah blah</p>
    """
