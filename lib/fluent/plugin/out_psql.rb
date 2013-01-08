class Fluent::PsqlOutput < Fluent::Output
  Fluent::Plugin.register_output('psql', self)

  # config_param :hoge, :string, :default => 'hoge'

  def initialize
    super
    # require 'hogehoge'
  end

  def configure(conf)
    super
    # @path = conf['path']
  end

  def start
    super
    # init
  end

  def shutdown
    super
    # destroy
  end

  def format(tag, time, record)
    [tag, time, record].to_msgpack
  end

  def write(chunk)
    records = []
    chunk.msgpack_each { |record|
      # records << record
    }
    # write records
  end
end
