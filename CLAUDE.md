# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Package Overview

`mighty.component` is an R package providing standard component classes for ADaM (Analysis Data Model) generation within the mighty framework. Components are reusable, templated R code blocks that perform specific data transformations for clinical trial analysis.

## Development Commands

### Testing
```r
# Run all tests
devtools::test()

# Run specific test file
devtools::test_active_file()
testthat::test_file("tests/testthat/test-component.R")

# Run tests with coverage
covr::package_coverage()
```

### Building and Checking
```r
# Install development version
devtools::install()

# Check package (R CMD check)
devtools::check()

# Build documentation
devtools::document()

# Build vignettes
devtools::build_vignettes()
```

### Linting
The project uses megalinter via GitHub Actions. Code should follow tidyverse style guide.

## Architecture

### Core R6 Classes

**`mighty_component`** (`R/mighty_component.R`)
- Unrendered component template with dynamic parameters
- Parses roxygen-like metadata tags (@title, @param, @type, @depends, @outputs)
- Uses Mustache templating for parameter substitution
- Method: `render(params)` returns `mighty_component_rendered`

**`mighty_component_rendered`** (`R/mighty_component_rendered.R`)
- Inherits from `mighty_component`
- Contains executable R code with all parameters substituted
- Key methods:
  - `stream(file)` - Write code to R script
  - `eval(envir)` - Execute code in environment
  - `test(expected)` - Test against expected output
  - `coverage()` - Calculate test coverage

**Relationship**: `mighty_component$render(params)` → `mighty_component_rendered`

### Component Types

Three validated component types (enforced in `R/utils-validation.R`):
- **predecessor**: Merges data from other datasets
- **derivation**: Derives new columns from existing data
- **row**: Adds or filters rows

### Standard Components Library

Pre-built validated components in `inst/components/`:
- `ady.mustache` - Analysis relative day derivations
- `aendt.mustache` - Analysis end date derivations
- `assign.mustache` - Simple variable assignments
- `astdt.mustache` - Analysis start date derivations
- `predecessor.mustache` - Merge columns from predecessor datasets
- `supp_sdtm.mustache` - Add supplementary variables from SDTM
- `trtemfl.mustache` - Treatment emergent flag derivations

Access via `get_standard(name)` or `list_standards()`.

### Component File Structure

Standard mustache component template:
```r
#' @title [Component name]
#' @description [What it does]
#' @param [parameter] [description]
#' @type [predecessor|derivation|row]
#' @depends [dataset] [column]
#' @outputs [created_column]
#' @code
[R code with {{mustache}} placeholders]
```

**Key conventions**:
- Input dataset is always referenced as `.self` in templates
- Mustache syntax: `{{ variable_name }}` for dynamic parameters
- Custom `.R` files (non-templated) must NOT contain `@param` tags or `{{}}` patterns

### Validation System

**Architecture**: `R/validate_component_code.R` orchestrates pluggable validators that analyze component code AST via `xmlparsedata`.

**Current validators**:
- **Implicit Join Validator** (`R/validate_implicit_join.R`)
  - Enforces explicit `by` argument in dplyr joins
  - Checks: `left_join`, `right_join`, `inner_join`, `full_join`, `semi_join`, `anti_join`, `nest_join`
  - Validates joins from: `dplyr`, `tidylog`, `dbplyr` namespaces

**Adding new validators**: Create function accepting parsed XML, return violations list or NULL.

### Component Retrieval Functions

**Location**: `R/component.R` and `R/standard.R`

- `get_component(component)` - Unified retrieval (auto-detects standard or custom)
- `get_standard(standard)` - Get standard template by name
- `get_rendered_component(component, params)` - One-step retrieval and rendering
- `get_rendered_standard(standard, params)` - One-step standard retrieval and rendering

**File type handling**:
- No extension → Look for standard component
- `.mustache` → Parse as mustache template
- `.R` → Custom R component (validated for no parameters)

## Testing

Uses `testthat` (edition 3). Test files are in `tests/testthat/`:
- `test-component.R` - Component retrieval
- `test-mighty_component.R` - Template class
- `test-mighty_component_rendered.R` - Rendered class
- `test-standard.R` - Standard components
- `test-validate_*.R` - Validator tests
- `test-custom_r.R` - Custom R components
- `test-components.R` - Test helper components

Test components in `tests/testthat/_components/` are used for validation testing.

Helper functions in `tests/testthat/helper-R6-methods.R` provide R6 method testing utilities.

## Key Workflows

### Using a standard component
```r
component <- get_standard("ady")
rendered <- component$render(domain = "advs", variable = "ASTDY", date = "ASTDT")
rendered$stream("output.R")
rendered$eval(envir = my_env)
```

### Creating custom component
```r
# Mustache template
component <- get_component("path/to/component.mustache")

# Plain R file (no parameters)
component <- get_component("path/to/component.R")
```

### Discovery
```r
list_standards()                    # Character vector
list_standards(as = "list")         # Full metadata
list_standards(as = "tibble")       # Tidy tibble
```

## CI/CD

GitHub Actions workflows (`.github/workflows/check_and_co.yaml`) run on push/PR:
- R CMD check (current and NN R versions)
- Test coverage via codecov
- pkgdown site generation
- megalinter
