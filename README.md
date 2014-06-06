# Kanban 看板

A simple webapp for viewing OmniFocus data.

## Requirements

You'll need a data file to read from. Check out [kanban-fetch](https://github.com/jyruzicka/kanban-fetch) for my Objective-C program for fetching data from OmniFocus and turning it into an appropriate format.

## Installation

To install this, grab the files, drop them somewhere on your drive and run `bundle install`. You may need to run `gem install bundler` first.

Edit the settings contained in `config.yaml`. The valid options in this YAML file are:

* `database_location`: Where on the drive you keep the SQLite database output by `kanban-fetch`
* `binary_location`: Where you've installed `kanban-fetch` to.
* `binary_options`: An array of options to pass to `kanban-fetch` (e.g. excluding projects)

Note that the `--out` flag will be set based on `database_location`, so you don't need to add this flag.

Once you have all that done, start it up with `bundle exec shotgun config.ru`.

To make it really seamless, run this whole thing through [pow](http://pow.cx/).

## Questions? Comments

Chuck me an [email](mailto:jan@1klb.com) or open a ticket.