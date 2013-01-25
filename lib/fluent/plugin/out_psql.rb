class Fluent::PsqlOutput < Fluent::TimeSlicedOutput
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
    #sql_adding_date = get_adding_date_sql chunk.key
    #conn.prepare("insert", sql_adding_date)
    conn.prepare("insert", @sql)

    chunk.msgpack_each { |tag,time,record|
      begin
        conn.exec_prepared('insert', get_prepared_parameter(tag,time,record))
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

  # bindする値の配列を返す.
  def get_prepared_parameter(tag, time, record)
   result = []
   key_names_ary = @key_names.split(",") 
   key_names_ary.each_with_index do |key_name,i|
     if key_name == "time"
       result << Time.at(time).to_s
     elsif !@hstore_key_name.nil? and record.has_key?(@hstore_key_name) and @hstore_key_name == key_name
       result << convert_hstore_format(record[@hstore_key_name])
     else
       result << record[key_name]
     end
   end

   return result
  end

  # パラメータの文字列をHSTORE型に変換する.
  def convert_hstore_format str
    hstore_ary = [] 
    elems = str.split("&") 
    elems.each do |elem| 
      kv = elem.split("=") 
      hstore_ary.push("\"#{kv[0]}\" => \"#{kv[1]}\"") 
    end

    return hstore_ary.join(",")
  end

  # SQLのtime_slice_format形式の部分をchunkからとれる日付に置き換える.
  def get_adding_date_sql chunk_date
    @sql.sub(@time_slice_format, chunk_date)
  end

end
