Feature: Compass integration

  I want to integrate Compass
  So that I can use it inside a layout

Background:

  Given input file "_pith/config.rb" contains
    """
    require 'pith/plugins/compass'
    """

Scenario: Sass template

  Given input file "style.css.sass" contains
    """
    @import "compass/typography/links/hover-link"

    a.mylink
      @include hover-link
    """

  When I build the site
  Then output file "style.css" should contain /a.mylink { text-decoration: none; }/

Scenario: Scss template

  Given input file "style.css.scss" contains
    """
    @import "compass/typography/links/hover-link";

    a.mylink {
      @include hover-link;
    }
    """

  When I build the site
  Then output file "style.css" should contain /a.mylink { text-decoration: none; }/
