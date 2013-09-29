Pith [![Build Status](https://secure.travis-ci.org/mdub/pith.png?branch=master)](http://travis-ci.org/mdub/pith)
====

Pith is a static website generator, written in Ruby.

Using Pith, you can:

* Lay-out your page designs in [Haml][haml], ERb, or Liquid.
* Style things up using [Sass][sass].
* Succintly add content using Markdown or Textile.
* Encapsulate common markup in "layout" and "partial" templates.
* Easily link pages (and resources) using relative links.
* Test changes quickly using the built-in web-server.

Install it
----------

Pith is packaged as a Ruby gem.  Assuming you have Ruby, install it thusly:

    gem install pith

Quickstart
----------

Create an input directory for your site (wherever you want), and pop some files into it:

    SITE/
      _pith/
      images/
        logo.png
      index.html.haml

The only requirement is the existance of a subdirectory called "`_pith`".  Pith checks that it's present, to prevent you accidently treating your entire home directory as website input.

Next, use the `pith build` command to convert your inputs into a functioning website.

    $ pith -i SITE build
    Generating to "SITE/_out"
    --(copy)-->   images/logo.png
    --(haml)-->   index.html

By default, output is generated into an subdirectory called "`_out`", inside the input directory ... but the default can be easily overridden, e.g.

    $ pith -i SITE -o OUTPUT build

Templates
---------

Files in the input directory are considered to be "templates" if the file name ends with a template format extension recognised as such by [Tilt][tilt], e.g. "`.haml`", or "`.textile`".  These will be evaluated dynamically.  Pith strips the format extension off the file name when generating output.

Tilt supports a wide variety of formats, including:

- [Markdown](http://daringfireball.net/projects/markdown/) (`markdown`, `md`)
- [Textile](http://redcloth.org/hobix.com/textile/) (`textile`)
- [Haml][haml] (`haml`)
- [Erb](http://ruby-doc.org/stdlib/libdoc/erb/rdoc/classes/ERB.html) (`erb`)
- [Sass][sass] (`sass`)
- [CoffeeScript](http://jashkenas.github.com/coffee-script/) (`coffee`)

At one end of the spectrum are the "template engines", like ERB/Erubis and Liquid, which allow insertion of dynamic content into a template.  These aren't really HTML-specific; they can be used to generate any output format ... really, they're just string interpolation on steroids.

At the other end of the spectrum are "markup formats" like Markdown, Textile, Creole, which are targeted specifically at HTML output ... but don't support insertion of dynamic content.

In the middle are hybrids like Haml, and Markaby, which are both HTML-focused, but support dynamic content.

Pipelining
----------

If you want both dynamic content, and simplified markup, in the same template, one option is to use Haml.

The alternative to Haml, if you want both dynamic content, and less angle-bracket, is to combine a template format with a markup format.  For example, you can create a "page.md.liquid" template, which would undergo first Liquid template expansion (for dynamic content), and then Markdown processing (for generation of HTML).

Resources
---------

Any non-template input files (we call them "resources") are just copied verbatim into the output directory.

Ignored files
-------------

Files or directories beginning with an underscore are ignored; that is, we don't generate corresponding output files.  They can still be used as "layout" or "partial" templates though; see below.

Page metadata
-------------

A YAML header can be provided at the top of any template, defining page metadata.  The header is introduced by a first line containing three dashes, and terminated by a line containing three dots.

    ---
    title: "Fish"
    subtitle: "All about fish"
    ...

Metadata provided in the header can be referenced by template content, via the "`page.meta`" Hash:

    %html
      %head
        %title= page.meta["title"]
      %body
        %h1= page.meta["title"]
        %h2= page.meta["subtitle"]

This is especially useful in "layout" templates (see below).

Since the page title is such a common thing to want to specify in the header, it's also available as "`page.title`", as a shortcut (if no explicit title was provided, Pith will guess one from the input file name).

Partials and Layouts
--------------------

Templates can include other templates, e.g.

     = include "_header.haml"

When including, you can pass local variables, e.g.

    = include "_list.haml", :items => [1,2,3]

which can be accessed in the included template:

    %ul
      - items.each do |i|
        %li= i

In Haml templates, you can also pass a block, e.g.

    = include "_mylayout.haml" do
      %p Some content

and access it in the template using "`yield`":

    !!!
    %html
      %body
        .header
          ... blah blah ...
        .main
          = yield

This way, any template can be used as a "layout".

Layouts can also be applied by using a "`layout`" entry in the page header, e.g.

    ---
    layout: "/_mylayout.haml"
    ...

    Some content

Relative links
--------------

It's sensible to use relative URIs when linking to other pages (and resources) in your static site, making the site easier to relocate.  But generating relative-links from partials and layouts is tricky.  Pith makes it easy with the "`href`" function:

    %a{:href => href("other.html")} Other page

    %img{:src => href("/images/logo.png")}

Any path beginning with a slash ("/") is resolved relative to the root of the site; anything else is resolved relative to the current input-file (even if that happens to be a layout or partial).  Either way, "`href`" always returns a relative link.

There's also a "`link`" function, for even easier hyper-linking:

    link("other.html", "Other page")

Configuring Pith
----------------

The behaviour of Pith can be customised somewhat, by dropping a "`config.rb`" file into the "`_pith`" directory.

There are a couple of flags that can be set to modify generation of links using "`href`" and "`link`":

    project.assume_content_negotiation = true
    project.assume_directory_index = true

Both flags default to false.  When `assume_content_negotiation` is enabled, Pith omits the ".html" suffix from links.  When `assume_directory_index` is enabled, Pith abbreviates links to "index.html" files.  Both of these assumptions work nicely when the generated files are served using a web-server such as Apache httpd, but aren't appropriate if you wish to navigate them as static files on the filesystem.

It's also possible to mix behaviour into Pith, using the config file, e.g.

    project.helpers do

      def handy_method
        # ...
      end

    end

Any methods defined in a `project.helpers` block are available for use in templates.

For a more extensive example of a config file, look [over here](https://github.com/mdub/dogbiscuit.org/blob/master/src/_pith/config.rb).

Incremental rebuild
-------------------

For quick prototyping, use the "`watch`" command, rather than "`build`".  After building your site, Pith will stay running, and regenerate output files (as necessary) as you edit the inputs.  We keep track of which input files are involved in the production of each output, so only the affected outputs are re-generated.

    $ pith -i SITE watch
    Generating to "SITE/_out"
    --> images/logo.png
    --> index.html
    # ... edit "index.html.haml" ...
    --> index.html

Built-in web-server
-------------------

For even quicker prototyping, Pith includes a simple HTTP server.  Start it by using the "`serve`" command, rather than "`build`"

    $ pith -i SITE serve
    Generating to "SITE/_out"
    --> images/logo.png
    --> index.html
    Taking the Pith at "http://localhost:4321"
    >> Thin web server (v1.2.7 codename No Hup)
    >> Maximum connections set to 1024
    >> Listening on 0.0.0.0:4321, CTRL+C to stop

Pith will incrementally re-build the site as you browse -- that is, if you alter any input files, Pith will regenerate the affected outputs.

Plugins
-------

Pith includes a couple of optional "plugins".  Actually, "plugin" is a bit strong: they're just plain old Ruby modules that extend Pith's functionality.

### Publication plugin

The 'publication' plugin makes it easier to build a weblog using Pith.

Enable it by requiring it in your "`config.rb`", like so:

    require "pith/plugins/publication"

Now you can specify a "published" date/time in the metadata of any pages you consider to be "articles", e.g.

    ---
    title: Introducing ShamRack
    published: 3-July-2009, 15:50
    ...

This exposes "`page.published_at`" for use in your templates.

In addition, "`project.published_inputs`" lists all the pages that have such a timestamp, in order of publication, making it easy to build index pages and XML feeds.  Here's a example, used to build the article index for [dogbiscuit.org](http://dogbiscuit.org/mdub/weblog):

    %ul.articles
      - project.published_inputs.reverse.each do |entry|
        %li
          %p
            = link(entry)
            %span.teaser
              %span.published_at
                on
                = entry.published_at.strftime("%e %b, %Y")

### Compass plugin

The Compass plugin gives you the full power of [Compass][compass] in your Sass stylesheets.  Enable it by requiring it in your "`config.rb`":

    require "pith/plugins/compass"

Note that if you're using Bundler, you'll also need to include the Compass gem in your `Gemfile`.

    gem "compass"

[tilt]: http://github.com/rtomayko/tilt/
[haml]: http://haml-lang.com
[sass]: http://sass-lang.com
[compass]: http://compass-style.org

