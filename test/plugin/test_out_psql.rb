require 'helper'

class PsqlOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  CONFIG = %{
    database hoge
    user hoge_user
    password hoge_password

    key_names fuga_key
    sql fuga_sql
  }

  def create_driver(conf = CONFIG, tag = 'test')
    Fluent::Test::BufferedOutputTestDriver.new(Fluent::PsqlOutput, tag).configure(conf)
  end

  def test_configure
  end

  def test_format
    d = create_driver
  end

  def test_write
    d = create_driver %[
      database log_db
      user tester
      password tester

      key_names method,code,param,time
      sql INSERT INTO simple_apache_access (method,code,data,datetime) VALUES ($1,$2,$3,$4)

      hstore_key_name param

      flush_interval 5s
    ]
    time = Time.parse('2012-12-17 09:23:45 JST').to_i # JST(+0900)
    record = {"method"=>"GET", "code"=>"200", "param" => "param1=hoge&param2=fuga"}
    d.emit(record, time)
    d.run
  end

end
