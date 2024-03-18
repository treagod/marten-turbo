<h1>
  <img src="./logo.svg" height="32" width="32" alt="Marten Turbo Logo">
  <span>Marten Turbo</span>
</h1>

## Handlers

Marten Turbo provides an extension to the generic Marten handlers. For example to create a record the `MartenTurbo::Handlers::RecordCreate` is used:

```crystal
class MyTurboForm < MartenTurbo::Handlers::RecordCreate
  model MyModel
  schema MyFormSchema
  template_name "my_form.html"
  success_route_name "my_form_success"
  turbo_stream_template "my_form.turbo_stream.html" 
end
```

Notice how we use `MartenTurbo::` instead of `Marten::`. Also the `#turbo_stream_template` class method gives you the option to define a turbo stream template which is
rendered instead of the normal template if a Turbo application is detected.
