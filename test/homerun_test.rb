require "test_helper"

class HomerunTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Homerun::VERSION
  end

  class A < Homerun::Instruction
    step ->(ctx) { ctx[:var] += 1  }
    step ->(ctx) { ctx[:var] += 1  }
    step ->(ctx) { ctx[:var] += 1  }
  end

  def test_smooth_run
    assert_equal(A.call(var: 0), { var: 3, _pass: true })
  end

  class B < Homerun::Instruction
    step ->(ctx) { false  }, failure: :recover
    step ->(ctx) { ctx[:var] += 3  }
    step ->(ctx) { ctx[:var] += 1  }, name: :recover
  end

  def test_redirection_run
    assert_equal(B.call(var: 0), { var: 1, _pass: true })
  end

  class C < Homerun::Instruction
    step ->(ctx) { false  }
    step ->(ctx) { ctx[:var] += 3  }
    step ->(ctx) { ctx[:var] += 1}
  end

  def test_step_false_pass_run
    assert_equal(C.call(var: 0), { var: 0, _pass: false })
  end

  class D < Homerun::Instruction
    step ->(ctx) { ctx[:var] += 1 }
    step ->(ctx) { ctx[:var] += 1 }
    step ->(ctx) { false }
  end

  def test_last_step_false_pass_run
    assert_equal(D.call(var: 0), { var: 2, _pass: false })
  end

  class E < Homerun::Instruction
    step ->(ctx) { ctx[:var] += 1 }
    step ->(ctx) { ctx[:var] += 1 }
    step ->(ctx) { true }
  end

  def test_last_step_false_pass_run
    assert_equal(E.call(var: 0) do |ctx|; ctx[:var] += 1; end, { var: 3, _pass: true })
  end
end
