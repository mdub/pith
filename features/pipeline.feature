Feature: apply multiple template processors

  I want to apply multiple template processors
  So that I can take advantage of the best features of each

Scenario: Markdown page with embedded ERB

  Given input file "article.html.md.erb" contains
    """
    <% %w(one two three).each do |n| %>
    - <%= n %>
    <% end %>
    """

  When I build the site

  Then output file "article.html" should contain
    """
    <ul>
    <li>one</li>
    <li>two</li>
    <li>three</li>
    </ul>
    """
