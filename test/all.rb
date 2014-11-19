# Parsing

require_relative 'parsing/parsing_test'

# Main components

require_relative 'registry_test'
require_relative 'template_test'
require_relative 'errors_test'

# Object registrations

require_relative 'objects/boolean_test'
require_relative 'objects/fixnum_test'
require_relative 'objects/nil_test'
require_relative 'objects/string_test'

# Method registrations

require_relative 'methods/if_test'
require_relative 'methods/unless_test'
require_relative 'methods/layout_test'
require_relative 'methods/partial_test'
require_relative 'methods/times_test'
