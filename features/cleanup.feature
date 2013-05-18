Feature: automatic cleanup

  I want old outputs removed from the output directory
  So that they don't hang around

Scenario: output without matching input

  Given output file "blah.txt" exists

  When I build the site

  Then output file "blah.txt" should not exist

Scenario: input removed

  Given input file "blah.txt" exists

  When I build the site
  And I remove input file "blah.txt"
  And I rebuild the site

  Then output file "blah.txt" should not exist
