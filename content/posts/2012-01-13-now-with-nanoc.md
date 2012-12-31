---
title: Now with Nanoc!
author: Ben
tags: [nanoc, blogging, ruby]
---
For a while now, I've been meaning to take a look at [Nanoc](http://nanoc.stoneship.org/). For the uninitiated, it's a static [web]site generator written in Ruby.

> nanoc is a tool that runs on your local computer and compiles documents written in formats such as Markdown, Textile, Haml… into a static web site consisting of simple HTML files, ready for uploading to any web server.

The idea is to replace the server-side smarts of a content management system with a 'one-shot' compilation process to static HTML each time something changes, while maintaining the convinience of templating, pagination, feeds, markup filtering, dynamic content etc. This has several advantages; no server-side security vulnerabilities (SQL injection etc.), no need for language runtimes, great performance and simple deployment. It does however mean any run-time dynamic stuff must be done solely client-side.

Previously, when building simple sites I've often relied on [Wordpress](http://wordpress.org/), of which I've never been a huge lover, as it was the path of least-resistance. The frequent security issues and need to write/run PHP are a hassle however and I've been looking for a better solution for a while.

 I finally found some time over Christmas to get started with Nanoc and I've since rewritten this site using it, with a new cleaner layout and some HTML5 goodness to boot. It's still a work in progress but I've got most of what I need working now including blogging (archive generation, atom feeds, tags, comments etc.), static asset management, sitemap generation and simple deployment. Nanoc provides some of these features out of the box but a few of them require extending Nanoc by writing [helpers](http://nanoc.stoneship.org/docs/4-basic-concepts/#helpers "Nanoc helpers"), which thankfully is [very easy](http://nanoc.stoneship.org/docs/5-advanced-concepts/#writing-helpers "Writing Nanoc helpers"). I took some inspiration from the [Brightbox Nanoc Helpers](https://github.com/brightbox/brightbox-nanoc-helpers) gem and wrote some helpers to provide some of the functionality I need, which I'll detail in future posts and release in due course.

 Content is written in [Markdown](http://daringfireball.net/projects/markdown/) and/or erb and processed using the [kramdown](http://kramdown.rubyforge.org) filter while the layouts are written in erb. Compilation and deployment is handled by a simple set of rake tasks that build the static HTML and uses rsync+ssh to copy it to the webserver. I've made use of Twitter's [Bootstrap CSS](http://twitter.github.com/bootstrap/) library and [jQuery](http://jquery.com/) as a foundation for the layout, styling and typography. Blog comments are provided using [Disqus](http://disqus.com) and I use [git](http://git-scm.com/) for version control of the whole thing. The code is on [Github](https://github.com/andatche/andatche.com).

 I still have a couple of things to work out like full-text searching and how best to enable blogging on-the-go (phone, ipad etc.) but I have some ideas in mind (using dropbox, Linux' inotify and git post-commit hooks).
