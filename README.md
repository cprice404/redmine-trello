Redmine-Trello Integration
==========================

This project provides extremely simplistic syncronization of
Redmine tickets to Trello boards.

Recent versions also have the ability to create Trello cards
from github pull requests.

Installation
------------
* Clone this git repo
* Make a copy of `config/redmine_trello_config.rb.SAMPLE`
   to `config/redmine_trello_config.rb`
* Edit the config file, following the instructions from
   the sample file to configure your trello access tokens
   and your mappings from Redmine projects / issue states
   to the Trello lists you'd like to clone the issues into.
