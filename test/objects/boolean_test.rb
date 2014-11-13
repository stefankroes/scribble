require_relative '../test_helper'

describe 'scribble boolean' do
  it 'can be used as a literal' do
    assert_scribble_render '{{ true }}',  'true'
    assert_scribble_render '{{ false }}', 'false'
  end

  it 'supports method and operator for logical or' do
    assert_scribble_render '{{ false.or true }}',  'true'
    assert_scribble_render '{{ true.or true }}',   'true'
    assert_scribble_render '{{ false.or false }}', 'false'
    assert_scribble_render '{{ true.or false }}',  'true'
    assert_scribble_render '{{ false.or 2 }}',     'true'
    assert_scribble_render '{{ true.or 2 }}',      'true'
    assert_scribble_render '{{ false.or 0 }}',     'false'
    assert_scribble_render '{{ true.or 0 }}',      'true'
    assert_scribble_render "{{ false.or 'foo' }}", 'true'
    assert_scribble_render "{{ true.or 'foo' }}",  'true'
    assert_scribble_render "{{ false.or '' }}",    'false'
    assert_scribble_render "{{ true.or '' }}",     'true'
    assert_scribble_render '{{ false | true }}',   'true'
    assert_scribble_render '{{ true | true }}',    'true'
    assert_scribble_render '{{ false | false }}',  'false'
    assert_scribble_render '{{ true | false }}',   'true'
    assert_scribble_render '{{ false | 2 }}',      'true'
    assert_scribble_render '{{ true | 2 }}',       'true'
    assert_scribble_render '{{ false | 0 }}',      'false'
    assert_scribble_render '{{ true | 0 }}',       'true'
    assert_scribble_render "{{ false | 'foo' }}",  'true'
    assert_scribble_render "{{ true | 'foo' }}",   'true'
    assert_scribble_render "{{ false | '' }}",     'false'
    assert_scribble_render "{{ true | '' }}",      'true'
  end

  it 'supports method and operator for logical and' do
    assert_scribble_render '{{ false.and true }}',  'false'
    assert_scribble_render '{{ true.and true }}',   'true'
    assert_scribble_render '{{ false.and false }}', 'false'
    assert_scribble_render '{{ true.and false }}',  'false'
    assert_scribble_render '{{ false.and 2 }}',     'false'
    assert_scribble_render '{{ true.and 2 }}',      'true'
    assert_scribble_render '{{ false.and 0 }}',     'false'
    assert_scribble_render '{{ true.and 0 }}',      'false'
    assert_scribble_render "{{ false.and 'foo' }}", 'false'
    assert_scribble_render "{{ true.and 'foo' }}",  'true'
    assert_scribble_render "{{ false.and '' }}",    'false'
    assert_scribble_render "{{ true.and '' }}",     'false'
    assert_scribble_render '{{ false & true }}',    'false'
    assert_scribble_render '{{ true & true }}',     'true'
    assert_scribble_render '{{ false & false }}',   'false'
    assert_scribble_render '{{ true & false }}',    'false'
    assert_scribble_render '{{ false & 2 }}',       'false'
    assert_scribble_render '{{ true & 2 }}',        'true'
    assert_scribble_render '{{ false & 0 }}',       'false'
    assert_scribble_render '{{ true & 0 }}',        'false'
    assert_scribble_render "{{ false & 'foo' }}",   'false'
    assert_scribble_render "{{ true & 'foo' }}",    'true'
    assert_scribble_render "{{ false & '' }}",      'false'
    assert_scribble_render "{{ true & '' }}",       'false'
  end

  it 'can equal another boolean' do
    assert_scribble_render '{{ true.equals true }}',  'true'
    assert_scribble_render '{{ true.equals false }}', 'false'
    assert_scribble_render '{{ true = true }}',       'true'
    assert_scribble_render '{{ true = false }}',      'false'
  end

  it 'does not equal another type' do
    assert_scribble_render '{{ true.equals 3 }}',     'false'
    assert_scribble_render "{{ true.equals 'foo' }}", 'false'
    assert_scribble_render '{{ true = 3 }}',          'false'
    assert_scribble_render "{{ true = 'foo' }}",      'false'
  end

  it 'can differ from another boolean' do
    assert_scribble_render '{{ true.differs true }}',  'false'
    assert_scribble_render '{{ true.differs false }}', 'true'
    assert_scribble_render '{{ true != true }}',       'false'
    assert_scribble_render '{{ true != false }}',      'true'
  end

  it 'differs from another type' do
    assert_scribble_render '{{ true.differs 3 }}',     'true'
    assert_scribble_render "{{ true.differs 'foo' }}", 'true'
    assert_scribble_render '{{ true != 3 }}',          'true'
    assert_scribble_render "{{ true != 'foo' }}",      'true'
  end

  it 'can not be compared' do
    assert_scribble_raises "{{ true.greater 'foo' }}"
    assert_scribble_raises '{{ true.greater 3 }}'
    assert_scribble_raises '{{ true.greater true }}'
    assert_scribble_raises "{{ true > 'foo' }}"
    assert_scribble_raises '{{ true > 3 }}'
    assert_scribble_raises '{{ true > true }}'
    assert_scribble_raises "{{ true.less 'foo' }}"
    assert_scribble_raises '{{ true.less 3 }}'
    assert_scribble_raises '{{ true.less true }}'
    assert_scribble_raises "{{ true < 'foo' }}"
    assert_scribble_raises '{{ true < 3 }}'
    assert_scribble_raises '{{ true < true }}'
    assert_scribble_raises "{{ true.greater_or_equal 'foo' }}"
    assert_scribble_raises '{{ true.greater_or_equal 3 }}'
    assert_scribble_raises '{{ true.greater_or_equal true }}'
    assert_scribble_raises "{{ true >= 'foo' }}"
    assert_scribble_raises '{{ true >= 3 }}'
    assert_scribble_raises '{{ true >= true }}'
    assert_scribble_raises "{{ true.less_or_equal 'foo' }}"
    assert_scribble_raises '{{ true.less_or_equal 3 }}'
    assert_scribble_raises '{{ true.less_or_equal true }}'
    assert_scribble_raises "{{ true <= 'foo' }}"
    assert_scribble_raises '{{ true <= 3 }}'
    assert_scribble_raises '{{ true <= true }}'
  end

  it 'does not support calculations' do
    assert_scribble_raises '{{ true.add 3 }}'
    assert_scribble_raises "{{ true.add 'foo' }}"
    assert_scribble_raises '{{ true.add true }}'
    assert_scribble_raises '{{ true + 3 }}'
    assert_scribble_raises "{{ true + 'foo' }}"
    assert_scribble_raises '{{ true + true }}'
    assert_scribble_raises '{{ true.subtract 3 }}'
    assert_scribble_raises "{{ true.subtract 'foo' }}"
    assert_scribble_raises '{{ true.subtract true }}'
    assert_scribble_raises '{{ true - 3 }}'
    assert_scribble_raises "{{ true - 'foo' }}"
    assert_scribble_raises '{{ true - true }}'
    assert_scribble_raises '{{ true.multiply 3 }}'
    assert_scribble_raises "{{ true.multiply 'foo' }}"
    assert_scribble_raises '{{ true.multiply true }}'
    assert_scribble_raises '{{ true * 3 }}'
    assert_scribble_raises "{{ true * 'foo' }}"
    assert_scribble_raises '{{ true * true }}'
    assert_scribble_raises '{{ true.divide 3 }}'
    assert_scribble_raises "{{ true.divide 'foo' }}"
    assert_scribble_raises '{{ true.divide true }}'
    assert_scribble_raises '{{ true / 3 }}'
    assert_scribble_raises "{{ true / 'foo' }}"
    assert_scribble_raises '{{ true / true }}'
    assert_scribble_raises '{{ true.remainder 3 }}'
    assert_scribble_raises "{{ true.remainder 'foo' }}"
    assert_scribble_raises '{{ true.remainder true }}'
    assert_scribble_raises '{{ true % 3 }}'
    assert_scribble_raises "{{ true % 'foo' }}"
    assert_scribble_raises '{{ true % true }}'
  end

  it 'can not be negated' do
    assert_scribble_raises '{{ true.negative }}'
    assert_scribble_raises '{{ -true }}'
  end

  it 'can be logically negated' do
    assert_scribble_render '{{ true.not }}',  'false'
    assert_scribble_render '{{ false.not }}', 'true'
    assert_scribble_render '{{ !!true }}',    'true'
    assert_scribble_render '{{ !!!true }}',   'false'
  end
end