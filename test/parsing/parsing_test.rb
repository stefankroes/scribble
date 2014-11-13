require_relative '../test_helper'

describe Scribble do
  it 'keeps text between tags' do
    assert_scribble_parse 'Hi! Nice template!',          "'Hi! Nice template!'"
    assert_scribble_parse 'Hi!{{ }} Nice template!',     "'Hi!', ' Nice template!'"
    assert_scribble_parse 'H{{ }}i! Nice template{{}}!', "'H', 'i! Nice template', '!'"
  end

  it 'parses literal values' do
    assert_scribble_parse '{{ 1 }}',     "1"
    assert_scribble_parse '{{ 100 }}',   "100"
    assert_scribble_parse "{{ 'foo' }}", "'foo'"
    assert_scribble_parse "{{ 'bar' }}", "'bar'"
    assert_scribble_parse '{{ true }}',  "true"
    assert_scribble_parse '{{ false }}', "false"
  end

  it 'parses binary and unary operators' do
    assert_scribble_parse '{{ 1 | 2 }}',  '1.or(2)'

    assert_scribble_parse '{{ 1 & 2 }}',  '1.and(2)'

    assert_scribble_parse '{{ 1 = 2 }}',  '1.equals(2)'
    assert_scribble_parse '{{ 1 != 2 }}', '1.differs(2)'

    assert_scribble_parse '{{ 1 > 2 }}',  '1.greater(2)'
    assert_scribble_parse '{{ 1 < 2 }}',  '1.less(2)'
    assert_scribble_parse '{{ 1 >= 2 }}', '1.greater_or_equal(2)'
    assert_scribble_parse '{{ 1 <= 2 }}', '1.less_or_equal(2)'

    assert_scribble_parse '{{ 1 + 2 }}',  '1.add(2)'
    assert_scribble_parse '{{ 1 - 2 }}',  '1.subtract(2)'

    assert_scribble_parse '{{ 1 * 2 }}',  '1.multiply(2)'
    assert_scribble_parse '{{ 1 / 2 }}',  '1.divide(2)'
    assert_scribble_parse '{{ 1 % 2 }}',  '1.remainder(2)'

    assert_scribble_parse '{{ -1 }}',     '1.negative()'
    assert_scribble_parse '{{ !1 }}',     '1.not()'
  end

  it 'parses chains of operators with equal precedence' do
    assert_scribble_parse '{{ 1 | 2 | 3 }}',   '1.or(2).or(3)'

    assert_scribble_parse '{{ 1 & 2 & 3 }}',   '1.and(2).and(3)'

    assert_scribble_parse '{{ 1 = 2 != 3 }}',  '1.equals(2).differs(3)'
    assert_scribble_parse '{{ 1 != 2 = 3 }}',  '1.differs(2).equals(3)'

    assert_scribble_parse '{{ 1 > 2 <= 3 }}',  '1.greater(2).less_or_equal(3)'
    assert_scribble_parse '{{ 1 < 2 > 3 }}',   '1.less(2).greater(3)'
    assert_scribble_parse '{{ 1 >= 2 < 3 }}',  '1.greater_or_equal(2).less(3)'
    assert_scribble_parse '{{ 1 <= 2 >= 3 }}', '1.less_or_equal(2).greater_or_equal(3)'

    assert_scribble_parse '{{ 1 + 2 - 3 }}',   '1.add(2).subtract(3)'
    assert_scribble_parse '{{ 1 - 2 + 3 }}',   '1.subtract(2).add(3)'

    assert_scribble_parse '{{ 1 * 2 % 3 }}',   '1.multiply(2).remainder(3)'
    assert_scribble_parse '{{ 1 / 2 * 3 }}',   '1.divide(2).multiply(3)'
    assert_scribble_parse '{{ 1 % 2 / 3 }}',   '1.remainder(2).divide(3)'

    assert_scribble_parse '{{ --!-1 }}',       '1.negative().not().negative().negative()'
    assert_scribble_parse '{{ !!-!1 }}',       '1.not().negative().not().not()'
  end

  it 'combines operators with different precedence' do
    assert_scribble_parse '{{ 1 & 2 | 3 }}',   '1.and(2).or(3)'

    assert_scribble_parse '{{ 1 = 2 & 3 }}',   '1.equals(2).and(3)'
    assert_scribble_parse '{{ 1 != 2 & 3 }}',  '1.differs(2).and(3)'

    assert_scribble_parse '{{ 1 > 2 = 3 }}',   '1.greater(2).equals(3)'
    assert_scribble_parse '{{ 1 < 2 = 3 }}',   '1.less(2).equals(3)'
    assert_scribble_parse '{{ 1 >= 2 = 3 }}',  '1.greater_or_equal(2).equals(3)'
    assert_scribble_parse '{{ 1 <= 2 = 3 }}',  '1.less_or_equal(2).equals(3)'
    assert_scribble_parse '{{ 1 > 2 != 3 }}',  '1.greater(2).differs(3)'
    assert_scribble_parse '{{ 1 < 2 != 3 }}',  '1.less(2).differs(3)'
    assert_scribble_parse '{{ 1 >= 2 != 3 }}', '1.greater_or_equal(2).differs(3)'
    assert_scribble_parse '{{ 1 <= 2 != 3 }}', '1.less_or_equal(2).differs(3)'

    assert_scribble_parse '{{ 1 + 2 > 3 }}',   '1.add(2).greater(3)'
    assert_scribble_parse '{{ 1 + 2 < 3 }}',   '1.add(2).less(3)'
    assert_scribble_parse '{{ 1 + 2 >= 3 }}',  '1.add(2).greater_or_equal(3)'
    assert_scribble_parse '{{ 1 + 2 <= 3 }}',  '1.add(2).less_or_equal(3)'
    assert_scribble_parse '{{ 1 - 2 > 3 }}',   '1.subtract(2).greater(3)'
    assert_scribble_parse '{{ 1 - 2 < 3 }}',   '1.subtract(2).less(3)'
    assert_scribble_parse '{{ 1 - 2 >= 3 }}',  '1.subtract(2).greater_or_equal(3)'
    assert_scribble_parse '{{ 1 - 2 <= 3 }}',  '1.subtract(2).less_or_equal(3)'

    assert_scribble_parse '{{ 1 * 2 + 3 }}',   '1.multiply(2).add(3)'
    assert_scribble_parse '{{ 1 / 2 + 3 }}',   '1.divide(2).add(3)'
    assert_scribble_parse '{{ 1 % 2 + 3 }}',   '1.remainder(2).add(3)'
    assert_scribble_parse '{{ 1 * 2 - 3 }}',   '1.multiply(2).subtract(3)'
    assert_scribble_parse '{{ 1 / 2 - 3 }}',   '1.divide(2).subtract(3)'
    assert_scribble_parse '{{ 1 % 2 - 3 }}',   '1.remainder(2).subtract(3)'
  end

  it 'respects operator precedence' do
    assert_scribble_parse '{{ 1 | 2 & 3 }}',   '1.or(2.and(3))'

    assert_scribble_parse '{{ 1 & 2 = 3 }}',   '1.and(2.equals(3))'
    assert_scribble_parse '{{ 1 & 2 != 3 }}',  '1.and(2.differs(3))'

    assert_scribble_parse '{{ 1 = 2 > 3 }}',   '1.equals(2.greater(3))'
    assert_scribble_parse '{{ 1 = 2 < 3 }}',   '1.equals(2.less(3))'
    assert_scribble_parse '{{ 1 = 2 >= 3 }}',  '1.equals(2.greater_or_equal(3))'
    assert_scribble_parse '{{ 1 = 2 <= 3 }}',  '1.equals(2.less_or_equal(3))'
    assert_scribble_parse '{{ 1 != 2 > 3 }}',  '1.differs(2.greater(3))'
    assert_scribble_parse '{{ 1 != 2 < 3 }}',  '1.differs(2.less(3))'
    assert_scribble_parse '{{ 1 != 2 >= 3 }}', '1.differs(2.greater_or_equal(3))'
    assert_scribble_parse '{{ 1 != 2 <= 3 }}', '1.differs(2.less_or_equal(3))'

    assert_scribble_parse '{{ 1 > 2 + 3 }}',   '1.greater(2.add(3))'
    assert_scribble_parse '{{ 1 < 2 + 3 }}',   '1.less(2.add(3))'
    assert_scribble_parse '{{ 1 >= 2 + 3 }}',  '1.greater_or_equal(2.add(3))'
    assert_scribble_parse '{{ 1 <= 2 + 3 }}',  '1.less_or_equal(2.add(3))'
    assert_scribble_parse '{{ 1 > 2 - 3 }}',   '1.greater(2.subtract(3))'
    assert_scribble_parse '{{ 1 < 2 - 3 }}',   '1.less(2.subtract(3))'
    assert_scribble_parse '{{ 1 >= 2 - 3 }}',  '1.greater_or_equal(2.subtract(3))'
    assert_scribble_parse '{{ 1 <= 2 - 3 }}',  '1.less_or_equal(2.subtract(3))'

    assert_scribble_parse '{{ 1 + 2 * 3 }}',   '1.add(2.multiply(3))'
    assert_scribble_parse '{{ 1 + 2 / 3 }}',   '1.add(2.divide(3))'
    assert_scribble_parse '{{ 1 + 2 % 3 }}',   '1.add(2.remainder(3))'
    assert_scribble_parse '{{ 1 - 2 * 3 }}',   '1.subtract(2.multiply(3))'
    assert_scribble_parse '{{ 1 - 2 / 3 }}',   '1.subtract(2.divide(3))'
    assert_scribble_parse '{{ 1 - 2 % 3 }}',   '1.subtract(2.remainder(3))'

    assert_scribble_parse '{{ -1 * !2 }}',     '1.negative().multiply(2.not())'
    assert_scribble_parse '{{ -1 / !2 }}',     '1.negative().divide(2.not())'
    assert_scribble_parse '{{ -1 % !2 }}',     '1.negative().remainder(2.not())'
    assert_scribble_parse '{{ !1 * -2 }}',     '1.not().multiply(2.negative())'
    assert_scribble_parse '{{ !1 / -2 }}',     '1.not().divide(2.negative())'
    assert_scribble_parse '{{ !1 % -2 }}',     '1.not().remainder(2.negative())'
  end

  it 'respects operator precedence in complex situations' do
    assert_scribble_parse '{{ !1 / 2 > 3 < -4 * 5 }}',   '1.not().divide(2).greater(3).less(4.negative().multiply(5))'
    assert_scribble_parse '{{ 1 | 2 <= !-3 | 4 < 5 }}',  '1.or(2.less_or_equal(3.negative().not())).or(4.less(5))'
    assert_scribble_parse '{{ -1 + -2 & 3 != 4 = 5 }}',  '1.negative().add(2.negative()).and(3.differs(4).equals(5))'
    assert_scribble_parse '{{ 1 % 2 - 3 >= !4 != !5 }}', '1.remainder(2).subtract(3).greater_or_equal(4.not()).differs(5.not())'
  end

  it 'respects parentheses' do
    assert_scribble_parse '{{ (1 > 2) = 3 }}',   '1.greater(2).equals(3)'
    assert_scribble_parse '{{ (1 < 2) = 3 }}',   '1.less(2).equals(3)'
    assert_scribble_parse '{{ (1 >= 2) = 3 }}',  '1.greater_or_equal(2).equals(3)'
    assert_scribble_parse '{{ (1 <= 2) = 3 }}',  '1.less_or_equal(2).equals(3)'
    assert_scribble_parse '{{ (1 > 2) != 3 }}',  '1.greater(2).differs(3)'
    assert_scribble_parse '{{ (1 < 2) != 3 }}',  '1.less(2).differs(3)'
    assert_scribble_parse '{{ (1 >= 2) != 3 }}', '1.greater_or_equal(2).differs(3)'
    assert_scribble_parse '{{ (1 <= 2) != 3 }}', '1.less_or_equal(2).differs(3)'
  end

  # Functions / variables

  it 'parses names' do
    assert_scribble_parse '{{ foo }}',                'foo'
    assert_scribble_parse '{{ foo123 }}',             'foo123'
    assert_scribble_parse '{{ bar? }}',               'bar?'
    assert_scribble_parse '{{ bar! }}',               'bar!'
    assert_scribble_parse '{{ foo1 + bar2 }}',        'foo1.add(bar2)'
    assert_scribble_parse '{{ foo1 - bar2 }}',        'foo1.subtract(bar2)'
    assert_scribble_parse '{{ foo1 - bar2 / baz3 }}', 'foo1.subtract(bar2.divide(baz3))'
  end

  it 'parses regular calls' do
    assert_scribble_parse '{{ foo() }}',             'foo()'
    assert_scribble_parse '{{ foo(1) }}',            'foo(1)'
    assert_scribble_parse '{{ bar(1, 2, baz) }}',    'bar(1, 2, baz)'
    assert_scribble_parse '{{ foo(1 + 2, bar()) }}', 'foo(1.add(2), bar())'
    assert_scribble_parse '{{ foo(1) + 2 }}',        'foo(1).add(2)'
    assert_scribble_parse '{{ 1 + foo() }}',         '1.add(foo())'
    assert_scribble_parse '{{ 1 + foo(2) }}',        '1.add(foo(2))'
  end

  it 'parses method style calls' do
    assert_scribble_parse '{{ 1.foo(2) }}',                         '1.foo(2)'
    assert_scribble_parse '{{ 1.foo }}',                            '1.foo'
    assert_scribble_parse '{{ (1 + 2).foo(3) }}',                   '1.add(2).foo(3)'
    assert_scribble_parse '{{ (1 + 2.foo(3)).bar(4 + 5, baz) }}',   '1.add(2.foo(3)).bar(4.add(5), baz)'
    assert_scribble_parse '{{ (1 + 2).foo(3).bar(4).baz(5) }}',     '1.add(2).foo(3).bar(4).baz(5)'
    assert_scribble_parse '{{ (1 - 2).foo.bar.baz(3) }}',           '1.subtract(2).foo.bar.baz(3)'
    assert_scribble_parse '{{ -1.foo(2) * !3.bar(4) * 5.baz(6) }}', '1.negative().foo(2).multiply(3.not().bar(4)).multiply(5.baz(6))'
    assert_scribble_parse '{{ -1.foo * !2.bar * 3.baz }}',          '1.negative().foo.multiply(2.not().bar).multiply(3.baz)'
  end

  it 'parses command style calls' do
    assert_scribble_parse '{{ foo 1 }}',               'foo(1)'
    assert_scribble_parse '{{ foo bar 1 }}',           'foo(bar(1))'
    assert_scribble_parse '{{ foo bar baz 1, 2, 3 }}', 'foo(bar(baz(1, 2, 3)))'
    assert_scribble_parse '{{ foo 1, 2, bar }}',       'foo(1, 2, bar)'
    assert_scribble_parse '{{ foo 1 + 2 }}',           'foo(1.add(2))'
    assert_scribble_parse '{{ foo 1 + 2, bar }}',      'foo(1.add(2), bar)'
    assert_scribble_parse '{{ 1 + (foo 2) }}',         '1.add(foo(2))'
    assert_scribble_parse '{{ foo 1.bar(2).baz(3) }}', 'foo(1.bar(2).baz(3))'
    assert_scribble_parse '{{ foo(bar 1) }}',          'foo(bar(1))'
  end

  it 'gives precedence to operations over commands' do
    assert_scribble_parse '{{ foo - 2 }}', 'foo.subtract(2)'
    assert_scribble_parse '{{ (foo - 2) }}', 'foo.subtract(2)'
    assert_scribble_parse '{{ foo(bar - 2) }}', 'foo(bar.subtract(2))'
    assert_scribble_parse '{{ foo bar - 2 }}', 'foo(bar.subtract(2))'
  end

  it 'parses calls that are both command and method style' do
    assert_scribble_parse '{{ 1.foo 2 }}',                '1.foo(2)'
    assert_scribble_parse '{{ -1.foo bar 2 }}',           '1.negative().foo(bar(2))'
    assert_scribble_parse '{{ !1.foo bar baz 2, 3, 4 }}', '1.not().foo(bar(baz(2, 3, 4)))'
    assert_scribble_parse '{{ 1.foo 2, 3, bar }}',        '1.foo(2, 3, bar)'
    assert_scribble_parse '{{ 1.foo 2 + 3 }}',            '1.foo(2.add(3))'
    assert_scribble_parse '{{ -1.foo 2 + 3, bar }}',      '1.negative().foo(2.add(3), bar)'
    assert_scribble_parse '{{ !1 + (2.foo 3) }}',         '1.not().add(2.foo(3))'
    assert_scribble_parse '{{ 1.foo 2.bar(3).baz(4) }}',  '1.foo(2.bar(3).baz(4))'
    assert_scribble_parse '{{ 1.foo(2.bar 3) }}',         '1.foo(2.bar(3))'
  end

  # Nesting

  it 'nests blocks of nodes in calls that need a block' do
    Scribble::Registry.reset do
      class SomeBlock < Scribble::Block
        def qux; end; register :qux
      end

      assert_scribble_parse '{{ qux }}foo{{ end }}',                                     "qux { 'foo' }"
      assert_scribble_parse '{{ qux }}{{ qux }}foo{{ end }}{{ end }}',                   "qux { qux { 'foo' } }"
      assert_scribble_parse '{{ qux }}foo{{ end }}{{ qux }}foo{{ end }}',                "qux { 'foo' }, qux { 'foo' }"
      assert_scribble_parse '{{ foo }}{{ qux }}{{ foo }}foo{{ foo }}{{ end }}{{ foo }}', "foo, qux { foo, 'foo', foo }, foo"
    end
  end
end
