class TestResult

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
    "#{@test_started_count} run, #{@test_failed_count} failed"
  end
end

class TestCase

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
    begin
      setup
      send(@test_method)
    rescue => e
      result.test_failed
    end
    down
    result
  end
end

class TestSuite

  def initialize
    @test_case_instances = []
  end

  def add(test_case)
    if test_case.is_a?(Class)
      # add class
      test_case_class = Object.const_get(test_case.name)
      test_case_class.instance_methods(false).each do |method|
        @test_case_instances << test_case_class.new(method)
      end
    else
      # add instance
      @test_case_instances << test_case
    end
    self
  end

  def run(result = TestResult.new)
    @test_case_instances.each do |test_case|
      test_case.run(result)
    end
    result
  end
end

class WasRun < TestCase

  attr_reader :log

  def initialize(test_method)
    super(test_method)
    @log = ""
  end

  %i(setup test_method down).each do |method_name|
    define_method(method_name) do
      @log += "#{method_name} "
    end
  end

  def test_broken_method
    raise "test_broken_method"
  end
end

class TestCaseTest < TestCase

  def test_template_method
    test = WasRun.new("test_method")
    test.run
    assert "setup test_method down " == test.log
  end

  def test_result
    test = WasRun.new("test_method")
    assert "1 run, 0 failed" == test.run.summary
  end

  def test_failed_result
    test = WasRun.new("test_broken_method")
    assert "1 run, 1 failed" == test.run.summary \
        && "setup down " == test.log
  end

  def test_suite_result
    suite = TestSuite.new
    suite.add(WasRun.new("test_method"))
         .add(WasRun.new("test_broken_method"))
    assert "2 run, 1 failed" == suite.run.summary
  end

  def test_class_suite_result
    suite = TestSuite.new
    suite.add(WasRun)
    assert "5 run, 1 failed" == suite.run.summary
  end

  def test_broken_setup
    test = WasRun.new("test_method")
    test.define_singleton_method(:setup) do
      raise "broken setup"
    end
    assert "1 run, 1 failed" == test.run.summary \
        && "down " == test.log
  end

  private

  def assert(truthy)
    raise unless truthy
  end
end

suite = TestSuite.new
suite.add(TestCaseTest)
puts suite.run.summary
