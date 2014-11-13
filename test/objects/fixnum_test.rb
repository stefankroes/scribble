require_relative '../test_helper'

describe 'scribble fixnum' do
  it 'can be used as a literal' do
    assert_scribble_render '{{ 3 }}',       '3'
    assert_scribble_render '{{ 322 }}',     '322'
    assert_scribble_render '{{ 3243232 }}', '3243232'
  end

  it 'knows if is odd' do
    assert_scribble_render '{{ 3.odd }}', 'true'
    assert_scribble_render '{{ 4.odd }}', 'false'
  end

  it 'knows if is even' do
    assert_scribble_render '{{ 3.even }}', 'false'
    assert_scribble_render '{{ 4.even }}', 'true'
  end

  it 'knows if is zero' do
    assert_scribble_render '{{ -5.zero }}', 'false'
    assert_scribble_render '{{ 0.zero }}',  'true'
    assert_scribble_render '{{ 5.zero }}',  'false'
  end

  it 'knows if is nonzero' do
    assert_scribble_render '{{ -5.nonzero }}', 'true'
    assert_scribble_render '{{ 0.nonzero}}',   'false'
    assert_scribble_render '{{ 5.nonzero}}',   'true'
  end

  it 'supports method and operator for logical or' do
    assert_scribble_render '{{ 0.or true }}',  'true'
    assert_scribble_render '{{ 3.or true }}',  'true'
    assert_scribble_render '{{ 0.or false }}', 'false'
    assert_scribble_render '{{ 3.or false }}', 'true'
    assert_scribble_render '{{ 0.or 2 }}',     'true'
    assert_scribble_render '{{ 3.or 2 }}',     'true'
    assert_scribble_render '{{ 0.or 0 }}',     'false'
    assert_scribble_render '{{ 3.or 0 }}',     'true'
    assert_scribble_render "{{ 0.or 'foo' }}", 'true'
    assert_scribble_render "{{ 3.or 'foo' }}", 'true'
    assert_scribble_render "{{ 0.or '' }}",    'false'
    assert_scribble_render "{{ 3.or '' }}",    'true'
    assert_scribble_render '{{ 0 | true }}',   'true'
    assert_scribble_render '{{ 3 | true }}',   'true'
    assert_scribble_render '{{ 0 | false }}',  'false'
    assert_scribble_render '{{ 3 | false }}',  'true'
    assert_scribble_render '{{ 0 | 2 }}',      'true'
    assert_scribble_render '{{ 3 | 2 }}',      'true'
    assert_scribble_render '{{ 0 | 0 }}',      'false'
    assert_scribble_render '{{ 3 | 0 }}',      'true'
    assert_scribble_render "{{ 0 | 'foo' }}",  'true'
    assert_scribble_render "{{ 3 | 'foo' }}",  'true'
    assert_scribble_render "{{ 0 | '' }}",     'false'
    assert_scribble_render "{{ 3 | '' }}",     'true'
  end

  it 'supports method and operator for logical and' do
    assert_scribble_render '{{ 0.and true }}',  'false'
    assert_scribble_render '{{ 3.and true }}',  'true'
    assert_scribble_render '{{ 0.and false }}', 'false'
    assert_scribble_render '{{ 3.and false }}', 'false'
    assert_scribble_render '{{ 0.and 2 }}',     'false'
    assert_scribble_render '{{ 3.and 2 }}',     'true'
    assert_scribble_render '{{ 0.and 0 }}',     'false'
    assert_scribble_render '{{ 3.and 0 }}',     'false'
    assert_scribble_render "{{ 0.and 'foo' }}", 'false'
    assert_scribble_render "{{ 3.and 'foo' }}", 'true'
    assert_scribble_render "{{ 0.and '' }}",    'false'
    assert_scribble_render "{{ 3.and '' }}",    'false'
    assert_scribble_render '{{ 0 & true }}',    'false'
    assert_scribble_render '{{ 3 & true }}',    'true'
    assert_scribble_render '{{ 0 & false }}',   'false'
    assert_scribble_render '{{ 3 & false }}',   'false'
    assert_scribble_render '{{ 0 & 2 }}',       'false'
    assert_scribble_render '{{ 3 & 2 }}',       'true'
    assert_scribble_render '{{ 0 & 0 }}',       'false'
    assert_scribble_render '{{ 3 & 0 }}',       'false'
    assert_scribble_render "{{ 0 & 'foo' }}",   'false'
    assert_scribble_render "{{ 3 & 'foo' }}",   'true'
    assert_scribble_render "{{ 0 & '' }}",      'false'
    assert_scribble_render "{{ 3 & '' }}",      'false'
  end

  it 'can equal another integer' do
    assert_scribble_render '{{ 3.equals 3 }}', 'true'
    assert_scribble_render '{{ 3.equals 4 }}', 'false'
    assert_scribble_render '{{ 3 = 3 }}',      'true'
    assert_scribble_render '{{ 3 = 4 }}',      'false'
  end

  it 'does not equal another type' do
    assert_scribble_render "{{ 3.equals 'foo' }}", 'false'
    assert_scribble_render '{{ 3.equals true }}',  'false'
    assert_scribble_render "{{ 3 = 'foo' }}",      'false'
    assert_scribble_render '{{ 3 = true }}',       'false'
  end

  it 'can differ from another integer' do
    assert_scribble_render '{{ 3.differs 3 }}', 'false'
    assert_scribble_render '{{ 3.differs 4 }}', 'true'
    assert_scribble_render '{{ 3 != 3 }}',      'false'
    assert_scribble_render '{{ 3 != 4 }}',      'true'
  end

  it 'differs from another type' do
    assert_scribble_render "{{ 3.differs 'foo' }}", 'true'
    assert_scribble_render '{{ 3.differs true }}',  'true'
    assert_scribble_render "{{ 3 != 'foo' }}",       'true'
    assert_scribble_render '{{ 3 != true }}',        'true'
  end

  it 'can be compared to another integer' do
    assert_scribble_render '{{ 2.greater 1 }}',          'true'
    assert_scribble_render '{{ 2.greater 2 }}',          'false'
    assert_scribble_render '{{ 2.greater 3 }}',          'false'
    assert_scribble_render '{{ 2 > 1 }}',                'true'
    assert_scribble_render '{{ 2 > 2 }}',                'false'
    assert_scribble_render '{{ 2 > 3 }}',                'false'
    assert_scribble_render '{{ 2.less 1 }}',             'false'
    assert_scribble_render '{{ 2.less 2 }}',             'false'
    assert_scribble_render '{{ 2.less 3 }}',             'true'
    assert_scribble_render '{{ 2 < 1 }}',                'false'
    assert_scribble_render '{{ 2 < 2 }}',                'false'
    assert_scribble_render '{{ 2 < 3 }}',                'true'
    assert_scribble_render '{{ 2.greater_or_equal 1 }}', 'true'
    assert_scribble_render '{{ 2.greater_or_equal 2 }}', 'true'
    assert_scribble_render '{{ 2.greater_or_equal 3 }}', 'false'
    assert_scribble_render '{{ 2 >= 1 }}',               'true'
    assert_scribble_render '{{ 2 >= 2 }}',               'true'
    assert_scribble_render '{{ 2 >= 3 }}',               'false'
    assert_scribble_render '{{ 2.less_or_equal 1 }}',    'false'
    assert_scribble_render '{{ 2.less_or_equal 2 }}',    'true'
    assert_scribble_render '{{ 2.less_or_equal 3 }}',    'true'
    assert_scribble_render '{{ 2 <= 1 }}',               'false'
    assert_scribble_render '{{ 2 <= 2 }}',               'true'
    assert_scribble_render '{{ 2 <= 3 }}',               'true'
  end

  it 'can not be compared to another type' do
    assert_scribble_raises "{{ 2.greater 'foo' }}",          Scribble::Errors::Argument
    assert_scribble_raises '{{ 2.greater true }}',           Scribble::Errors::Argument
    assert_scribble_raises "{{ 2 > 'foo' }}",                Scribble::Errors::Argument
    assert_scribble_raises '{{ 2 > true }}',                 Scribble::Errors::Argument
    assert_scribble_raises "{{ 2.less 'foo' }}",             Scribble::Errors::Argument
    assert_scribble_raises '{{ 2.less true }}',              Scribble::Errors::Argument
    assert_scribble_raises "{{ 2 < 'foo' }}",                Scribble::Errors::Argument
    assert_scribble_raises '{{ 2 < true }}',                 Scribble::Errors::Argument
    assert_scribble_raises "{{ 2.greater_or_equal 'foo' }}", Scribble::Errors::Argument
    assert_scribble_raises '{{ 2.greater_or_equal true }}',  Scribble::Errors::Argument
    assert_scribble_raises "{{ 2 >= 'foo' }}",               Scribble::Errors::Argument
    assert_scribble_raises '{{ 2 >= true }}',                Scribble::Errors::Argument
    assert_scribble_raises "{{ 2.less_or_equal 'foo' }}",    Scribble::Errors::Argument
    assert_scribble_raises '{{ 2.less_or_equal true }}',     Scribble::Errors::Argument
    assert_scribble_raises "{{ 2 <= 'foo' }}",               Scribble::Errors::Argument
    assert_scribble_raises '{{ 2 <= true }}',                Scribble::Errors::Argument
  end

  it 'can have integers and strings added to it but not booleans' do
    assert_scribble_render '{{ 3.add 2 }}',     '5'
    assert_scribble_render '{{ 3.add(-2) }}',   '1'
    assert_scribble_render "{{ 3.add 'foo' }}", '3foo'
    assert_scribble_raises '{{ 3.add true }}',  Scribble::Errors::Argument
    assert_scribble_render '{{ 3 + 2 }}',       '5'
    assert_scribble_render '{{ 3 + -2 }}',      '1'
    assert_scribble_render "{{ 3 + 'foo' }}",   '3foo'
    assert_scribble_raises '{{ 3 + true }}',    Scribble::Errors::Argument
  end

  it 'can only have integers subtracted from it' do
    assert_scribble_render '{{ 3.subtract 2 }}',     '1'
    assert_scribble_render '{{ 3.subtract(-2) }}',   '5'
    assert_scribble_raises "{{ 3.subtract 'foo' }}", Scribble::Errors::Argument
    assert_scribble_raises '{{ 3.subtract true }}',  Scribble::Errors::Argument
    assert_scribble_render '{{ 3 - 2 }}',            '1'
    assert_scribble_render '{{ 3 - -2 }}',           '5'
    assert_scribble_raises "{{ 3 - 'foo' }}",        Scribble::Errors::Argument
    assert_scribble_raises '{{ 3 - true }}',         Scribble::Errors::Argument
  end

  it 'can be multiplied by integers and strings but not booleans' do
    assert_scribble_render '{{ 3.multiply 2 }}',      '6'
    assert_scribble_render '{{ 3.multiply(-2) }}',    '-6'
    assert_scribble_render "{{ 3.multiply 'foo' }}",  'foofoofoo'
    assert_scribble_raises "{{ -3.multiply 'foo' }}", Scribble::Errors::Argument
    assert_scribble_raises '{{ 3.multiply true }}',   Scribble::Errors::Argument
    assert_scribble_render '{{ 3 * 2 }}',             '6'
    assert_scribble_render '{{ 3 * -2 }}',            '-6'
    assert_scribble_render "{{ 3 * 'foo' }}",         'foofoofoo'
    assert_scribble_raises "{{ -3 * 'foo' }}",        Scribble::Errors::Argument
    assert_scribble_raises '{{ 3 * true }}',          Scribble::Errors::Argument
  end

  it 'can only be divided by integers' do
    assert_scribble_render '{{ 10.divide 2 }}',     '5'
    assert_scribble_render '{{ 10.divide(-2) }}',   '-5'
    assert_scribble_raises "{{ 10.divide 'foo' }}", Scribble::Errors::Argument
    assert_scribble_raises '{{ 10.divide true }}',  Scribble::Errors::Argument
    assert_scribble_render '{{ 10 / 2 }}',          '5'
    assert_scribble_render '{{ 10 / -2 }}',         '-5'
    assert_scribble_raises "{{ 10 / 'foo' }}",      Scribble::Errors::Argument
    assert_scribble_raises '{{ 10 / true }}',       Scribble::Errors::Argument
  end

  it 'can only have its remainder taken by integers' do
    assert_scribble_render '{{ 10.remainder 3 }}',     '1'
    assert_scribble_render '{{ 10.remainder(-3) }}',   '-2'
    assert_scribble_raises "{{ 10.remainder 'foo' }}", Scribble::Errors::Argument
    assert_scribble_raises '{{ 10.remainder true }}',  Scribble::Errors::Argument
    assert_scribble_render '{{ 10 % 3 }}',             '1'
    assert_scribble_render '{{ 10 % -3 }}',            '-2'
    assert_scribble_raises "{{ 10 % 'foo' }}",         Scribble::Errors::Argument
    assert_scribble_raises '{{ 10 % true }}',          Scribble::Errors::Argument
  end

  it 'can be negated' do
    assert_scribble_render "{{ 3.negative }}", '-3'
    assert_scribble_render "{{ -3 }}",         '-3'
  end

  it 'can be logically negated' do
    assert_scribble_render '{{ 3.not }}',  'false'
    assert_scribble_render '{{ -3.not }}', 'false'
    assert_scribble_render '{{ 0.not }}',  'true'
    assert_scribble_render '{{ !3 }}',     'false'
    assert_scribble_render '{{ !-3 }}',    'false'
    assert_scribble_render '{{ !0 }}',     'true'
  end

  it 'returns an absolute value' do
    assert_scribble_render '{{ 3.abs }}',  '3'
    assert_scribble_render '{{ -3.abs }}', '3'
    assert_scribble_render '{{ 0.abs }}',  '0'
  end
end
