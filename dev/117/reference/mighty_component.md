# Component class

R6 class for a component.

A component is a code template. Its code takes an input data set and
returns a modified version with new or changed columns or rows.
Components are documented with roxygen-like tags.

Use
[`get_component()`](https://novonordisk-opensource.github.io/mighty.component/reference/get_component.md)
to create a component from a file or repo.

## Details

### Templates

A template starts with tags in roxygen comments (`#'`). All lines below
the `@code` tag are the R code.

Templates use [Mustache](https://mustache.github.io/mustache.5.html)
placeholders. `$render()` fills them in with
[`whisker::whisker.render()`](https://rdrr.io/pkg/whisker/man/whisker.render.html).

- `{{{name}}}` inserts the value of parameter `name`. Always use triple
  braces. Double braces (`{{name}}`) HTML-escape the value, e.g. `a<b`
  becomes `a&lt;b`.

- `{{#name}}...{{/name}}` repeats the enclosed text for each element of
  the vector `name`. Use `{{{.}}}` to insert the current element.

### Tags

A tag continues until the next tag. Required tags must appear exactly
once.

|  |  |  |  |
|----|----|----|----|
| Tag | Required | Description | Example |
| `@title` | Yes | Title of the component. | `@title Double a column` |
| `@description` | Yes | Description of the component. | `@description Creates a new column.` |
| `@param` | No | Name, then description. One per placeholder. | `` @param domain `character` Name of the domain `` |
| `@type` | Yes | Component type. See *Types* below. | `@type column` |
| `@origin` | Yes | CDISC origin. See allowed values below. | `@origin Derived` |
| `@method` | Yes | Free-text method description for define.xml. | `@method Two times the input column` |
| `@depends` | No | Input domain, then column. Repeat for each. | `@depends {{{domain}}} USUBJID` |
| `@outputs` | No | Column created. Repeat for each. | `@outputs {{{output}}}` |
| `@code` | Yes | Last tag. All lines below are the code. | `@code` |

`@origin` must be one of `Assigned`, `Collected`, `Derived`,
`Not Available`, `Other`, `Predecessor`, `Protocol`.

`@depends` is split at the first space into domain and column. Do not
use spaces inside its placeholders, e.g. use `{{{domain}}}`, not
`{{{ domain }}}`.

### Types

- `column`: Adds or modifies columns. The row count is unchanged.

- `row`: Adds, removes or modifies rows.

- `parameter`: Derives a new `PARAMCD` (BDS parameter).

- `internal`: Helper step with no define.xml output.

### Conventions

1.  The input data set is `{{{domain}}}`.

2.  The code assigns the result back to `{{{domain}}}`.

3.  Every placeholder is declared with `@param`.

4.  Functions are called with explicit namespaces, e.g.
    [`dplyr::mutate()`](https://dplyr.tidyverse.org/reference/mutate.html).

5.  Joins specify `by`. This is enforced when rendering.

### Validation

When a component is rendered, the code is parsed and must be valid R.
Joins from dplyr, tidylog and dbplyr without a `by` argument raise an
error. Column existence is not checked.

### Example

This template creates a new column `output` as two times the existing
column `input`:

    #' @title Double a column
    #' @description
    #' Creates a new column as two times an existing column.
    #'
    #' @param domain `character` Name of the domain
    #' @param output `character` Name of the new column
    #' @param input `character` Name of the existing column
    #' @type column
    #' @origin Derived
    #' @method Two times the input column
    #' @depends {{{domain}}} {{{input}}}
    #' @outputs {{{output}}}
    #' @code
    {{{domain}}} <- {{{domain}}} |>
      dplyr::mutate(
        {{{output}}} = 2 * {{{input}}}
      )

Rendered with `domain = "ADSL"`, `output = "A"` and `input = "B"`, the
code (`$code`) is:

    ADSL <- ADSL |>
      dplyr::mutate(
        A = 2 * B
      )

The tags are rendered too, e.g. `$depends` has domain `ADSL` and column
`B`.

## See also

[`get_component()`](https://novonordisk-opensource.github.io/mighty.component/reference/get_component.md),
[mighty_component_rendered](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_component_rendered.md)

## Active bindings

- `id`:

  `character(1)` Component name without file extension.

- `title`:

  `character(1)` Title of the component.

- `description`:

  `character(1)` Description of the component.

- `code`:

  `character` Lines below `@code`.

- `template`:

  `character` Full template.

- `type`:

  `character(1)` Component type. One of `column`, `row`, `parameter`,
  `internal`.

- `origin`:

  `character(1)` CDISC origin. One of `Assigned`, `Collected`,
  `Derived`, `Not Available`, `Other`, `Predecessor`, `Protocol`.

- `method`:

  `character(1)` Method description for define.xml.

- `depends`:

  `data.frame` with columns `domain` and `column`.

- `outputs`:

  `character` Columns created by the component.

- `params`:

  `data.frame` with columns `name` and `description`.

## Methods

### Public methods

- [`mighty_component$new()`](#method-mighty_component-initialize)

- [`mighty_component$print()`](#method-mighty_component-print)

- [`mighty_component$render()`](#method-mighty_component-render)

- [`mighty_component$document()`](#method-mighty_component-document)

- [`mighty_component$clone()`](#method-mighty_component-clone)

------------------------------------------------------------------------

### `mighty_component$new()`

Create a component from a template.

#### Usage

    mighty_component$new(template, id)

#### Arguments

- `template`:

  `character` Template, one element per line. See Details.

- `id`:

  `character(1)` Component ID.

------------------------------------------------------------------------

### `mighty_component$print()`

Print the component.

#### Usage

    mighty_component$print()

#### Returns

(`invisible`) self

------------------------------------------------------------------------

### `mighty_component$render()`

Render the component with
[`whisker::whisker.render()`](https://rdrr.io/pkg/whisker/man/whisker.render.html).

#### Usage

    mighty_component$render(...)

#### Arguments

- `...`:

  Named parameters used to render the template. Supply one for each
  `@param` tag and no others.

  For `@type row` components, `domain` can be a subset marker:
  `".mighty_subset(<domain>, '<subset>')"`, where `<subset>` is an R
  expression in a string, e.g.
  `domain = ".mighty_subset(ADLB, 'PARAMCD == \"ALB\"')"`. The code then
  only processes the rows where `<subset>` is `TRUE`. Other rows are
  kept unchanged. The marker is not allowed for other parameters or
  types.

#### Returns

Object of class
[mighty_component_rendered](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_component_rendered.md)

------------------------------------------------------------------------

### `mighty_component$document()`

Create documentation in markdown format. Requires the knitr package.

#### Usage

    mighty_component$document()

#### Returns

(`invisible`) `character(1)` markdown documentation, also printed to the
console.

------------------------------------------------------------------------

### `mighty_component$clone()`

The objects of this class are cloneable with this method.

#### Usage

    mighty_component$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
