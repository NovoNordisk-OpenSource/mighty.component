# Rendered mighty standard component

Class for a rendered mighty standard component.

Once rendered a component can be used to:

- Stream into an R script

- Evaluate the generated code in an environment

- Test code against expected output

- Calculate test coverage

## See also

[`get_rendered_standard()`](https://novonordisk-opensource.github.io/mighty.component/reference/get_standard.md)

## Super class

[`mighty.component::mighty_component`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_component.md)
-\> `mighty_component_rendered`

## Methods

### Public methods

- [`mighty_component_rendered$new()`](#method-mighty_component_rendered-new)

- [`mighty_component_rendered$print()`](#method-mighty_component_rendered-print)

- [`mighty_component_rendered$stream()`](#method-mighty_component_rendered-stream)

- [`mighty_component_rendered$eval()`](#method-mighty_component_rendered-eval)

- [`mighty_component_rendered$test()`](#method-mighty_component_rendered-test)

- [`mighty_component_rendered$test_coverage()`](#method-mighty_component_rendered-test_coverage)

- [`mighty_component_rendered$clone()`](#method-mighty_component_rendered-clone)

Inherited methods

- [`mighty.component::mighty_component$document()`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_component.html#method-document)
- [`mighty.component::mighty_component$render()`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_component.html#method-render)

------------------------------------------------------------------------

### Method `new()`

Create standard component from rendered template.

#### Usage

    mighty_component_rendered$new(template, id)

#### Arguments

- `template`:

  `character` Rendered template such as output from
  `mighty_component$render()`.

- `id`:

  `character` ID of the component. Either name of standard or path to
  local.

------------------------------------------------------------------------

### Method [`print()`](https://rdrr.io/r/base/print.html)

Print rendered component

#### Usage

    mighty_component_rendered$print()

#### Returns

(`invisible`) self

------------------------------------------------------------------------

### Method `stream()`

Stream rendered code into a script (appended)

#### Usage

    mighty_component_rendered$stream(path)

#### Arguments

- `path`:

  `character(1)` path to the R script to stream code into.

------------------------------------------------------------------------

### Method [`eval()`](https://rdrr.io/r/base/eval.html)

Evaluate code in a specified environment.

#### Usage

    mighty_component_rendered$eval(envir = parent.frame())

#### Arguments

- `envir`:

  Environment to evaluate in. Parsed to
  [`eval()`](https://rdrr.io/r/base/eval.html). Defaults to using the
  current environment with
  [`parent.frame()`](https://rdrr.io/r/base/sys.parent.html).

------------------------------------------------------------------------

### Method `test()`

Test component against expected output.

#### Usage

    mighty_component_rendered$test(
      expected,
      value = "domain",
      envir = parent.frame()
    )

#### Arguments

- `expected`:

  The expected output in `value` after evaluation

- `value`:

  Name of the object used to compare against after evaluating the
  component. Defaults to `"domain"`.

- `envir`:

  Parent environment to use for evaluation of test code. Defaults to
  using the current environment with
  [`parent.frame()`](https://rdrr.io/r/base/sys.parent.html).

------------------------------------------------------------------------

### Method `test_coverage()`

Calculate test coverage for already run tests

#### Usage

    mighty_component_rendered$test_coverage()

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    mighty_component_rendered$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
