# Test mighty component

R6 class for unit testing a mighty component with code coverage
tracking. Runs component code in an isolated R session and tracks which
lines are executed during testing.

## Details

Use
[`get_test_component()`](https://novonordisk-opensource.github.io/mighty.component/reference/get_test_component.md)
to create instances for testing. The test workflow is:

1.  Create test component with
    [`get_test_component()`](https://novonordisk-opensource.github.io/mighty.component/reference/get_test_component.md)

2.  Assign input data with `$assign()`

3.  Execute and track coverage with `$eval()`

4.  Retrieve results with `$get()`

5.  Test results with `expect_*()` functions from `{testthat}` as usual

Coverage is automatically checked at test teardown via
`$check_coverage()`.

## Super classes

[`mighty.component::mighty_component`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_component.md)
-\>
[`mighty.component::mighty_component_rendered`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_component_rendered.md)
-\> `mighty_component_test`

## Active bindings

- `percent_coverage`:

  `numeric` Percentage of lines covered (0-100).

- `line_coverage`:

  `data.frame` with columns `line` and `value` showing execution count
  per line.

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

Assign a variable in the isolated test session.

#### Usage

    mighty_component_test$assign(x, value)

#### Arguments

- `x`:

  `character` Name of the variable to assign.

- `value`:

  Value to assign to the variable.

#### Returns

`self` invisibly, for method chaining.

------------------------------------------------------------------------

### Method [`get()`](https://rdrr.io/r/base/get.html)

Retrieve a variable from the isolated test session.

#### Usage

    mighty_component_test$get(x)

#### Arguments

- `x`:

  `character` Name of the variable to retrieve.

#### Returns

The value of the variable.

------------------------------------------------------------------------

### Method [`ls()`](https://rdrr.io/r/base/ls.html)

List all variables in the isolated test session.

#### Usage

    mighty_component_test$ls()

#### Returns

`character` vector of variable names.

------------------------------------------------------------------------

### Method [`eval()`](https://rdrr.io/r/base/eval.html)

Execute the component code and update coverage tracking.

#### Usage

    mighty_component_test$eval()

#### Returns

`self` invisibly, for method chaining.

------------------------------------------------------------------------

### Method `check_coverage()`

Check that all lines in the component were executed at least once.
Throws an error if any lines have zero coverage.

#### Usage

    mighty_component_test$check_coverage()

#### Returns

`self` invisibly if all lines are covered.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    mighty_component_test$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
