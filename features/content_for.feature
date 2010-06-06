Feature: templates can be used as layouts

  I want to encapsulate a chunk of content
  So that I can use it inside a layout

Scenario: Haml template with a layout

  Given input file "index.html.haml" contains
    """
    = include "_layout.haml" do
      - content_for[:sidebar] = capture_haml do
        %p SIDEBAR
      %p MAIN
    """
  And input file "_layout.haml" contains 
    """
    #sidebar
      = content_for[:sidebar]
    = yield
    """
   
  When I build the site
  Then output file "index.html" should contain 
    """
    <div id='sidebar'>
      <p>SIDEBAR</p>
    </div>
    <p>MAIN</p>
    """
