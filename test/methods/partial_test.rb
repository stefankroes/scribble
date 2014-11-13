require_relative '../test_helper'

describe Scribble::Methods::Partial do
  it 'loads and renders a partial template' do
    loader = MockLoader.new test: 'Foo Bar Baz'
    assert_scribble_render "{{ partial 'test' }}", 'Foo Bar Baz', template: {loader: loader}
  end

  it 'evaluates expressions in the template' do
    loader = MockLoader.new test: '{{ 1 + 2 }}'
    assert_scribble_render "{{ partial 'test' }}", '3', template: {loader: loader}
  end

  # Access

  it 'has access to template methods' do
    loader = MockLoader.new test: '{{ if true }}foo{{ else }}bar{{ end }}'
    assert_scribble_render "{{ partial 'test' }}", 'foo', template: {loader: loader}
  end

  it 'has access to template variables' do
    loader = MockLoader.new test: 'foo={{ foo }}, bar={{ bar }}, foo * bar={{ foo * bar }}'
    assert_scribble_render "{{ partial 'test' }}", 'foo=3, bar=Foo, foo * bar=FooFooFoo', template: {loader: loader}, variables: {foo: 3, bar: 'Foo'}
  end

  it 'has access to template variables when nested' do
    loader = MockLoader.new test: "{{ partial 'nested' }}", nested: '{{ foo }}'
    assert_scribble_render "foo={{ partial 'test' }}", 'foo=3', template: {loader: loader}, variables: {foo: 3}
  end

  # Passing object

  it 'exposes a second argument as a variable' do
    loader = MockLoader.new test: '{{ test }}'
    assert_scribble_render "{{ partial 'test', 'foo' }}", 'foo', template: {loader: loader}, variables: {foo: 3}
  end

  # Formats

  it 'ignores partial format if no render format is specified' do
    loader = MockLoader.new foo: ['FOO', :partial_format]
    assert_scribble_render "{{ partial 'foo' }}", 'FOO', template: {loader: loader}
  end

  it 'adopts context format when no partial format is specified' do
    loader = MockLoader.new foo: 'FOO'
    assert_scribble_render "{{ partial 'foo' }}", 'FOO', template: {loader: loader, format: :template_format}
  end

  it "can't render a partial with format without a suitable converter" do
    loader = MockLoader.new foo: ['FOO', :partial_format]
    assert_raises_message 'No suitable converter' do
      Scribble::Template.new("{{ partial 'foo' }}", loader: loader, format: :template_format).render
    end
  end

  it "won't need converter to render a partial in template format" do
    loader = MockLoader.new foo: ['FOO', :template_format]
    assert_scribble_render "{{ partial 'foo' }}", 'FOO', template: {loader: loader, format: :template_format}
  end

  it "converts a partial with format to the template format using a suitable converter" do
    loader = MockLoader.new foo: ['FOO', :partial_format]
    converter = MockConverter.new :partial_format, :template_format
    assert_scribble_render "{{ partial 'foo' }}", 'partial_format > template_format(FOO)',
      template: {loader: loader, format: :template_format, converters: [converter]}
  end

  # Formats and nested partials

  it "won't converted nested partials with the same format" do
    loader = MockLoader.new test: ["{{ partial 'nested' }}", :partial_format], nested: ['NESTED', :partial_format]
    converter = MockConverter.new :partial_format, :template_format
    assert_scribble_render "{{ partial 'test' }}", 'partial_format > template_format(NESTED)',
      template: {loader: loader, format: :template_format, converters: [converter]}
  end

  it "converts nested partials" do
    loader = MockLoader.new test: ["{{ partial 'nested' }}", :partial_format], nested: ['NESTED', :nested_partial_format]
    c1 = MockConverter.new :partial_format, :template_format
    c2 = MockConverter.new :nested_partial_format, :partial_format
    assert_scribble_render "{{ partial 'test' }}", 'partial_format > template_format(nested_partial_format > partial_format(NESTED))',
      template: {loader: loader, format: :template_format, converters: [c1, c2]}
  end
end