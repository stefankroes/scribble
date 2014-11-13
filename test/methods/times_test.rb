require_relative '../test_helper'

describe Scribble::Methods::Times do
  it 'repeats a block of content x times' do
    assert_scribble_render "{{ 0.times }}Foo Bar {{ end }}", ''
    assert_scribble_render "{{ 1.times }}Foo Bar {{ end }}", 'Foo Bar '
    assert_scribble_render "{{ 3.times }}Foo Bar {{ end }}", 'Foo Bar Foo Bar Foo Bar '
    assert_scribble_render "{{ 5.times }}Foo Bar {{ end }}", 'Foo Bar Foo Bar Foo Bar Foo Bar Foo Bar '
  end
end