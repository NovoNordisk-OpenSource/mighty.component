# Test mighty component class

R6 class for unit testing a component with code coverage tracking. The
code runs in a separate R session, and the lines executed are counted.

## Details

Use
[`get_test_component()`](https://novonordisk-opensource.github.io/mighty.component/reference/get_test_component.md)
to create a test component. The workflow is:

1.  Create the test component with
    [`get_test_component()`](https://novonordisk-opensource.github.io/mighty.component/reference/get_test_component.md).

2.  Assign input data with `$assign()`.

3.  Run the code and update coverage with `$eval()`.

4.  Retrieve results with `$get()`.

5.  Test the results with testthat `expect_*()` functions.

6.  Close the session with `$close()`.

By default,
[`get_test_component()`](https://novonordisk-opensource.github.io/mighty.component/reference/get_test_component.md)
checks coverage with `$check_coverage()` when the test ends. Coverage is
kept in the current R session, so it can still be checked after
`$close()`.

The code runs inside a function, with `<-` replaced by `<<-`, so
assignments are made in the session's global environment.

## See also

[`get_test_component()`](https://novonordisk-opensource.github.io/mighty.component/reference/get_test_component.md)

## Super classes

[`mighty_component`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_component.md)
-\>
[`mighty_component_rendered`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_component_rendered.md)
-\> `mighty_component_test`

## Active bindings

- `percent_coverage`:

  `numeric(1)` Percentage of lines covered (0-100).

- `line_coverage`:

  `data.frame` with columns `line` and `value` (number of times the line
  has run).

## Methods

### Public methods

- [`mighty_component_test$new()`](#method-mighty_component_test-initialize)

- [`mighty_component_test$print()`](#method-mighty_component_test-print)

- [`mighty_component_test$assign()`](#method-mighty_component_test-assign)

- [`mighty_component_test$get()`](#method-mighty_component_test-get)

- [`mighty_component_test$ls()`](#method-mighty_component_test-ls)

- [`mighty_component_test$eval()`](#method-mighty_component_test-eval)

- [`mighty_component_test$check_coverage()`](#method-mighty_component_test-check_coverage)

- [`mighty_component_test$close()`](#method-mighty_component_test-close)

- [`mighty_component_test$clone()`](#method-mighty_component_test-clone)

Inherited methods

- [`mighty_component$document()`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_component.html#method-document)
- [`mighty_component$render()`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_component.html#method-render)
- [`mighty_component_rendered$stream()`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_component_rendered.html#method-stream)

------------------------------------------------------------------------

### `mighty_component_test$new()`

Create a test component from a rendered template. Starts a new R
session. Requires the callr and covr packages.

#### Usage

    mighty_component_test$new(template, id)

#### Arguments

- `template`:

  `character` Rendered template, one element per line.

- `id`:

  `character(1)` Component ID.

------------------------------------------------------------------------

### `mighty_component_test$print()`

Print the test component with its code coverage.

#### Usage

    mighty_component_test$print()

#### Returns

(`invisible`) self

------------------------------------------------------------------------

### `mighty_component_test$assign()`

Assign a variable in the test session.

#### Usage

    mighty_component_test$assign(x, value)

#### Arguments

- `x`:

  `character(1)` Variable name.

- `value`:

  Value to assign.

#### Returns

(`invisible`) self

------------------------------------------------------------------------

### `mighty_component_test$get()`

Get a variable from the test session.

#### Usage

    mighty_component_test$get(x)

#### Arguments

- `x`:

  `character(1)` Variable name.

#### Returns

Value of the variable.

------------------------------------------------------------------------

### `mighty_component_test$ls()`

List the variables in the test session.

#### Usage

    mighty_component_test$ls()

#### Returns

`character` Variable names.

------------------------------------------------------------------------

### `mighty_component_test$eval()`

Run the code in the test session and update the coverage.

#### Usage

    mighty_component_test$eval()

#### Returns

(`invisible`) self

------------------------------------------------------------------------

### `mighty_component_test$check_coverage()`

Check that every line of the code has run at least once. Raises an error
otherwise.

#### Usage

    mighty_component_test$check_coverage()

#### Returns

(`invisible`) self

------------------------------------------------------------------------

### `mighty_component_test$close()`

Close the test session. Called automatically when the object is garbage
collected.

#### Usage

    mighty_component_test$close()

#### Returns

(`invisible`) self

------------------------------------------------------------------------

### `mighty_component_test$clone()`

The objects of this class are cloneable with this method.

#### Usage

    mighty_component_test$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
path <- system.file("examples", "ady.mustache", package = "mighty.component")
x <- get_test_component(
  component = path,
  params = list(domain = "adae", variable = "ADY", date = "ADT"),
  check_coverage = FALSE
)
#> → Found "ady.mustache" in "local::/home/runner/work/_temp/Library/mighty.component/examples"
x$percent_coverage
#> [1] 0

x$assign(
  "adae",
  data.frame(TRTSDT = as.Date("2024-01-01"), ADT = as.Date("2024-01-05"))
)
x$eval()
x$ls()
#> [1] "adae"
x$get("adae")$ADY
#> [1] 5
x$percent_coverage
#> [1] 100
x$check_coverage()
x$close()
```
