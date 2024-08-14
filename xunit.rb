class TestSuite
  attr_reader :tests

  def initialize
    @tests = []
  end

  def add(test)
    @tests << test
  end

  def run(result = TestResult.new)
    @tests.each do |test|
      test.run(result)
    end
    return result
  end
end

class TestResult
  attr_accessor :test_started_count, :test_failed_count

  def initialize
    @test_started_count = 0
    @test_failed_count = 0
  end

  def test_started
    @test_started_count += 1
  end

  def test_failed
    @test_failed_count += 1
  end

  def summary
    "#{test_started_count} run, #{test_failed_count} failed"
  end
end

module TestCase
  attr_accessor :test_method

  def initialize(test_method)
    @test_method = test_method
  end

  # TestCaseTest で空のオーバーライドを強制することになり、シンプルさが失われる
  # 処理が複雑になり、強制が必要と判断すればコメントアウトを外す
  def setup
    # raise NotImplementedError.new("You must implement setup")
  end

  # TestCaseTest で空のオーバーライドを強制することになり、シンプルさが失われる
  # 処理が複雑になり、強制が必要と判断すればコメントアウトを外す
  def down
    # raise NotImplementedError.new("You must implement down")
  end

  def run(result = TestResult.new)
    result.test_started
    setup
    begin
      send(@test_method)
    rescue => e
      result.test_failed
    end
    down
    result
  end
end

class WasRun
  include TestCase

  attr_reader :log

  def setup
    @log = "setup"
  end

  def test_method
    @log += " test_method"
  end

  def test_broken_method
    raise "test_broken_method"
  end

  def down
    @log += " down"
  end
end

class TestCaseTest
  include TestCase

  def test_template_method
    test = WasRun.new("test_method")
    test.run
    assert "setup test_method down" == test.log
  end

  def test_result
    test = WasRun.new("test_method")
    assert "1 run, 0 failed" == test.run.summary
  end

  def test_failed_result
    test = WasRun.new("test_broken_method")
    assert "1 run, 1 failed" == test.run.summary
  end

  def test_suite_result
    suite = TestSuite.new
    suite.add(WasRun.new("test_method"))
    suite.add(WasRun.new("test_broken_method"))
    assert "2 run, 1 failed" == suite.run.summary
  end

  private

  def assert(truthy)
    raise unless truthy
  end
end

TestCaseTest.instance_methods(false).each do |test_method|
  puts  "#{test_method}\n" + \
        TestCaseTest.new(test_method).run.summary + "\n\n"
end
