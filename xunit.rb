
module TestCase
  attr_accessor :test_method

  def initialize(test_method)
    @test_method = test_method
  end

  def setup
    raise NotImplementedError.new("You must implement setup")
  end

  def run
    setup
    send(@test_method)
  end
end

class WasRun
  include TestCase

  attr_accessor :was_run, :was_setup

  def setup
    @was_run = false
    @was_setup = true
  end

  def test_method
    @was_run = true
  end

  [:was_run, :was_setup].each do |method_name|
    define_method("#{method_name}?", -> { method_name })
  end
end

class TestCaseTest
  include TestCase

  attr_accessor :test_object

  def setup
    @test_object = WasRun.new("test_method")
  end

  def test_setup
    @test_object.run
    assert @test_object.was_setup?
  end

  def test_running
    @test_object.run
    assert @test_object.was_run?
  end

  private

  def assert(truthy)
    raise unless truthy
  end
end

TestCaseTest.new("test_running").run
TestCaseTest.new("test_setup").run
