# Kanban 看板

A simple webapp for viewing OmniFocus data.

## Requirements

You'll need a data file to read from. Check out [kanban-fetch](https://github.com/jyruzicka/kanban-fetch) for my Objective-C program for fetching data from OmniFocus and turning it into an appropriate format.

## Installation

To install this, grab the files, drop them somewhere on your drive and run `bundle install`. You may need to run `gem install bundler` first.

Now, open `lib/project.rb` in your favourite editor. See that constant on line 4? Edit that so the program is pointing at the database file `kanban-fetch` spat out. While you're doing modifications, you might want to alter line 51 of `app.rb`.

Once you have all that done, start it up with `bundle exec shotgun config.ru`.

To make it really seamless, run this whole thing through [pow](http://pow.cx/).

### Running in the background

I let `kanban-fetch` run every hour or so, outputting data to a known location on my hard drive. Using `pow`, my kanban board is always available at kanban.dev.

## Questions? Comments

Chuck me an [email](mailto:jan@1klb.com).