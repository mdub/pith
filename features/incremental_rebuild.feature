Feature: incremental rebuilding

  I want to rebuild just the outputs whose inputs have changed
  So that I can bring the project up-to-date efficiently

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

Scenario: alter a dependency

  Given input file "page.html.haml" contains "= include('_partials/foo.haml')"
  And input file "_partials/foo.haml" contains "bananas"
  And the site is up-to-date

  When I change input file "_partials/foo.haml" to contain "New content"
  And I rebuild the site

  Then output file "page.html" should be re-generated
  And output file "page.html" should contain "New content"

Scenario: delete a dependency

  Given input file "fruits.html.haml" contains
    """
    - project.inputs.map(&:path).map(&:to_s).grep(/^_fruit/).sort.each do |input_name|
      %p= include(input_name)
    """

  And input file "_fruit/a.html.haml" contains
    """
    apple
    """

  And input file "_fruit/b.html.haml" contains
    """
    banana
    """

  And the site is up-to-date

  Then output file "fruits.html" should contain
    """
    <p>apple</p>
    <p>banana</p>
    """

  When I remove input file "_fruit/a.html.haml"
  And I rebuild the site

  Then output file "fruits.html" should be re-generated
  And output file "fruits.html" should contain
    """
    <p>banana</p>
    """

Scenario: alter meta-data

  Given input file "index.html.haml" contains
    """
    - project.inputs.select do |input|
      - output.record_dependency_on(input)
      - if input.meta["flavour"]
        %p= input.meta["flavour"]
    """

  And input file "page.html.haml" contains
    """
    ---
    flavour: Chocolate
    ---
    """

  When I build the site
  Then output file "index.html" should contain "<p>Chocolate</p>"

  When I change input file "page.html.haml" to contain
    """
    ---
    flavour: Strawberry
    ---
    """

  And I rebuild the site

  Then output file "index.html" should be re-generated
  Then output file "index.html" should contain "<p>Strawberry</p>"
