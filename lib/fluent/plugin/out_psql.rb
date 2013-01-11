class Fluent::PsqlOutput < Fluent::BufferedOutput
  Fluent::Plugin.register_output('psql', self)

  config_param :database, :string
  config_param :host, :string, :default => 'localhost'
  config_param :port, :integer, :default => 5432
  config_param :user, :string
  config_param :password, :string

  config_param :key_names, :string
  config_param :sql, :string

  config_param :hstore_key_name, :string, :default => nil

  def initialize
    super
    require 'pg'
  end

  def configure(conf)
    super
  end

  def start
    super
  end

  def shutdown
    super
  end

  def format(tag, time, record)
    [tag, time, record].to_msgpack
  end

  def write(chunk)
    conn = get_connection
    conn.prepare("insert",@sql)

    chunk.msgpack_each { |tag,time,record|
      p record

      if !@hstore_key_name.nil? and record.has_key?(@hstore_key_name)
        hstore_ary = []
        elems = record[@hstore_key_name].split("&")
        elems.each do |elem|
          kv = elem.split("=")
          hstore_ary.push("\"#{kv[0]}\" => \"#{kv[1]}\"")
        end
      end
      puts ["'#{record["method"]}'","'#{record["code"]}'", "'#{hstore_ary.join(",")}'"]

      begin
        conn.exec_prepared('insert',["#{record["method"]}","#{record["code"]}", "#{hstore_ary.join(",")}"])
      rescue PGError => e
        $log.error "PGError: " + e.message
      end
    }

    conn.close()
  end

  def get_connection
    if @conn != nil and @conn.finished?() == false
      return @conn
    end

    begin
      @conn = PG.connect(:dbname => @database, :host => @host, :port => @port,
                         :user => @user, :password => @password)
    rescue PGError => e
      $log.error "database '#{@database}' connection failed : " + e.message
      return nil
    end

    return @conn
  end

end
