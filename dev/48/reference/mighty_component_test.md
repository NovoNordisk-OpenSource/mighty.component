# Rendered mighty standard component

Class for a rendered mighty standard component.

Once rendered a component can be used to:

- Test code against expected output

- Calculate test coverage

## See also

[`get_rendered_standard()`](https://novonordisk-opensource.github.io/mighty.component/reference/get_standard.md)

## Active bindings

- `component`:

  The
  [mighty_component_rendered](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_component_rendered.md)
  object being tested.

- `test_coverage`:

  Test coverage percentage

- `missing_lines`:

  Index of lines uncovered by unit tests

- `covered_lines`:

  Index of lines covered by unit tests

## Methods

### Public methods

- [`mighty_component_test$new()`](#method-mighty_component_test-new)

- [`mighty_component_test$print()`](#method-mighty_component_test-print)

- [`mighty_component_test$eval()`](#method-mighty_component_test-eval)

- [`mighty_component_test$check_coverage()`](#method-mighty_component_test-check_coverage)

- [`mighty_component_test$clone()`](#method-mighty_component_test-clone)

------------------------------------------------------------------------

### Method `new()`

Create standard component from rendered template.

#### Usage

    mighty_component_test$new(component)

#### Arguments

- `component`:

  `character` Rendered template such as output from
  `mighty_component$render()`.

------------------------------------------------------------------------

### Method [`print()`](https://rdrr.io/r/base/print.html)

Print method showing test coverage

#### Usage

    mighty_component_test$print()

------------------------------------------------------------------------

### Method [`eval()`](https://rdrr.io/r/base/eval.html)

Test component against expected output.

#### Usage

    mighty_component_test$eval(input)

#### Arguments

- `input`:

  The input to use as `.self` for the code chunk

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
