# Getting Started

This guide will walk you through building a simple example application that demonstrates the core features of Marten Turbo.

## Prerequisites

* Understanding of [Turbo](https://turbo.hotwired.dev/handbook/introduction) concepts.
* The Marten CLI installed (See [Installation Guide](./installation.md)).


## Starting a basic application

### Model setup

First we'll create a basic Marten Todo app. To quickly set this up we can leverage the Marten generators:

```bash
marten new project turbo-blog && cd turbo-blog
shards install
marten gen model Todo task:string done:boolean
marten gen schema TodoSchema task:string
```

Change following line in `src/models/todo.cr`:

```diff
- field :done, :bool
+ field :done, :bool, default: false
```

Now generate and execute the migrations:

```bash
marten genmigrations
marten migrate
```

### Routes & Handler Setup

First create following handlers:

```ruby
# src/handlers/todo_handler.cr
class TodosHandler < Marten::Handlers::RecordList
  template_name "todos/index.html"
  model Todo
  queryset Todo.order("-created_at")
end
```

```ruby
# src/handlers/todo_create_handler.cr
class TodoCreateHandler < Marten::Handlers::RecordCreate
  model Todo
  schema TodoSchema
  template_name "todos/create.html"
  success_route_name "todos:list"
end
```

```ruby
# src/handlers/todo_update_handler.cr
class TodoUpdateHandler < Marten::Handlers::RecordUpdate
  model Todo
  schema TodoSchema
  template_name "todos/update.html"
  success_route_name "todos:list"
end
```

```ruby
# src/handlers/todos_delete_handler.cr
class TodoDeleteHandler < Marten::Handlers::RecordDelete
  model Todo
  template_name "articles/delete.html"
  success_route_name "todos:list"
end
```

And add these handlers to a namespaced route inside your `config/routes.cr`:

```diff
# config/routes.cr
+ TODO_ROUTES =  Marten::Routing::Map.draw do
+   path "/", TodosHandler, name: "list"
+   path "/create", TodoCreateHandler, name: "create"
+   path "/update/<pk:int>", TodoUpdateHandler, name: "update"
+   path "/delete/<pk:int>", TodoDeleteHandler, name: "delete"
+ end

Marten.routes.draw do
+   path "/todos", TODO_ROUTES, name: "todos"
```

### Templates

To keep this guide short, just copy & paste following templates:

```html
{% extend "base.html" %}

{% block content %}
<h1>Todos</h1>

<div>
    <a href="{% url 'todos:create' %}" class="button">Create New Todo</a>
</div>

<div id="todos">
{% for todo in records %}
    <div class="todo card" style="display: flex; flex-direction: row; justify-content: space-between;align-items: center;">
        <div class="todo-title">{{ todo.task }}</div>
        <div class="todo-actions" style="display: flex; gap: 0.5rem;">
            <a href="{% url 'todos:update' pk: todo.pk %}" class="action action-edit"><i class="bi bi-pencil"></i></a>
            <form action="{% url 'todos:delete' pk: todo.pk %}" method="post">
                <input type="hidden" name="csrftoken" value="{% csrf_token %}" />
                <button class="action action-delete">
                    <i class="bi bi-trash3"></i>
                </button>
            </form>
        </div>
    </div>
{% endfor %}
</div>
{% endblock %}
```

```html
<!-- src/templates/todos/create.html -->
{% extend "base.html" %}

{% block content %}
<h1>Create Todo</h1>

<div id="todo">
    {% include "todos/todo_form.html" with button_label="Create Todo" %}
</div>
{% endblock %}
```

```html
{% extend "base.html" %}

{% block content %}
<h1>Update Todo</h1>

<div id="todo">
    {% include "todos/todo_form.html" with button_label="Update Todo" %}
</div>
{% endblock %}
```

```html
<form class="card" action="" method="post" style="margin: 0 auto;">
    <input type="hidden" name="csrftoken" value="{% csrf_token %}" />

    <div class="field{% if schema.task.errored? %} field-error{% endif %}">
        <label for="{{ schema.task.id }}">Title</label>
        <input type="text" id="{{ schema.task.id }}" name="{{ schema.task.id }}" value="{{ schema.task.value }}"
            autocomplete="off" required>
        {% for error in schema.task.errors %}<p class="input-error">{{ error.message }}</p>{% endfor %}
    </div>

    <div class="field-actions">
        <input class="button" type="submit" value="{{ button_label }}">
        <a href="{% url 'todos:list' %}" class="button inverse">Back to Todos</a>
    </div>
</form>
```

This will allow you to view all todos and to create or update a todo. For more information about templates [visit the official marten documentation](https://martenframework.com/docs/templates/introduction){:target="_blank"}.

## Add Turbo to your application

To add a touch of SPA feeling to the app we can leverage [Hotwire Turbo](https://turbo.hotwired.dev/){:target="_blank"}. Additionally to install the Marten Turbo library [follow the installation instructions](installation.md).

First you have to add the Marten Turbo library to your installed apps:

```diff
# src/project.cr
require "sqlite3"
+ require "marten_turbo"
```

```diff
# config/settings/base.cr
- config.installed_apps = [] of Marten::Apps::Config.class
+ config.installed_apps = [
+   MartenTurbo::App
+ ] of Marten::Apps::Config.class
```

Because Marten Turbo does include the Turbo JavaScript library you have to download the library, for example from (unpkg.com)[https://unpkg.com/browse/@hotwired/turbo@8.0.4/dist/] as refered from the official Turbo documentation. Save the esm library to `src/assets/js/turbo.js` and include it inside `src/templates/base.html`:

```diff
-  <link rel="stylesheet" type="text/css" href="{% asset 'css/app.css' %}"/>
+  <link rel="stylesheet" type="text/css" href="{% asset 'css/app.css' %}" data-turbolinks-track="reload" />

+  <script type="module" src="{% asset 'js/turbo.js' %}"></script>
  <title>{% block title %}turbo-blog{% endblock %}</title>
</head>
```

Notice we also added `data-turbolinks-track="reload"` to our CSS link, which ensures that `css/app.css` will be reloaded when necessary.


Now we have to extend our record handlers `TodoCreateHandler` and `TodoUpdateHandler`:

```diff
- class TodoCreateHandler < Marten::Handlers::RecordCreate
+ class TodoCreateHandler < MartenTurbo::Handlers::RecordCreate
  model Todo
  schema TodoSchema
  template_name "todos/create.html"
+ turbo_stream_name "todos/create.turbo_stream.html"
  success_route_name "todos:list"
end
```

```diff
- class TodoUpdateHandler < Marten::Handlers::RecordUpdate
+ class TodoUpdateHandler < MartenTurbo::Handlers::RecordUpdate
  model Todo
  schema TodoSchema
  template_name "todos/update.html"
+ turbo_stream_name "todos/update.turbo_stream.html"
  success_route_name "todos:list"
end
```

We changed two things in both handlers: we changed `Marten::Handlers` to `MartenTurbo::Handlers` and added a `turbo_stream_name` definition.

Now let's change our views step by step. We start with `src/templates/todos/index.html`.

```diff
{% extend "base.html" %}

{% block content %}
<h1>Todos</h1>

<div>
-    <a href="{% url 'todos:create' %}" class="button">Create New Todo</a>
+    <a href="{% url 'todos:create' %}" data-turbo-frame="{% dom_id 'new_todo' %}" class="button">
+        Create New Todo
+    </a>
</div>

+ <turbo-frame id="{% dom_id 'new_todo' %}"></turbo-frame>

<div id="todos">
{% for todo in records %}
-    <div class="todo card" style="display: flex; flex-direction: row; justify-content: space-between;align-items: center;">
-        <div class="todo-title">{{ todo.task }}</div>
-        <div class="todo-actions" style="display: flex; gap: 0.5rem;">
-            <a href="{% url 'todos:update' pk: todo.pk %}" class="action action-edit"><i class="bi bi-pencil"></i></a>
-            <form action="{% url 'todos:delete' pk: todo.pk %}" method="post">
-                <input type="hidden" name="csrftoken" value="{% csrf_token %}" />
-                <button class="action action-delete">
-                    <i class="bi bi-trash3"></i>
-                </button>
-            </form>
-        </div>
-    </div>
+   {% include "todos/todo.html" %}
{% endfor %}
</div>
{% endblock %}
```

We did a few things here:

- Changed the `Create New Todo` button to have a turbo frame target `new_todo`. We used to template tag `dom_id` template helper which is provided by Marten Turbo.
- We added a new empty `new_todo` turbo frame where the content of the todo creation form is loaded into
- We moved the HTML content of a single todo into `todos/todo.html`. This way we can reuse the markup everywhere, also in turbo streams, and only need to change it in one place.

The content of the new `src/templates/todos/todo.html` is similar to the one we've removed from `src/templates/todos/index.html`:

```html
<turbo-frame id="{% dom_id todo %}" class="todo card"
    style="display: flex; flex-direction: row; justify-content: space-between;align-items: center;">
    <div class="todo-title">{{ todo.task }}</div>
    <div class="todo-actions" style="display: flex; gap: 0.5rem;">
        <a href="{% url 'todos:update' pk: todo.pk %}" class="action action-edit"><i class="bi bi-pencil"></i></a>
        <form action="{% url 'todos:delete' pk: todo.pk %}" method="post">
            <input autofocus type="hidden" name="csrftoken" value="{% csrf_token %}" />
            <button class="action action-delete">
                <i class="bi bi-trash3"></i>
            </button>
        </form>
    </div>
</turbo-frame>
```

We wrapped the todo in a Turbo Frame and also utilized the `dom_id` helper to make each todo frame unique.

To avoid re-loading the entire page when creating/updating a todo we'll also move the form inside a frame.

```diff
{% extend "base.html" %}

{% block content %}
<h1>Create Todo</h1>

{% url 'todos:create' as action %}

- <div id="todo">
+ <turbo-frame id="{% dom_id 'new_todo' %}">
    <div class="card" style="margin: 0 auto;">
        {% include "todos/todo_form.html" with button_label="Create Todo", action=action %}
    </div>
- </div>
+ </turbo-frame>
{% endblock %}
```
