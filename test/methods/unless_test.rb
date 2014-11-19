require_relative '../test_helper'

describe Scribble::Methods::Unless do
  it 'renders according unless-elsif-else semantics' do
    assert_scribble_render '{{ unless false  }}Foo {{ end }}Bar', 'Foo Bar'
    assert_scribble_render '{{ unless true }}Foo {{ end }}Bar', 'Bar'

    assert_scribble_render '{{ unless false  }}Foo {{ else }}Bar {{ end }}Baz', 'Foo Baz'
    assert_scribble_render '{{ unless true }}Foo {{ else }}Bar {{ end }}Baz', 'Bar Baz'

    assert_scribble_render '{{ unless false  }}Foo {{ elsif true  }}Bar {{ end }}Baz', 'Foo Baz'
    assert_scribble_render '{{ unless true }}Foo {{ elsif true  }}Bar {{ end }}Baz', 'Bar Baz'
    assert_scribble_render '{{ unless false  }}Foo {{ elsif false }}Bar {{ end }}Baz', 'Foo Baz'
    assert_scribble_render '{{ unless true }}Foo {{ elsif false }}Bar {{ end }}Baz', 'Baz'

    assert_scribble_render '{{ unless false  }}Foo {{ elsif true  }}Bar {{ else }}Qux {{ end }}Baz', 'Foo Baz'
    assert_scribble_render '{{ unless true }}Foo {{ elsif true  }}Bar {{ else }}Qux {{ end }}Baz', 'Bar Baz'
    assert_scribble_render '{{ unless false  }}Foo {{ elsif false }}Bar {{ else }}Qux {{ end }}Baz', 'Foo Baz'
    assert_scribble_render '{{ unless true }}Foo {{ elsif false }}Bar {{ else }}Qux {{ end }}Baz', 'Qux Baz'
  end

  it 'casts numbers to booleans' do
    assert_scribble_render '{{ unless 0 }}Foo {{ elsif 1 }}Bar {{ end }}Baz', 'Foo Baz'
    assert_scribble_render '{{ unless 1 }}Foo {{ elsif 1 }}Bar {{ end }}Baz', 'Bar Baz'
    assert_scribble_render '{{ unless 0 }}Foo {{ elsif 0 }}Bar {{ end }}Baz', 'Foo Baz'
    assert_scribble_render '{{ unless 1 }}Foo {{ elsif 0 }}Bar {{ end }}Baz', 'Baz'
  end

  it 'casts strings to booleans' do
    assert_scribble_render '{{ unless 0 }}Foo {{ elsif 1 }}Bar {{ end }}Baz', 'Foo Baz'
    assert_scribble_render '{{ unless 1 }}Foo {{ elsif 1 }}Bar {{ end }}Baz', 'Bar Baz'
    assert_scribble_render '{{ unless 0 }}Foo {{ elsif 0 }}Bar {{ end }}Baz', 'Foo Baz'
    assert_scribble_render '{{ unless 1 }}Foo {{ elsif 0 }}Bar {{ end }}Baz', 'Baz'
  end

  it 'works with boolean expressions' do
    assert_scribble_render '{{ unless 0 = 1    }}Foo {{ elsif 1 < 2   }}Bar {{ end }}Baz', 'Foo Baz'
    assert_scribble_render '{{ unless 3 < 10   }}Foo {{ elsif 5 <= 10 }}Bar {{ end }}Baz', 'Bar Baz'
    assert_scribble_render '{{ unless 5 != 5   }}Foo {{ elsif 1.zero  }}Bar {{ end }}Baz', 'Foo Baz'
    assert_scribble_render '{{ unless (0.zero) }}Foo {{ elsif 5 < 0   }}Bar {{ end }}Baz', 'Baz'
  end

  it 'casts other expressions to booleans' do
    assert_scribble_render "{{ unless 1 - 1  }}Foo {{ elsif 'foo'.replace('foo', '') }}Bar {{ end }}Baz", 'Foo Baz'
    assert_scribble_render "{{ unless 1 + 1  }}Foo {{ elsif 3 * 'foo'                }}Bar {{ end }}Baz", 'Bar Baz'
    assert_scribble_render "{{ unless '   '  }}Foo {{ elsif '     '.strip            }}Bar {{ end }}Baz", 'Baz'
    assert_scribble_render "{{ unless '' * 5 }}Foo {{ elsif 0.abs                    }}Bar {{ end }}Baz", 'Foo Baz'
  end
end
