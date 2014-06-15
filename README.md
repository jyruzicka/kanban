# Kanban 看板

A simple webapp for viewing OmniFocus data.

## Requirements

You'll need a data file to read from. Check out [kanban-fetch](https://github.com/jyruzicka/kanban-fetch) for my Objective-C program for fetching data from OmniFocus and turning it into an appropriate format.

## Installation

To install this, grab the files, drop them somewhere on your drive and run `bundle install`. You may need to run `gem install bundler` first.

Edit the settings contained in `config.yaml` as required. You will probably want to modify the "File locations" section, but depending on your requirements you may want to modify other parts of it.

Once you have all that done, start it up with `bundle exec shotgun config.ru`.

To make it really seamless, run this whole thing through [pow](http://pow.cx/).

## Questions? Comments

Chuck me an [email](mailto:jan@1klb.com) or open a ticket.

## Version history

### 1.0.1 2014-06-16

* Version history started
* Will now realise the database is missing and give you an informative error rather than cryptic mumbo-jumbo.