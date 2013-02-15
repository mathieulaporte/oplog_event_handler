require 'oplog_event_handler'
class MyEventHandler
  include OplogEventHandler

  connect_to host: 'localhost', port: 27017

  for_db :az_app_2_development do
    on_insert :in => :subjects, :call => :new_subject
    on_update :in => :subjects, :call => :update_subject
    on_update :in => :subjects, :call => :update_subject_title, :only => [:title, :description]
    on_update :in => :subjects, :call => :update_subject_relationships, :only => [:relationships]
    on_delete :in => :subjects, :call => :remove_subject
    
    on_insert :in => :tasks, :call => :new_task
    on_delete :in => :tasks, :call => :delete_task
  end

  def new_task(opts)
    puts "there is a new taks"
  end

  def new_subject(opts)
    puts "in callback subjects"
  end

  def update_subject_relationships(opts)
    puts "yopyopyopy il faut refaire les relationships pour le sujet #{opts[:id]}"
  end

  def update_subject_title(opts)
    puts 'YEAHA!!!'
  end

  def update_subject(opts)
    puts "in subjects update"
  end

  def remove_subject(opts)
    puts "i have deleted the subject #{opts['id']}"
  end

  def update_users(opts)
    # do something
  end

  def delete_task(opts)
    puts "delete task"
  end

end
MyEventHandler.mapping

# MyEventHandler.new.run