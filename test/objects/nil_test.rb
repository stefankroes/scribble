require_relative '../test_helper'

describe 'scribble nil' do
  def with_nil
    Scribble::Registry.reset do
      Scribble::Registry.for Scribble::Template::Context do
        method :nil, to: -> { nil }
      end

      yield
    end
  end

  it 'supports method and operator for logical or' do
    with_nil do
      assert_scribble_render '{{ nil.or true }}',     'true'
      assert_scribble_render '{{ nil.or false }}',    'false'
      assert_scribble_render '{{ nil.or 2 }}',        'true'
      assert_scribble_render '{{ nil.or 0 }}',        'false'
      assert_scribble_render "{{ nil.or 'foo' }}",    'true'
      assert_scribble_render "{{ nil.or '' }}",       'false'
      assert_scribble_render '{{ nil | true }}',      'true'
      assert_scribble_render '{{ nil | false }}',     'false'
      assert_scribble_render '{{ nil | 2 }}',         'true'
      assert_scribble_render '{{ nil | 0 }}',         'false'
      assert_scribble_render "{{ nil | 'foo' }}",     'true'
      assert_scribble_render "{{ nil | '' }}",        'false'
    end
  end

  it 'supports method and operator for logical and' do
    with_nil do
      assert_scribble_render '{{ nil.and true }}',     'false'
      assert_scribble_render '{{ nil.and false }}',    'false'
      assert_scribble_render '{{ nil.and 2 }}',        'false'
      assert_scribble_render '{{ nil.and 0 }}',        'false'
      assert_scribble_render "{{ nil.and 'foo' }}",    'false'
      assert_scribble_render "{{ nil.and '' }}",       'false'
      assert_scribble_render '{{ nil & true }}',       'false'
      assert_scribble_render '{{ nil & false }}',      'false'
      assert_scribble_render '{{ nil & 2 }}',          'false'
      assert_scribble_render '{{ nil & 0 }}',          'false'
      assert_scribble_render "{{ nil & 'foo' }}",      'false'
      assert_scribble_render "{{ nil & '' }}",         'false'
    end
  end

  it 'equals only nil' do
    with_nil do
      assert_scribble_render '{{ nil.equals nil }}',   'true'
      assert_scribble_render "{{ nil.equals 'bar' }}", 'false'
      assert_scribble_render '{{ nil.equals 1 }}',     'false'
      assert_scribble_render '{{ nil.equals true }}',  'false'
      assert_scribble_render '{{ nil.equals false }}', 'false'
      assert_scribble_render '{{ nil = nil }}',        'true'
      assert_scribble_render "{{ nil = 'bar' }}",      'false'
      assert_scribble_render '{{ nil = 1 }}',          'false'
      assert_scribble_render '{{ nil = true }}',       'false'
      assert_scribble_render '{{ nil = false }}',      'false'
    end
  end

  it 'differs everything but nil' do
    with_nil do
      assert_scribble_render '{{ nil.differs nil }}',   'false'
      assert_scribble_render "{{ nil.differs 'bar' }}", 'true'
      assert_scribble_render '{{ nil.differs 1 }}',     'true'
      assert_scribble_render '{{ nil.differs true }}',  'true'
      assert_scribble_render '{{ nil.differs false }}', 'true'
      assert_scribble_render '{{ nil != nil }}',        'false'
      assert_scribble_render "{{ nil != 'bar' }}",      'true'
      assert_scribble_render '{{ nil != 1 }}',          'true'
      assert_scribble_render '{{ nil != true }}',       'true'
      assert_scribble_render '{{ nil != false }}',      'true'
    end
  end

  it 'renders as an empty string' do
    with_nil do
      assert_scribble_render '{{ nil }}', ''
    end
  end
end
