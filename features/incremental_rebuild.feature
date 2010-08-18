Feature: incremental rebuilding

  I want to rebuild just the outputs whose inputs have changed
  So that that I can bring the project up-to-date efficiently
  
Scenario: alter an input, and the output changes

  Given input file "page.html.haml" contains "Old content"
  And the site is up-to-date

  When I change input file "page.html.haml" to contain "New content"
  And I rebuild the site
  
  Then output file "page.html" should be re-generated
  And output file "page.html" should contain "New content"

Scenario: don't alter an input, and the output is untouched

  Given input file "page.html.haml" contains "Content"
  And the site is up-to-date

  When I rebuild the site

  Then output file "page.html" should not be re-generated
