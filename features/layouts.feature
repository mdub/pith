Feature: layouts

  I want to be able to apply a layout
  So that I can reuse template patterns

Scenario: Haml template with a layout

  Given input file "layouts/_default.haml" contains
    """
    %html
      %head
        %title= title
      %body
        %h1= title
        = yield
    """

  And input file "index.html.haml" contains
    """
    = partial "layouts/_default.haml", :title => "XXX" do
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
