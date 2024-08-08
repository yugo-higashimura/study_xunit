
module TestCase
  attr_accessor :test_method

  def initialize(test_method)
    @test_method = test_method
  end

  def run
    send(@test_method)
  end
end

class WasRun
  include TestCase

  attr_accessor :was_run

  def initialize(test_method)
    @was_run = false
    super(test_method)
  end

  def test_method
    @was_run = true
  end
end

class TestCaseTest
  include TestCase

  def test_running
    test = WasRun.new("test_method")
    assert test.was_run == false
    test.run
    assert test.was_run == true
  end

  private

  def assert(truthy)
    raise unless truthy
  end
end

TestCaseTest.new("test_running").run
