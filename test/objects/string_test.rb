require_relative '../test_helper'

describe 'scribble string' do
  it 'can be used as a literal' do
    assert_scribble_render "{{ 'Foo bar baz' }}", 'Foo bar baz'
    assert_scribble_render "{{ '%${^$%T#%##' }}", '%${^$%T#%##'
  end

  it 'supports escape characters' do
    assert_scribble_render "{{ 'Foo \\' bar \\\\ \\a' }}", "Foo ' bar \\ a"
  end

  it 'can be capitalized' do
    assert_scribble_render "{{ 'foo'.capitalize }}", 'Foo'
    assert_scribble_render "{{ 'BAR'.capitalize }}", 'Bar'
    assert_scribble_render "{{ 'Baz'.capitalize }}", 'Baz'
  end

  it 'can be upcased' do
    assert_scribble_render "{{ 'foo'.upcase }}", 'FOO'
    assert_scribble_render "{{ 'BAR'.upcase }}", 'BAR'
    assert_scribble_render "{{ 'Baz'.upcase }}", 'BAZ'
  end

  it 'can be downcased' do
    assert_scribble_render "{{ 'foo'.downcase }}", 'foo'
    assert_scribble_render "{{ 'BAR'.downcase }}", 'bar'
    assert_scribble_render "{{ 'Baz'.downcase }}", 'baz'
  end

  it 'can be reversed' do
    assert_scribble_render "{{ 'foo'.reverse }}", 'oof'
    assert_scribble_render "{{ 'bar'.reverse }}", 'rab'
    assert_scribble_render "{{ 'baz'.reverse }}", 'zab'
  end

  it 'returns its size, length and wether it is empty' do
    assert_scribble_render "{{ 'foo'.size }}",           '3'
    assert_scribble_render "{{ 'foo bar baz'.size }}",   '11'
    assert_scribble_render "{{ 'foo'.length }}",         '3'
    assert_scribble_render "{{ 'foo bar baz'.length }}", '11'
    assert_scribble_render "{{ 'foo'.empty }}",          'false'
    assert_scribble_render "{{ ''.empty }}",             'true'
  end

  it 'supports a replace method' do
    assert_scribble_render "{{ 'foo'.replace('f', 'b').replace 'oo', 'ar' }}", 'bar'
    assert_scribble_render "{{ 'foo bar bar baz'.replace 'bar', 'foo' }}",     'foo foo foo baz'
  end

  it 'supports a remove method' do
    assert_scribble_render "{{ 'foo'.remove('f').remove 'oo' }}",  ''
    assert_scribble_render "{{ 'foo bar bar baz'.remove 'bar' }}", 'foo   baz'
  end

  it 'supports a replace_first method' do
    assert_scribble_render "{{ 'foo'.replace('f', 'b').replace_first 'oo', 'ar' }}", 'bar'
    assert_scribble_render "{{ 'foo bar bar baz'.replace_first 'bar', 'foo' }}",     'foo foo bar baz'
  end

  it 'supports a remove_first method' do
    assert_scribble_render "{{ 'foo'.remove('f').remove_first 'oo' }}",  ''
    assert_scribble_render "{{ 'foo bar bar baz'.remove_first 'bar' }}", 'foo  bar baz'
  end

  it 'supports a append method' do
    assert_scribble_render "{{ 'foo'.append(' bar').append ' baz' }}", 'foo bar baz'
  end

  it 'supports a prepend method' do
    assert_scribble_render "{{ 'foo'.prepend(' bar').prepend ' baz' }}", ' baz barfoo'
  end

  it 'supports a truncate method' do
    assert_scribble_render "{{ ' foo bar baz'.truncate 8 }}",        ' foo bar ...'
    assert_scribble_render "{{ ' foo bar baz'.truncate 8, 'aaa' }}", ' foo baraaa'
    assert_scribble_render "{{ ' foo bar baz'.truncate 12 }}",       ' foo bar baz'
  end

  it 'supports a truncate words method' do
    assert_scribble_render "{{ ' foo bar baz'.truncate_words 2 }}",        ' foo bar ...'
    assert_scribble_render "{{ ' foo bar baz'.truncate_words 2, 'aaa' }}", ' foo baraaa'
    assert_scribble_render "{{ ' foo bar baz'.truncate_words 3 }}",        ' foo bar baz'
  end

  it 'supports strip methods' do
    assert_scribble_render "{{ '   foo bar  '.strip }}",       'foo bar'
    assert_scribble_render "{{ '   foo bar  '.strip_left }}",  'foo bar  '
    assert_scribble_render "{{ '   foo bar  '.strip_right }}", '   foo bar'
  end

  it 'supports a repeat method' do
    assert_scribble_render "{{ 'foo'.repeat 3 }}",           'foofoofoo'
    assert_scribble_render "{{ 'foo'.repeat(3).repeat 2 }}", 'foofoofoofoofoofoo'
  end

  it 'supports method and operator for logical or' do
    assert_scribble_render "{{ ''.or true }}",     'true'
    assert_scribble_render "{{ 'foo'.or true }}",  'true'
    assert_scribble_render "{{ ''.or false }}",    'false'
    assert_scribble_render "{{ 'foo'.or false }}", 'true'
    assert_scribble_render "{{ ''.or 2 }}",        'true'
    assert_scribble_render "{{ 'foo'.or 2 }}",     'true'
    assert_scribble_render "{{ ''.or 0 }}",        'false'
    assert_scribble_render "{{ 'foo'.or 0 }}",     'true'
    assert_scribble_render "{{ ''.or 'foo' }}",    'true'
    assert_scribble_render "{{ 'foo'.or 'foo' }}", 'true'
    assert_scribble_render "{{ ''.or '' }}",       'false'
    assert_scribble_render "{{ 'foo'.or '' }}",    'true'
    assert_scribble_render "{{ '' | true }}",      'true'
    assert_scribble_render "{{ 'foo' | true }}",   'true'
    assert_scribble_render "{{ '' | false }}",     'false'
    assert_scribble_render "{{ 'foo' | false }}",  'true'
    assert_scribble_render "{{ '' | 2 }}",         'true'
    assert_scribble_render "{{ 'foo' | 2 }}",      'true'
    assert_scribble_render "{{ '' | 0 }}",         'false'
    assert_scribble_render "{{ 'foo' | 0 }}",      'true'
    assert_scribble_render "{{ '' | 'foo' }}",     'true'
    assert_scribble_render "{{ 'foo' | 'foo' }}",  'true'
    assert_scribble_render "{{ '' | '' }}",        'false'
    assert_scribble_render "{{ 'foo' | '' }}",     'true'
  end

  it 'supports method and operator for logical and' do
    assert_scribble_render "{{ ''.and true }}",     'false'
    assert_scribble_render "{{ 'foo'.and true }}",  'true'
    assert_scribble_render "{{ ''.and false }}",    'false'
    assert_scribble_render "{{ 'foo'.and false }}", 'false'
    assert_scribble_render "{{ ''.and 2 }}",        'false'
    assert_scribble_render "{{ 'foo'.and 2 }}",     'true'
    assert_scribble_render "{{ ''.and 0 }}",        'false'
    assert_scribble_render "{{ 'foo'.and 0 }}",     'false'
    assert_scribble_render "{{ ''.and 'foo' }}",    'false'
    assert_scribble_render "{{ 'foo'.and 'foo' }}", 'true'
    assert_scribble_render "{{ ''.and '' }}",       'false'
    assert_scribble_render "{{ 'foo'.and '' }}",    'false'
    assert_scribble_render "{{ '' & true }}",       'false'
    assert_scribble_render "{{ 'foo' & true }}",    'true'
    assert_scribble_render "{{ '' & false }}",      'false'
    assert_scribble_render "{{ 'foo' & false }}",   'false'
    assert_scribble_render "{{ '' & 2 }}",          'false'
    assert_scribble_render "{{ 'foo' & 2 }}",       'true'
    assert_scribble_render "{{ '' & 0 }}",          'false'
    assert_scribble_render "{{ 'foo' & 0 }}",       'false'
    assert_scribble_render "{{ '' & 'foo' }}",      'false'
    assert_scribble_render "{{ 'foo' & 'foo' }}",   'true'
    assert_scribble_render "{{ '' & '' }}",         'false'
    assert_scribble_render "{{ 'foo' & '' }}",      'false'
  end

  it 'can equal another string' do
    assert_scribble_render "{{ 'foo'.equals 'foo' }}", 'true'
    assert_scribble_render "{{ 'foo'.equals 'bar' }}", 'false'
    assert_scribble_render "{{ 'foo' = 'foo' }}",      'true'
    assert_scribble_render "{{ 'foo' = 'bar' }}",      'false'
  end

  it 'does not equal another type' do
    assert_scribble_render "{{ 'foo'.equals 3 }}",    'false'
    assert_scribble_render "{{ 'foo'.equals true }}", 'false'
    assert_scribble_render "{{ 'foo' = 3 }}",         'false'
    assert_scribble_render "{{ 'foo' = true }}",      'false'
  end

  it 'can differ from another integer' do
    assert_scribble_render "{{ 'foo'.differs 'foo' }}", 'false'
    assert_scribble_render "{{ 'foo'.differs 'bar' }}", 'true'
    assert_scribble_render "{{ 'foo' != 'foo' }}",      'false'
    assert_scribble_render "{{ 'foo' != 'bar' }}",      'true'
  end

  it 'differs from another type' do
    assert_scribble_render "{{ 'foo'.differs 3 }}",    'true'
    assert_scribble_render "{{ 'foo'.differs true }}", 'true'
    assert_scribble_render "{{ 'foo' != 3 }}",         'true'
    assert_scribble_render "{{ 'foo' != true }}",      'true'
  end

  it 'can not be compared' do
    assert_scribble_raises "{{ 'foo'.greater 'foo' }}"
    assert_scribble_raises "{{ 'foo'.greater 3 }}"
    assert_scribble_raises "{{ 'foo'.greater true }}"
    assert_scribble_raises "{{ 'foo' > 'foo' }}"
    assert_scribble_raises "{{ 'foo' > 3 }}"
    assert_scribble_raises "{{ 'foo' > true }}"
    assert_scribble_raises "{{ 'foo'.less 'foo' }}"
    assert_scribble_raises "{{ 'foo'.less 3 }}"
    assert_scribble_raises "{{ 'foo'.less true }}"
    assert_scribble_raises "{{ 'foo' < 'foo' }}"
    assert_scribble_raises "{{ 'foo' < 3 }}"
    assert_scribble_raises "{{ 'foo' < true }}"
    assert_scribble_raises "{{ 'foo'.greater_or_equal 'foo' }}"
    assert_scribble_raises "{{ 'foo'.greater_or_equal 3 }}"
    assert_scribble_raises "{{ 'foo'.greater_or_equal true }}"
    assert_scribble_raises "{{ 'foo' >= 'foo' }}"
    assert_scribble_raises "{{ 'foo' >= 3 }}"
    assert_scribble_raises "{{ 'foo' >= true }}"
    assert_scribble_raises "{{ 'foo'.less_or_equal 'foo' }}"
    assert_scribble_raises "{{ 'foo'.less_or_equal 3 }}"
    assert_scribble_raises "{{ 'foo'.less_or_equal true }}"
    assert_scribble_raises "{{ 'foo' <= 'foo' }}"
    assert_scribble_raises "{{ 'foo' <= 3 }}"
    assert_scribble_raises "{{ 'foo' <= true }}"
  end

  it 'can have integers and strings added to it but not booleans' do
    assert_scribble_render "{{ 'foo'.add 2 }}",     'foo2'
    assert_scribble_render "{{ 'foo'.add 'bar' }}", 'foobar'
    assert_scribble_raises "{{ 'foo'.add true }}",  Scribble::Errors::Argument
    assert_scribble_render "{{ 'foo' + 2 }}",       'foo2'
    assert_scribble_render "{{ 'foo' + 'bar' }}",   'foobar'
    assert_scribble_raises "{{ 'foo' + true }}",    Scribble::Errors::Argument
  end

  it 'can only have string subtracted from it' do
    assert_scribble_render "{{ 'foobarbaz foo'.subtract 'foo' }}", 'barbaz '
    assert_scribble_render "{{ 'foobarbaz foo'.subtract 'bar' }}", 'foobaz foo'
    assert_scribble_raises "{{ 'foobarbaz foo'.subtract 2 }}",     Scribble::Errors::Argument
    assert_scribble_raises "{{ 'foobarbaz foo'.subtract true }}",  Scribble::Errors::Argument
    assert_scribble_render "{{ 'foobarbaz foo' - 'foo' }}",        'barbaz '
    assert_scribble_render "{{ 'foobarbaz foo' - 'bar' }}",        'foobaz foo'
    assert_scribble_raises "{{ 'foobarbaz foo' - 2 }}",            Scribble::Errors::Argument
    assert_scribble_raises "{{ 'foobarbaz foo' - true }}",         Scribble::Errors::Argument
  end

  it 'can only be multiplied by positive integers' do
    assert_scribble_render "{{ 'foo'.multiply 2 }}",     'foofoo'
    assert_scribble_render "{{ 'foo'.multiply 5 }}",     'foofoofoofoofoo'
    assert_scribble_raises "{{ 'foo'.multiply 'foo' }}", Scribble::Errors::Argument
    assert_scribble_raises "{{ 'foo'.multiply true }}",  Scribble::Errors::Argument
    assert_scribble_raises "{{ 'foo'.multiply(-2) }}",   Scribble::Errors::Argument
    assert_scribble_render "{{ 'foo' * 2 }}",            'foofoo'
    assert_scribble_render "{{ 'foo' * 5 }}",            'foofoofoofoofoo'
    assert_scribble_raises "{{ 'foo' * 'foo' }}",        Scribble::Errors::Argument
    assert_scribble_raises "{{ 'foo' * true }}",         Scribble::Errors::Argument
    assert_scribble_raises "{{ 'foo' * -2 }}",           Scribble::Errors::Argument
  end

  it 'can not be divided' do
    assert_scribble_raises "{{ 'foo'.divide 5 }}"
    assert_scribble_raises "{{ 'foo'.divide 'foo' }}"
    assert_scribble_raises "{{ 'foo'.divide true }}"
    assert_scribble_raises "{{ 'foo' / 5 }}"
    assert_scribble_raises "{{ 'foo' / 'foo' }}"
    assert_scribble_raises "{{ 'foo' / true }}"
  end

  it 'can not be have its remainder taken' do
    assert_scribble_raises "{{ 'foo'.remainder 5 }}"
    assert_scribble_raises "{{ 'foo'.remainder 'foo' }}"
    assert_scribble_raises "{{ 'foo'.remainder true }}"
    assert_scribble_raises "{{ 'foo' % 5 }}"
    assert_scribble_raises "{{ 'foo' % 'foo' }}"
    assert_scribble_raises "{{ 'foo' % true }}"
  end

  it 'can not be negated' do
    assert_scribble_raises "{{ 'foo'.negative }}"
    assert_scribble_raises "{{ -'foo' }}"
  end

  it 'can be logically negated' do
    assert_scribble_render "{{ 'foo'.not }}", 'false'
    assert_scribble_render "{{ ''.not }}",    'true'
    assert_scribble_render "{{ !'foo' }}",    'false'
    assert_scribble_render "{{ !'' }}",       'true'
  end
end
