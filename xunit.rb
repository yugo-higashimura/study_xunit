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

  attr_accessor :log

  def setup
    @log = "setup"
  end

  def test_method
    @log += " test_method"
  end
end

class TestCaseTest
  include TestCase

  def setup
  end

  def test_template_method
    test = WasRun.new("test_method")
    test.run
    assert "setup test_method" == test.log
  end

  private

  def assert(truthy)
    raise unless truthy
  end
end

TestCaseTest.new("test_template_method").run
