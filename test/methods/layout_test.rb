require_relative '../test_helper'

describe Scribble::Methods::Layout do
  it 'loads and renders a layout template' do
    loader = MockLoader.new test: 'Foo {{ content }} Baz'
    assert_scribble_render "{{ layout 'test' }}Bar{{end}}", 'Foo Bar Baz', template: {loader: loader}
  end

  it 'evaluates expressions in the template' do
    loader = MockLoader.new test: "{{ 'Foo' * 2 }} {{ content.repeat(2) }} Baz"
    assert_scribble_render "{{ layout 'test' }}Bar{{end}}", 'FooFoo BarBar Baz', template: {loader: loader}
  end

  # Access

  it 'has access to template methods' do
    loader = MockLoader.new test: 'Foo {{ if true }}{{ content }} {{ end }}Baz'
    assert_scribble_render "{{ layout 'test' }}Bar{{end}}", 'Foo Bar Baz', template: {loader: loader}
  end

  it 'has access to template variables' do
    loader = MockLoader.new test: 'Foo {{ content }} Baz {{ 12 }}'
    assert_scribble_render "{{ layout 'test' }}Bar{{end}}", 'Foo Bar Baz 12', template: {loader: loader}, variables: {foo: 12}
  end

  it 'has access to layout variables' do
    skip # Implement var first
  end

  # Passing object and nesting

  it 'exposes a second argument as a variable' do
    loader = MockLoader.new test: '{{ test }} {{ content }}'
    assert_scribble_render "{{ layout 'test', 'Foo' }}Bar {{end}}Baz", 'Foo Bar Baz', template: {loader: loader}
  end

  it 'exposes a second argument as a variable when nested' do
    loader = MockLoader.new foo: "{{ foo }}{{ layout 'bar', content }}{{ foo }}{{ end }}{{ foo }}", bar: '{{ bar }}{{ content }}{{ bar }}'
    assert_scribble_render "0{{ layout 'foo', 1 }}2{{end}}0", '0121210', template: {loader: loader}
  end

  # Formats

  it 'adopts context format when no layout format is specified' do
    loader = MockLoader.new foo: '{{ content }}'
    assert_scribble_render "{{ layout 'foo' }}FOO{{ end }}", 'FOO', template: {loader: loader, format: :template_format}
  end

  it "won't need converter to render a layout in template format" do
    loader = MockLoader.new foo: ['{{ content }}', :template_format]
    assert_scribble_render "{{ layout 'foo' }}FOO{{ end }}", 'FOO', template: {loader: loader, format: :template_format}
  end

  it "can't render a layout with a format without suitable converters back and forth" do
    loader = MockLoader.new foo: ['{{ content }}BAR', :layout_format]
    c1 = MockConverter.new :layout_format, :template_format
    c2 = MockConverter.new :template_format, :layout_format

    assert_raises_message 'No suitable converter' do
      Scribble::Template.new("{{ layout 'foo' }}FOO{{ end }}", loader: loader, format: :template_format, converters: [c1]).render
    end

    assert_raises_message 'No suitable converter' do
      Scribble::Template.new("{{ layout 'foo' }}FOO{{ end }}", loader: loader, format: :template_format, converters: [c2]).render
    end

    assert_scribble_render "{{ layout 'foo' }}FOO{{ end }}", 'layout_format > template_format(template_format > layout_format(FOO)BAR)',
      template: {loader: loader, format: :template_format, converters: [c1, c2]}
  end

end