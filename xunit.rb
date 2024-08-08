
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

  def was_run
    @was_run
  end

  def test_method
    @was_run = true
  end
end

class TestCaseTest
  include TestCase

  def test_running
      test = WasRun.new("test_method")
      raise unless test.was_run == false
      test.run
      raise unless test.was_run == true
  end
end

TestCaseTest.new("test_running").run
