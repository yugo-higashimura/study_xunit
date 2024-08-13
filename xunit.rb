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

  def run
    setup
    send(@test_method)
    down
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

  private

  def assert(truthy)
    raise unless truthy
  end
end

TestCaseTest.new("test_template_method").run
