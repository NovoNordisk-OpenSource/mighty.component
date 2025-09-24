# mighty_component

    Code
      test_component
    Message
      <mighty_component/R6>
      test: This is a test component used for unit testing
      Type: column
      Parameters:
      * x1: First input
      * x2: Second input
      Depends:
      * .self.A
      * Y.B
      Outputs:
      * NEWVAR

---

    Code
      test_component$document()
    Output
      ## test: My test component
      *type: column*
      
      This is a test component used for unit testing
      
      ### Parameters
      
      |name |description  |
      |:----|:------------|
      |x1   |First input  |
      |x2   |Second input |
      
      ### Depends
      
      |domain |column |
      |:------|:------|
      |.self  |A      |
      |Y      |B      |
      
      ### Outputs
      
      * NEWVAR
      
      ### Code
      
      ```r
      .self$NEWVAR <- {{ x1 }} * Y$B + .self$A - {{ x2 }}
      ``` 
      

---

    Code
      test_component_rendered
    Message
      <mighty_component_rendered/mighty_component/R6>
      test: This is a test component used for unit testing
      Type: column
      Depends:
      * .self.A
      * Y.B
      Outputs:
      * NEWVAR
      Code:
      .self$NEWVAR <- 1 * Y$B + .self$A - 2

# print

    Code
      expect_s3_class(expect_invisible(print(get_component(test_path("_components",
        "test_component.mustache")))), "mighty_component")
    Message
      <mighty_component/R6>
      _components/test_component.mustache: This is a test component used for unit
      testing
      Type: column
      Parameters:
      * x1: First input
      * x2: Second input
      Depends:
      * .self.A
      * Y.B
      Outputs:
      * NEWVAR

# create_bullets

    Code
      create_bullets(header = "mytest", bullets = c("first item", "second item"))
    Message
      mytest
      * first item
      * second item

# document

    Code
      eval_method(get_component(test_path("_components", "test_component.mustache")),
      "document")
    Output
      ## _components/test_component.mustache: My test component
      *type: column*
      
      This is a test component used for unit testing
      
      ### Parameters
      
      |name |description  |
      |:----|:------------|
      |x1   |First input  |
      |x2   |Second input |
      
      ### Depends
      
      |domain |column |
      |:------|:------|
      |.self  |A      |
      |Y      |B      |
      
      ### Outputs
      
      * NEWVAR
      
      ### Code
      
      ```r
      .self$NEWVAR <- {{ x1 }} * Y$B + .self$A - {{ x2 }}
      ``` 
      

