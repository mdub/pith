Feature: format Haml input

  I want file with a .html extension to be formatted using Haml
  
Scenario: Haml template with no layout

  Given input file "index.html.haml" contains
    """
    %h1 Header
    
    %p
      Some text
    """
    
  When I build the site
  
  Then output file "index.html" should contain
    """
    <h1>Header</h1>
    <p>
      Some text
    </p>
    """

@wip
Scenario: Haml template with a layout

  Given input file "layouts/_default.haml" contains
    """
    %html
      %head
        %title= @title
      %body
        %h1= @title
        = yield
    """

  And input file "index.html.haml" contains
    """
    = partial "layouts/_default" do
      - @title = "XXX"
      %p blah blah
    """
   
  When I build the site
  
  Then output file "index.html" should contain
    """
    <html>
      <head>
        <title>XXX</title>
      </head>
      <body>
        <h1>XXX</h1>
        <p>blah blah</p>
      </body>
    </html>
    """
