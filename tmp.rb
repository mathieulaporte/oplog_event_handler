require 'mongo'

class OplogEventHandler
  CONFIG = {connection: {host: 'localhost', port: 27017} }
  OPERATIONS = {
      'i' => :insert,
      'u' => :update,
      'd' => :delete,
      'c' => :dbcmd,
      'n' => :noop
    }
    @@mapping = {}
  def self.connect_to(h)
    CONFIG[:connection] = h
  end

  def run()
    tail do |log|
      callbacks = get_callbaks(log)
      unless callbacks.empty?
        send_events(log, callbacks)
      end
    end
  end

  def self.for_db(db_name)
    @@db_name = db_name
    yield
  end

  def self.on_insert(opts)
    @@mapping[:"insert_#{@@db_name}_#{opts[:in]}"] = opts[:call]
  end

  def self.on_update(opts)
    if opts[:only].nil?
      @@mapping[:"update_#{@@db_name}_#{opts[:in]}"] = opts[:call]
    else
      opts[:only].each do |e|
        @@mapping[:"update_#{@@db_name}_#{opts[:in]}##{e}"] = opts[:call]
      end
    end
  end

  def self.on_delete(opts)
    @@mapping[:"delete_#{@@db_name}_#{opts[:in]}"] = opts[:call]
  end

  private

  def send_events(log, callbacks)
    callbacks.each do |callback|
      case log['op']
      when 'u'
        send(callback, id: get_object_id(log), log: log)
      when 'c'
        send(callback, id: get_object_id(log), object: log['o'])
      when 'd'
        send(callback, id: get_object_id(log))
      end
    end
  end

  def get_callbaks(log)
    callbacks = [@@mapping[:"#{extract_operation(log)}_#{extract_db_name(log)}_#{extract_collection_name(log)}"]]
    if log['op'] == 'u'
      fields(log).each do |f|
        callbacks << @@mapping[:"#{extract_operation(log)}_#{extract_db_name(log)}_#{extract_collection_name(log)}##{f}"]
      end 
    end
    callbacks.compact!
    callbacks.uniq!
    return callbacks
  end

  def extract_db_name(doc)
    doc['ns'].split('.')[0]
  end

  def extract_collection_name(doc)
    doc['ns'].sub(/\A\w+\./, '')
  end

  def extract_operation(doc)
    OPERATIONS[doc['op']]
  end

  def get_object_id(doc)
    case doc['op']
    when 'u'
      doc['o2']['_id']
    else
      doc['o']['_id']
    end
  end

  def get_keys(h)
    ks = []
    h.each do |k, v|
      k.split('.').each { |e| ks << e }
      ks << get_keys(v) if v.kind_of?(Hash)
    end
    ks.flatten
  end

  def fields(doc)
    if doc['op'] == 'u'
      get_keys(doc['o']).keep_if { |e| e[0] != '$' }
    end
  end

  def tail
    oplog_coll = Mongo::Connection.new(CONFIG[:host], CONFIG[:port])['local']['oplog.rs']
    start = oplog_coll.count
    tailable_oplog = Mongo::Cursor.new(oplog_coll, :timeout => false, :tailable => true).skip(start)
    while not tailable_oplog.closed?
      doc = tailable_oplog.next_document
      if doc
        yield doc
      else
        sleep(0.1)
      end
    end
  end
end