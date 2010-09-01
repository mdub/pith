Pith
====

Pith is a static web-site generator, written in Ruby.

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
      images/
        logo.png
      index.html.haml

Use the `pith build` command to convert your inputs into a functioning website.

    $ pith -i SITE build
    Generating to "SITE/_out"
    --(copy)-->   images/logo.png
    --(haml)-->   index.html

Any input file with an extension recognised by [Tilt][tilt] is considered to be a template, and will be dynamically evaluated.  Formats supported by Tilt include:

- [Markdown](http://daringfireball.net/projects/markdown/) (`markdown`, `md`)
- [Textile](http://redcloth.org/hobix.com/textile/) (`textile`)
- [Haml][haml] (`haml`)
- [Erb](http://ruby-doc.org/stdlib/libdoc/erb/rdoc/classes/ERB.html) (`erb`)
- [Sass][sass] (`sass`)
- [CoffeeScript](http://jashkenas.github.com/coffee-script/) (`coffee`)

Anything else is just copied verbatim into the generated site.

Partials
--------

Templates can include other templates, e.g.

     = include("_header.haml")

Note the leading underscore ("_").  Any input file (or directory) beginning with an underscore is ignored when generating outputs.

When including, you can pass local variables, e.g.

    = include("_list.haml", :items => [1,2,3])

which can be accessed in the included template:

    %ul
      - items.each do |i|
        %li= i

Layouts
-------

Layout templates are a bit like partials, except that they take a block, e.g.

    = inside "_mylayout.haml" do
      %p Some content

Use "`yield`" to embed the block's content within the layout:

    !!!
    %html
      %body
        .header
          ... blah blah ...
        .main
          = yield

Relative links
--------------

It's sensible to use relative URIs when linking to other pages (and resources) in your static site, making the site easier to relocate.  But generating relative-links from partials and layouts is tricky.  Pith makes it easy with the "`href`" function:

    %a{:href => href("other.html")} Other page

    %img{:src => href("/images/logo.png")}

Any path beginning with a slash ("/") is resolved relative to the root of the site; anything else is resolve relative to the current input-file (even if that happens to be a layout or partial).  Either way, "`href`" always returns a relative link.

There's also a "`link`" function, for even easier hyper-linking:

    link("other.html", "Other page")
    
Built-in web-server
-------------------

For quick prototyping, pith includes a simple HTTP server.  Start it by using the "`serve`" command, rather than "`build`"

    $ pith -i SITE serve
    Generating to "SITE/_out"
    --(copy)-->   images/logo.png
    --(haml)-->   index.html
    Taking the Pith at "http://localhost:4321"
    >> Thin web server (v1.2.7 codename No Hup)
    >> Maximum connections set to 1024
    >> Listening on 0.0.0.0:4321, CTRL+C to stop

Pith will incrementally re-build the site as you browse -- that is, if you alter any input files, Pith will regenerate the affected outputs.

[tilt]: http://github.com/rtomayko/tilt/
[haml]: http://haml-lang.com
[sass]: http://sass-lang.com
