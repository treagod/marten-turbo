# Installation

## Prerequisites

* **Crystal:**  Ensure you have Crystal installed on your system. You can find installation instructions on the official [Crystal website](https://crystal-lang.org/install/){:target="_blank"}.
* **Marten Framework:** Marten Turbo works in conjunction with the Marten Framework. Follow the [Marten installation guide](https://martenframework.com/docs/getting-started/installation){:target="_blank"} if you haven't already.
* **Turbo** Ensure you are including Turbo inside your `<head>` section. For installation instructions have a look at their [handbook](https://turbo.hotwired.dev/handbook/installing){:target="_blank"}!

## Adding Marten Turbo to Your Project

1. **Edit `shard.yml`:**  Add the following dependency to your project's `shard.yml` file:

```diff
   dependencies:
+     marten_turbo:
+       github: treagod/marten-turbo
```

2. **Install Dependencies**: Run the following command in your project's directory:

```bash
shards install
```

## Setup in your Marten Project

You have to require `marten_turbo`, add following line to your project's `src/project.cr` file:

```ruby
require "marten_turbo"
```

Now you're ready to go!

Now you can start using Marten Turbo's features in your Turbo application. Check out the [Getting Started Guide](./getting_started.md) for a quick walkthrough to build a simple example.
