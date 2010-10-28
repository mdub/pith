Feature: ignorable files are ignored

  I want certain files (or directories) to be ignored
  So that I can place supporting files anywhere within the input directory

Scenario Outline: ignorable templates

  Given input file <input> exists
  When I build the site
  Then output file <output> should not exist

  Examples:
    | input                           | output                  |
    | "_layout.haml"                  | "_layout"               |
    | "_partials/foo.html.haml"       | "_partials/foo.html"    |
    | "partials/_foo.html.haml"       | "partials/_foo.html"    |

Scenario Outline: ignorable resources

  Given input file <file> exists
  When I build the site
  Then output file <file> should not exist

  Examples:
    | file                  |
    | "_data/xyz.json"      |
    | ".git/config"         |
    | "xyz/.svn/blah"       |
