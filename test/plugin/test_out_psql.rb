require 'helper'

class PsqlOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  CONFIG = %{
  }

  def create_driver(conf = CONFIG, tag = 'test')
    Fluent::Test::OutputTestDriver.new(Fluent::PsqlOutput, tag).configure(conf)
  end

  def test_configure
  end

  def test_format
    d = create_driver
  end

  def test_write
    d = create_driver
  end
end
