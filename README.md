oplog\_event\_handler
===================

[![Code Climate](https://codeclimate.com/github/mathieulaporte/oplog_event_handler.png)](https://codeclimate.com/github/mathieulaporte/oplog_event_handler)

A very simple way to cath event in mongodb

First you need to run mongo using replicaset mod

Install
-------
```
gem install oplog_event_handler
```


Example
-------
```ruby
require 'oplog_event_handler'
class MyEventHandler
  include OplogEventHandler

  connect_to host: 'localhost', port: 27017

  for_db :my_super_app do
    on_insert :in => :subjects, :call => :new_subject
    on_update :in => :subjects, :call => :update_subject
    on_update :in => :subjects, :call => :update_subject_title, :only => [:title]
    on_delete :in => :subjects, :call => :remove_subject
    
    on_insert :in => :users,    :call => :new_user
    on_delete :in => :users,    :call => :delete_user
  end

  def new_subject(opts)
    puts "in callback subjects"
  end

  def update_subject_title(opts)
    puts 'updating subject title'
  end

  def update_subject(opts)
    puts "in subjects update"
  end

  def remove_subject(opts)
    puts "i have deleted the subject #{opts['id']}"
  end

  def new_user(opts)
    puts "there is a new user"
  end

  def delete_users(opts)
    # do something
  end

end

MyEventHandler.new.run
```
