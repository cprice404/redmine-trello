Redmine-Trello Integration
==========================

This project provides extremely simplistic synchronization of
Redmine tickets to Trello boards.

Recent versions also have the ability to create Trello cards
from github pull requests.

Prerequisites
-------------
* Requires ruby 1.9 because it uses some of the newer character
  encoding features

Installation
------------
* Clone this git repo
* Make a copy of `config/redmine_trello_config.rb.SAMPLE`
   to `config/redmine_trello_config.rb`
* Edit the config file, following the instructions from
   the sample file to configure your trello access tokens
   and your mappings from Redmine projects / issue states
   to the Trello lists you'd like to clone the issues into
* Set up a cron job that calls `bin/copy_to_trello.rb` at
   your desired interval

Compatibility
-------------
We are currently running this script against Redmine 1.3.0.
It has not been tested with any other versions.

