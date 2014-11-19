# Support

require_relative 'scribble/support/context'
require_relative 'scribble/support/utilities'
require_relative 'scribble/support/matcher'
require_relative 'scribble/support/unmatched'

# Parsing

require_relative 'scribble/parsing/parser'
require_relative 'scribble/parsing/transform'
require_relative 'scribble/parsing/nester'
require_relative 'scribble/parsing/reporter'

# Node types

require_relative 'scribble/nodes/node'
require_relative 'scribble/nodes/call'
require_relative 'scribble/nodes/ending'
require_relative 'scribble/nodes/value'

# Main components

require_relative 'scribble/registry'
require_relative 'scribble/method'
require_relative 'scribble/block'
require_relative 'scribble/partial'
require_relative 'scribble/template'
require_relative 'scribble/errors'
require_relative 'scribble/converter'

# Object registrations

require_relative 'scribble/objects/boolean'
require_relative 'scribble/objects/fixnum'
require_relative 'scribble/objects/nil'
require_relative 'scribble/objects/string'

# Method registrations

require_relative 'scribble/methods/if'
require_relative 'scribble/methods/unless'
require_relative 'scribble/methods/layout'
require_relative 'scribble/methods/partial'
require_relative 'scribble/methods/times'
