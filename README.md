# Scribble

Scribble is a client facing template language similar to Liquid. Scribble was written in Ruby and can be used in any Ruby or Ruby on Rails project. It takes a template file, consisting of text and Scribble tags and transforms it into text. Scribble can be used to transform any plain text format like HTML, Markdown, JSON, XML or plain text. Client facing means that it is safe to use Scribble to run/evaluate user provided templates.

## Project status and features

Scribble currently has solid architecture and features and it is already used in production in [Sitebox.io](http://www.sitebox.io/). The actual scripting API is still somewhat sparse regarding supported types and methods but will be extended in future minor releases and can also easily be extended on a per application basis. Pull requests enriching the API are very welcome. Scribble currently supports:

* A proper grammar based parser, generating user-friendly syntax errors that unclude line and column numbers
* Excellent runtime error reporting (`Wrong number of arguments (0 for 1-2) for 'partial' at line 1 column 4`)
* Simple and consistent tag syntax using {{ ... }}
* Unary and binary operators with proper precedence rules and parentheses
* Method invocation, method chaining, block methods and command style method invocation (without parentheses)
* Nested execution scopes (blocks) and rescursive resolving of methods and variables
* Boolean, integer, string and nil scripting types (Arrays or hashes are not currently supported)
* Rich object oriented API for scripting with these types
* Pluggable architecture for additional (application specific) types
* If/elsif/else, layout and partial methods
* Pluggable loader architecture for working with partials and layouts
* Ability to convert between formats when inlining partials and layouts with mixed formats (for example: Markdown and HTML)

## Compatibility

Scribble is only compatible with Ruby 2.0 and Ruby 2.1 because it uses keyword arguments.

## Installation

Add this line to your application's Gemfile:

    gem 'scribble'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install scribble

## Basic Usage

The following example shows how to load a Scribble template and evaluate it.

``` ruby
Scribble::Template.new("I'm a template! {{1 + 1}}").render
```

The template constructor and and render method both take options. The following example shows the same call but with all options. We will describe the specifics of formats, loaders, converters and registers later.

``` ruby
template_options = {
  format: :markdown,             # The template itself is in Markdown format
  loader: my_partial_loader,     # Object handling the loading of partials and layouts
  converters: [html2md, md2html] # Two converters to convert between HTML and Markdown
}

render_options = {
  variables: {a: 1, b: 'Foo'},   # Expose some data to the template
  registers: {c: 2, d: 'Bar'},   # For internal use by Scribble method implementations
  format: :html                  # Request output conversion to HTML format
}

Scribble::Template.new(source, template_options).render render_options
```

## Basic Template

The following example is a Scribble template repeating some text, folowed by an `if` statement.

    {{ 3.times }}Hello World!{{ end }}

    {{ if foo = 3 | bar = 'baz' }}
      Either foo equals the number 3 or bar equals the string 'baz'
    {{ elsif 3 * 3 != foo & bar }}
      Foo does not equal 9 and bar is either true, a non-zero number or a non-empty string
    {{ else }}
      None of the above
    {{ end }}

In the example above:

* Everything between {{ and }} are Scribble tags, the rest is text.
* `times` and `if` are block methods that can be used to manipulate the associated block (up until the next `end`).
* `foo` and `bar` are variables that can be inserted by passing them into the `render` method from Ruby.
* `=`, `|`, `&`, `*`, `!=` are operators. Operators are invoked on their left hand side with their right hand side as an argument.
* `elsif` and `else` are methods that are defined only in the context of an `if` block to split up the block.

## Template and rendering options

Scribble supports a few options when initializing and rendering templates. This section describes those options.

### Supplying a partial loader

When you supply Scribble with a partial loader you can use the `partial` and `layout` methods in order to inline other Scribble templates. A loader is an objects that implements a single instance method named `load` which takes the partial name as a single string argument. The method should return a Scribble::Partial or nil if the partial cannot be found. Initializing the partial with a format is optional.

``` ruby
class MyLoader
  def load name

    # ...

    unless partial_source.nil?
      Scribble::Partial.new partial_source, format: partial_format
    end
  end
end

Scribble::Template.new(template_source, loader: MyLoader.new).render
```

### Formats and converters

Scribble is able to convert between different formats when inlining partials and rendering templates. This functionality is completely optional, just ignore all format and converter options to disable it. If you want to use this functionality you should tell Scribble the format of your templates and partials when initializing them using symbols. Additionally you should tell Scribble in what format to render and supply the format convertors that will be needed to do so.

``` ruby
md2html = Scribble.converter :markdown => :html do |markdown|
  Kramdown::Document.new(markdown).to_html
end

template = Scribble::Template.new template_source, format: :markdown, converters: [md2html]

template.render :html
```

### Variables and registers

Variables are the way to pass data from your template into your Scribble template. In addition to variables, you can pas registers. Registers will not be available as Scribble variables but they will be available to the Ruby implementations of your methods.


``` ruby
template = Scribble::Template.new template_source

template.render variables: {a: 1}, registers: {some_private_resource: 2}
```

## Template Language

The Scribble template language takes a lot of cues from Ruby:

* Everything is an object
* Objects only support methods, no attributes
* Methods can take a block of code, delimited by the keyword `end`
* Operators are just method calls, invoked on their left hand side
* Parentheses are optional when passing arguments into a method
* Multiple methods can be chained using dot `.` notation

Some key differences are:

* Scribble only implements a very small subset of the Ruby syntax.
* Blocks of code don't need to be opened. The interpreter knows which methods take a block.
* Constructs like an `if` statement are also implemented as block methods, using so called split methods for constructs like `elsif` and `else`.
* Meanings of operators have been simplified because Scribble only needs to support certain operations.

### Syntax

The Scribble grammar is defined using [Parslet](http://kschiess.github.io/parslet/) in [parser.rb](https://github.com/stefankroes/scribble/blob/master/lib/scribble/parsing/parser.rb).

A Scribble template consists of text and tags. Tags are everything between {{ and }}. Tags containing only the keyword `end` are special tags that close a block.

    3 times 6 is: {{ 3 * 6 }}

    {{ 3.times }}
    Hello World!
    {{ end }}

Scribble supports integers, strings, booleans and nil. Nil doesn't have a literal, it can only be returned. Other objects do have literals.

    {{ 'This is string' }}

    This is a number: {{ 3 }}

    {{ true }} and {{ false }} are booleans

Methods are called globally or on objects with the dot `.` notation. Parentheses are optional when invoking a method and are not allowed when calling a variable. Methods can be chained and used as arguments to other methods.

    {{ some_method }}
    {{ some_method() }}
    {{ some_method(1, true, 'test') }}
    {{ some_method 1, true, 'test' }}
    {{ some_variable }}
    {{ -3.abs }}
    {{ 'Scribble'.replace('Scr', 'Dr').upcase }}
    {{ true.or 1 }}
    {{ 3.multiply(5.subtract(2)) }}
    {{ some_method another_method }}
    This will cause an error: {{ some_variable() }}

Unary and binary operators are supported. As are parentheses.

    {{ -2 * (3 + 5) }}
    {{ 'Scribble' - 'Scr' }}
    {{ 3 * 'Repeat me! ' }}

### Operators and precedence

The table below shows all supported operators in order of precedence. Operators are invoked as methods on their left hand side (or on their only operand in case of a unary operator). The table also shows the method name that is associated with each operator for this purpose. This essentially enables operator overloading since you just define the associated method.

Operator            | Precedence | Description      | Associated method
------------------- | ---------- | ---------------- | -----------------
`!`                 | 1          | Unary *not*      | `not`
`-`                 | 2          | Unary minus      | `negative`
`*`                 | 3          | Multiplication   | `multiply`
`/`                 | 3          | Division         | `divide`
`%`                 | 3          | Remainder        | `remainder`
`+`                 | 4          | Addition         | `add`
`-`                 | 4          | Subtraction      | `subtract`
`>`                 | 5          | Greater          | `greater`
`<`                 | 5          | Less             | `less`
`>=`                | 5          | Greater or equal | `greater_or_equal`
`<=`                | 5          | Less or equal    | `less_or_equal`
`=`                 | 6          | Equality         | `equals`
`!=`                | 6          | Inequality       | `differs`
`&`                 | 7          | Logical *and*    | `and`
<code>&#124;</code> | 8          | Logical *or*     | `or`

## Standard types and methods

Scribble provides an extensible set of types and methods as a base API. This section describes Scribble functionality that is always available.

### String

Strings support a literal notation using single quotes. Single quotes and backslashes can be escaped within a string using a backslash (`\'` and `\\`). Strings are considered false when they are empty and true when they are not. Strings support many methods and many operators (through methods), an overview can be found in [objects/string.rb](https://github.com/stefankroes/scribble/blob/master/lib/scribble/objects/string.rb).

    {{ 'I\'m a string!' }}

    {{ if foo }}
      Text in the string foo: {{ foo }}
    {{ else }}
      The string foo is empty!
    {{ end }}

    {{ 'foo' * 3 }}
    {{ 'foo'.repeat 3 }}
    {{ 'foo' + 'bar' }}
    {{ 'foo' - 'oo' }}
    {{ 'foo'.replace 'foo', 'bar' }}
    {{ 'foo'.upcase.downcase.capitalize }}
    {{ 'Hello world!'.truncate 5, '...' }}
    {{ 'Hello world!'.truncate_words 1 }}

### Integer

Integers support a literal notation using one or more digits. Integers are considered false when they are zero and true when they are not. Integers support many methods and many operators (through methods), an overview can be found in [objects/fixnum.rb](https://github.com/stefankroes/scribble/blob/master/lib/scribble/objects/fixnum.rb). Additionally, integers support the times method for repeating a block of content multiple times. Times needs to be implemented as its own class because it takes a block.

    {{ if foo }}
      Integer foo: {{ foo }}
    {{ else }}
      The integer foo is zero!
    {{ end }}

    {{ (-5 + 3) * 5 / 3 }}
    {{ 5.negative }}
    {{ -3.abs }}
    {{ 4.even }}
    {{ 4.odd }}
    {{ 4.times }}Hi! {{ end }}

### Boolean

Booleans support a literal notation using either the keyword true or the keyword false. Booleans support a subset of operators and associated methods, an overview can be found in  [objects/boolean.rb](https://github.com/stefankroes/scribble/blob/master/lib/scribble/objects/boolean.rb).

    {{ true | false & 'foo' }}
    {{ !true }}
    {{ true != 3 }}

### Nil

Nil does not support a literal notation but it can be returned by methods. It is always considered to be false. It implements the same methods as false, an overview can be found in [objects/nil.rb](https://github.com/stefankroes/scribble/blob/master/lib/scribble/objects/nil.rb).

### Global methods

Scribble supports the global `if`, `partial`, and `layout` methods. The if method was shown in several previous examples. The `partial` and `layout` methods are similar in that they load a partial through the loader and render it (converting between any format disparities). The difference is that layout takes a block of content to which the partial can yield using the `content` method.

    # Partial template (loaded by loader as 'foo')

    Hello from the partial!

    # Layout template (loaded by loader as 'bar')

    <div style="color=red;">{{ content }}</div>

    # Template

    {{ partial 'foo' }}

    {{ layout 'foo' }}I will be in red!{{ end }}

## Extending the Scribble language

The Scribble language can be extended by inserting new methods into the registry. The registry keeps track of methods and their properties:

* The method name
* The receiver class/type
* The argument signature (number of arguments and their types)

Any Ruby class can also be a Scribble type as long as methods are defined on it.

### Introducing a new type

In order to add everything to the registry that will make a Ruby class well behaved as a Scribble type, use Scribble::Registry.for and define its name, cast methods and regular methods as shown below. After that you can just pass the Ruby object along to your template using variables.

``` ruby
Scribble::Registry.for User do
  name 'user'

  to_boolean { true }
  to_string  { "user: #{name}" }

  # Logical operators
  method :or,  Object, cast: 'to_boolean'
  method :and, Object, cast: 'to_boolean'

  # Equality
  method :equals,  User, as: '=='
  method :differs, User, as: '!='
  method :equals,  Object, returns: false
  method :differs, Object, returns: true

  # Attributes
  method :name
  method :email

  method :first_name, to: -> { self.name.split(/\s/).first }
end
```

In the example above the call to `name` describes how the class `User` should be called in error messages and such. The next two lines describe how it should be cast to either a boolean (when used in an `if` statement for example) or a string (when it is rendered to the template). Then a bunch of methods are defined using different keywords.

* The `cast` keyword tells Scribble to cast this `User` to a boolean first, then call the same method (`or` or `and`) on that boolean.
* The `as` keyword means the method is delegated to the Ruby implementation under a different name.
* The `returns` keyword specifies that the method should just always return the same value.
* The `to` keyword specifies a block to implement the method.
* When `method` is called without any keywords, it is delegated to the Ruby method with the same name.

In this case `equals` and `differs` are defined twice with a different signature. The first method with a matching signature will be called so you can use pattern matching when implementing methods. In this case `User` can be equal to another user (delegated to Ruby equality) but can never be equal to another object (always returns false).

### Introducing a complex method

Global methods and any methods taking a block should be implemented as a Ruby class that subclasses either Scribble::Method or Scribble::Block. The `if` method is shown below as an example. Some more examples can be found in the [methods folder](https://github.com/stefankroes/scribble/tree/master/lib/scribble/methods) of the project.

``` ruby
class If < Scribble::Block
  register :if, Object

  def if object
    @paths = []
    send :elsif, object

    render(nodes: @paths.map { |condition, nodes| nodes if condition }.compact.first || [])
  end

  method :elsif, Object, split: true

  def elsif object
    @paths.unshift [Registry.to_boolean(object), split_nodes]
  end

  method :else, split: true

  def else
    @paths.unshift [true, nodes]
  end
end
```

The first line of the class implementation registers this method with the registry. The two calls to the `method` method register methods (`elsif` and `else`) that will be available within the block passed to the `if` call. These are split methods, meaning they will split up the block when `split_nodes` is called. Lets examine what happens when the following code is evaluated.

    {{ if false }}
      Some text
    {{ elsif true }}
      Some more text
    {{ else }}
      Last bit of text
    {{ end }}

1. `if` is a block method so the block up to the `end` is assigned to it and the `elsif` and `else` methods are considered regular method calls by the parser.
2. `if` is called in Scribble which is delegated to the `if` method in Ruby
3. The `if` method initializes the path array and calls `elsif` (using `send` because `elsif` is a keyword)
4. `split_nodes` is called by `elsif` which skips over `Some text` and evaluates the Scribble `elsif` (the next split method)
5. `split_nodes` is called by `elsif` which skips over `Some more text` and evaluates the Scribble `else` (the next split method)
6. The implementation of `else` takes the rest of the nodes (`Last bit of text`) and inserts it into the array together with a `true` value.
7. The last call to `split_nodes` returns `Some more text` which is added to the beginning of the array, together with the argument to `elsif` cast to a boolean (`true`).
8. The first call to `split_nodes` returns `Some text` which is added to the beginning of the array, together with the argument to `if` cast to a boolean (`false`).
9. The `send :elsif` returns and it renders the first list of nodes with a positive condition (`Some more text`)

This might be hard to wrap your head around but once you do it is a clean and easy way to extend the language with new `if`-like constructs without touching the parser. For examples of this, check out [Sitebox.io forms](http://www.sitebox.io/articles/form-method) and [Sitebox.io columns](http://www.sitebox.io/articles/columns-method). Implementations of block methods that don't use split methods are much easier, lake a look at [the implementation](https://github.com/stefankroes/scribble/blob/master/lib/scribble/methods/times.rb) of the `times` method.

### Method implementation API

This sections describes the API you can use when implementing methods as classes (like the `if` method). Please read the previous section first to gain some context.

Method or instance variable           | Description
------------------------------------- | ---------------------------------------
`@receiver`                             | The object receiving the method call (object before the method invocation dot or left hand side of an operation)
`@call`                                 | The parse tree node of the method call
`@context`                              | The execution context (block) of the method call
`@context.variables`                    | The variables that are defined in that context (doesn't include variables of containing contexts)
`@context.set_variable name, value`     | Set a variable in the context (and nested contexts)
`@context.registers`                    | The registers passed to the render method
`@context.template`                     | The template or partial being rendered
`@context.format`                       | The format of the text nodes in the context (before conversion)
`@context.render_format`                | The target rendering format (after conversion)
`render`                                | (`Scribble::Block` only) Render the contents of the block (or specific nodes using the `nodes` keyword) to a string
`split_nodes`                           | (`Scribble::Block` only) Evaluate the next split method and return nodes that came before it
`nodes`                                 | (`Scribble::Block` only) Get all nodes not skipped over by calling `split_nodes`

All methods available on `@context` are also available directly when the method is a `Scribble::Block` as it is also a context. `@context` holds the context containing the block in case of a `Scribble::Block`.

### Method signatures

In previous sections you have seen some method signatures. Both the `method` and `register` methods seen above take zero or more arguments after the method name. These arguments are the method signature. Any options/named arguments passed (`cast`, `as`, etc.) are not part of the method signature. A method matches when arguments of the same classes (or subclasses) as those in the signature are passed. Signatures also support optional arguments and multiple arguments as explained below.

``` ruby
Scribble::Registry.for String do
  # method1 takes an integer and a required string
  method :method1, Fixnum, String

  # method2 takes an integer and zero or more strings
  method :method2, Fixnum, [String]

  # method3 takes an integer and up to one string (an optional string)
  method :method3, Fixnum, [String, 1]

  # method4 takes an integer, one to four strings and after that zero or more integers
  method :method4, Fixnum, String, [String, 3], [Fixnum]
end
```

## Why Scribble instead of Liquid?

While Liquid is fine for many use-cases, we decided to replace it on the [Sitebox.io](http://www.sitebox.io/) project for the following reasons:

* Liquid uses regular expressions for parsing and tends to ignore most runtime errors, we want to be a little more strict and present the user with helpful error messages that include line and column numbers
* We needed a template language that's able to convert between different formats when using partials (in particular between Markdown and HTML)
* While the Liquid syntax can be friendly to non-programmers, an object oriented expression based language is more powerful and expressive
* Liquid uses different syntax for blocks and inlining, we wanted a single syntax for both

## Future work

* Extend language with arrays and possibly hashes
* Extend language with more built-in methods like loops
* Setup continuous integration and coverage reports
* Write more documentation, in particular on error reporting

## Contributing

1. Fork it ( https://github.com/stefankroes/scribble/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Origin, License, Copyright

Released under the [MIT license](https://github.com/stefankroes/scribble/blob/master/LICENSE.txt)

Scribble was developed by Stefan Kroes at [Lab 01](http://www.lab01.nl/) (Dutch website, available for hire ;-) as a part of [Sitebox.io](http://www.sitebox.io/) (Service that lets you create/edit a website using files in your Dropbox).

Copyright © 2014 Stefan Kroes
