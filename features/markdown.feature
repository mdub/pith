Feature: support for Markdown

  I want to build pages using Markdown
  So that I can express content succintly
  
Scenario: Simple Markdown

  Given input file "article.html.md" contains
    """
    - Yen (¥)
    - Pound (£)
    - Euro (€)
    """

  When I build the site
  
  Then output file "article.html" should contain
    """
    <ul>
    <li>Yen (¥)</li>
    <li>Pound (£)</li>
    <li>Euro (€)</li>
    </ul>
    """
