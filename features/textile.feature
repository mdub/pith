Feature: support for Textile markup

  I want to use Textile fragments in pages
  So that I can express content succintly

Scenario: Haml page with embedded Textile

  Given input file "_pith/config.rb" contains
    """
    require 'haml'
    require 'haml/filters/textile'
    """

  Given input file "page.html.haml" contains
    """
    :textile

      A paragraph.

      * one
      * two
      * three
    """

  When I build the site

  Then output file "page.html" should contain
    """
    <p>A paragraph.</p>
    <ul>
      <li>one</li>
      <li>two</li>
      <li>three</li>
    </ul>
    """
