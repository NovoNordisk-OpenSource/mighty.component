# Test mighty component

Class for a testing a mighty component.

## Super classes

[`mighty.component::mighty_component`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_component.md)
-\>
[`mighty.component::mighty_component_rendered`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_component_rendered.md)
-\> `mighty_component_test`

## Active bindings

- `coverage`:

  description

## Methods

### Public methods

- [`mighty_component_test$new()`](#method-mighty_component_test-new)

- [`mighty_component_test$print()`](#method-mighty_component_test-print)

- [`mighty_component_test$assign()`](#method-mighty_component_test-assign)

- [`mighty_component_test$get()`](#method-mighty_component_test-get)

- [`mighty_component_test$ls()`](#method-mighty_component_test-ls)

- [`mighty_component_test$eval()`](#method-mighty_component_test-eval)

- [`mighty_component_test$check_coverage()`](#method-mighty_component_test-check_coverage)

- [`mighty_component_test$clone()`](#method-mighty_component_test-clone)

Inherited methods

- [`mighty.component::mighty_component$document()`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_component.html#method-document)
- [`mighty.component::mighty_component$render()`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_component.html#method-render)
- [`mighty.component::mighty_component_rendered$stream()`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_component_rendered.html#method-stream)

------------------------------------------------------------------------

### Method `new()`

Create test component from rendered template.

#### Usage

    mighty_component_test$new(template, id)

#### Arguments

- `template`:

  `character` Rendered template such as output from
  `mighty_component$render()`.

- `id`:

  `character` ID of the component. Either name of standard or path to
  local.

------------------------------------------------------------------------

### Method [`print()`](https://rdrr.io/r/base/print.html)

Print method showing component and test coverage

#### Usage

    mighty_component_test$print()

------------------------------------------------------------------------

### Method [`assign()`](https://rdrr.io/r/base/assign.html)

Assign

#### Usage

    mighty_component_test$assign(x, value)

------------------------------------------------------------------------

### Method [`get()`](https://rdrr.io/r/base/get.html)

#### Usage

    mighty_component_test$get(x)

------------------------------------------------------------------------

### Method [`ls()`](https://rdrr.io/r/base/ls.html)

#### Usage

    mighty_component_test$ls()

------------------------------------------------------------------------

### Method [`eval()`](https://rdrr.io/r/base/eval.html)

Test component against expected output.

#### Usage

    mighty_component_test$eval()

------------------------------------------------------------------------

### Method `check_coverage()`

Check that code coverage is 100%

#### Usage

    mighty_component_test$check_coverage()

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    mighty_component_test$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
