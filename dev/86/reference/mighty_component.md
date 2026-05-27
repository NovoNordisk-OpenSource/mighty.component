# Mighty component

Class for a generic mighty component.

In the mighty framework, a "component" is a code template that processes
input data and returns a modified version with new columns or rows.
Mighty components share a common structure and roxygen-like
documentation pattern, facilitating their use inside mighty.

## Details

Templates are `character` vectors of R code that are interpreted.
Dynamic use of variables etc. are supported using the
[mustache](https://mustache.github.io) framework. Dynamic parameters are
specified using `{{ variable_name }}`.

### Documentation

A template is required to be documented with the following tags similar
to when documenting functions using roxygen2:

|  |  |  |
|----|----|----|
| Tag | Description | Example |
| `@title` | Title of the component | `@title My component` |
| `@description` | Description of the component | `@description text text` |
| `@param` | Specifies input used to render the component | `@param variable new var` |
| `@type` | Specifies type: column, row, parameter, internal | `@type column` |
| `@origin` | CDISC origin (optional) | `@origin Derived` |
| `@depends` | Required input variable (repeat if several) | `@depends {{ domain }} USUBJID` |
| `@outputs` | Variables created (repeat if several) | `@outputs NEWVAR` |
| `@code` | Everything under this tag defines the component code | `@code` |

### Conventions

A component template follows these conventions:

1.  The input data set is always called `{{ domain }}`.

2.  Additional parameters used to render the template into R code are
    documented with the `@param` tag.

3.  The template ends with creating a modified version of
    `{{ domain }}`.

4.  Template documented with the roxygen-like tags above

### Example

Below is an example of a mighty component template that creates a new
dynamic variable `variable` as twice the value of the dynamic input `x`,
that should already by in the input data set `{{ domain }}`.

    #' @title Title for my component
    #' @description
    #' A more in depth description of what is being done
    #'
    #' @param variable dynamic output if applicable
    #' @param x some other input to the component
    #' @type column
    #' @origin Derived
    #' @depends {{ domain }} {{ x }}
    #' @outputs {{ variable }}
    #' @code
    {{ domain }} <- {{ domain }} |>
      dplyr::mutate(
        {{ variable }} = 2 * {{ x }}
      )

When rendered with parameters `variable = "A"` and `x = "B"` the
rendered code used in mighty becomes:

    {{ domain }} <- {{ domain }} |>
      dplyr::mutate(
        A = 2 * B
      )

## See also

[`get_component()`](https://novonordisk-opensource.github.io/mighty.component/reference/get_component.md),
[mighty_component_rendered](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_component_rendered.md)

## Active bindings

- `id`:

  Component ID.

- `title`:

  Title for the component.

- `description`:

  Description of the component.

- `code`:

  The code block of the component.

- `template`:

  The complete template.

- `type`:

  The type of the component. Can be one of column, row, parameter,
  internal.

- `origin`:

  CDISC origin. One of Assigned, Collected, Derived, Not Available,
  Other, Predecessor, Protocol or `NULL`.

- `depends`:

  Data.frame listing all the components dependencies.

- `outputs`:

  List of the new columns created by the component.

- `params`:

  Data.frame listing parameters that need to be supplied when rendering
  the component.

## Methods

### Public methods

- [`mighty_component$new()`](#method-mighty_component-initialize)

- [`mighty_component$print()`](#method-mighty_component-print)

- [`mighty_component$render()`](#method-mighty_component-render)

- [`mighty_component$document()`](#method-mighty_component-document)

- [`mighty_component$clone()`](#method-mighty_component-clone)

------------------------------------------------------------------------

### `mighty_component$new()`

Create component from template.

#### Usage

    mighty_component$new(template, id)

#### Arguments

- `template`:

  `character` template code. See details for how to format.

- `id`:

  `character` ID of the component.

------------------------------------------------------------------------

### `mighty_component$print()`

Print method displaying the component information.

#### Usage

    mighty_component$print()

#### Returns

(`invisible`) self

------------------------------------------------------------------------

### `mighty_component$render()`

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

### `mighty_component$document()`

Create standard documentation in markdown format.

#### Usage

    mighty_component$document()

------------------------------------------------------------------------

### `mighty_component$clone()`

The objects of this class are cloneable with this method.

#### Usage

    mighty_component$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
