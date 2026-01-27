# Mighty standard component

Class for a generic mighty standard component.

In the mighty framework, a "component" is a code template that processes
input data and returns a modified version with new columns or rows.
Standard components share a common structure and roxygen-like
documentation pattern, facilitating their use inside mighty.

## Details

Templates are `character` vectors of R code that are interpreted.
Dynamic use of variables etc. are supported using the
[mustache](https://mustache.github.io) framework. Dynamic parameters are
specified using `{{ variable_name }}`.

### Documentation

A template is required to be documented with the following tags similar
to when documenting functions using roxygen2:

|                |                                                      |                           |
|----------------|------------------------------------------------------|---------------------------|
| Tag            | Description                                          | Example                   |
| `@title`       | Title of the component                               | `@title My component`     |
| `@description` | Description of the component                         | `@description text text`  |
| `@param`       | Specifies input used to render the component         | `@param variable new var` |
| `@type`        | Specifies type: predecessor, derivation, row         | `@type derivation`        |
| `@depends`     | Required input variable (repeat if several)          | `@depends .self USUBJID`  |
| `@outputs`     | Variables created (repeat if several)                | `@outputs NEWVAR`         |
| `@code`        | Everything under this tag defines the component code | `@code`                   |

### Conventions

A template for a standard components follow these conventions:

1.  The input data set is always called `.self`.

2.  Additional parameters used to render the template into R code are
    documented with the `@param` tag.

3.  The template ends with creating a modified version of `.self`.

4.  Template documented with the roxygen-like tags above

### Example

Below is an example of a mighty component template that creates a new
dynamic variable `variable` as twice the value of the dynamic input `x`,
that should already by in the input data set `.self`.

    #' @title Title for my component
    #' @description
    #' A more in depth description of what is being done
    #'
    #' @param variable dynamic output if applicable
    #' @param x some other input to the component
    #' @type derivation
    #' @depends .self {{ x }}
    #' @outputs {{ variable }}
    #' @code
    .self <- .self |>
      dplyr::mutate(
        {{ variable }} = 2 * {{ x }}
      )

When rendered with parameters `variable = "A"` and `x = "B"` the
rendered code used in mighty becomes:

    .self <- .self |>
      dplyr::mutate(
        A = 2 * B
      )

## See also

[`get_standard()`](https://novonordisk-opensource.github.io/mighty.component/reference/get_standard.md),
[mighty_component_rendered](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_component_rendered.md)

## Active bindings

- `id`:

  Component ID

- `title`:

  Title for the component.

- `description`:

  Description of the component.

- `code`:

  The code block of the component.

- `template`:

  The complete template.

- `type`:

  The type of the component. Can be one of predecessor, derivation, row.

- `depends`:

  Data.frame listing all the components dependencies.

- `outputs`:

  List of the new columns created by the component.

- `params`:

  Data.frame listing parameters that need to be supplied when rendering
  the component.

## Methods

### Public methods

- [`mighty_component$new()`](#method-mighty_component-new)

- [`mighty_component$print()`](#method-mighty_component-print)

- [`mighty_component$render()`](#method-mighty_component-render)

- [`mighty_component$document()`](#method-mighty_component-document)

- [`mighty_component$clone()`](#method-mighty_component-clone)

------------------------------------------------------------------------

### Method `new()`

Create standard component from template.

#### Usage

    mighty_component$new(template, id)

#### Arguments

- `template`:

  `character` template code. See details for how to format.

- `id`:

  `character` ID of the component. Either name of standard or path to
  local.

------------------------------------------------------------------------

### Method [`print()`](https://rdrr.io/r/base/print.html)

Print method displaying the component information.

#### Usage

    mighty_component$print()

#### Returns

(`invisible`) self

------------------------------------------------------------------------

### Method `render()`

Render component with supplied values. Supports mustache templates and
uses
[`whisker::whisker.render()`](https://rdrr.io/pkg/whisker/man/whisker.render.html).

#### Usage

    mighty_component$render(...)

#### Arguments

- `...`:

  Parameters used to render the template. Must be named, and depends on
  the template.

#### Returns

Object of class
[mighty_component_rendered](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_component_rendered.md)

------------------------------------------------------------------------

### Method `document()`

Create standard documentation in markdown format.

#### Usage

    mighty_component$document()

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    mighty_component$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
