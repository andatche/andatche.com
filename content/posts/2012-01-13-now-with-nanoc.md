---
title: Now with Nanoc!
author: Ben
tags: [nanoc, blogging, ruby]
---
For a while now I've been meaning to take a look at [Nanoc](https://nanoc.ws/). For the uninitiated, it's a static [web]site generator written in Ruby.

Nanoc is a tool that runs on your local computer and compiles documents written in formats like Markdown, Textile or Haml into a static site consisting of simple HTML files, ready for uploading to any web server.

The idea is to replace the server-side smarts of a content management system with a 'one-shot' compilation to static HTML each time something changes, while maintaining the convinience of templating, pagination, markup filtering and dynamic content etc. This has several advantages; no server-side security vulnerabilities (SQL injection etc.), no need for language runtimes, great performance and simple deployment. The downside is that any run-time dynamic stuff must be done client-side with Javascript.

Previously when building simple sites, I've often relied on [Wordpress](http://wordpress.org/), as it was the path of least-resistance. The frequent security issues and need to write/run PHP are a hassle however, so I've been looking for a better solution.

I finally found some time over Christmas to rewrite this site with Nanoc, with a new cleaner layout and some HTML5 goodness to boot. It's still a work in progress but I've got most of what I need working now including article publication (archive generation, atom feeds, tags, comments etc.), static assets, sitemap generation and simple deployment. Nanoc provides some of these features out of the box but a few of them require extending Nanoc by writing [helpers](https://nanoc.ws/doc/reference/helpers/ "Nanoc Helpers"), which thankfully is [very easy](https://nanoc.ws/doc/helpers/ "Writing Nanoc helpers"). I took some inspiration from the [Brightbox Nanoc Helpers](https://github.com/brightbox/brightbox-nanoc-helpers) gem and wrote some helpers of my own to provide the functionality I need, which I'll detail in future posts and release in due course.

Content is written in [Markdown](http://daringfireball.net/projects/markdown/) and processed using the [kramdown](http://kramdown.rubyforge.org) filter, while the layouts are written in erb. Compilation and deployment is handled by a simple set of rake tasks that build the static HTML and use rsync+ssh to copy it to the webserver. I've made use of Twitter's [Bootstrap CSS](http://twitter.github.com/bootstrap/) library and [jQuery](http://jquery.com/) as a foundation for the layout, styling and typography. Blog comments are provided using [Disqus](http://disqus.com) and I use [git](http://git-scm.com/) for version control of the whole thing. The code is on [Github](https://github.com/andatche/andatche.com).

I still have a couple of things left to work out, like full-text searching and writing on-the-go (phone, ipad etc.), but I have some ideas in mind (using dropbox, Linux' inotify and git post-commit hooks).
