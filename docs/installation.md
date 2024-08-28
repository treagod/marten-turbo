# Installation

## Prerequisites

Before you begin, ensure you have the following installed:

- **Crystal** programming language: [Installation Guide](https://crystal-lang.org/install/)
- **Marten Framework**: Make sure your project is set up with the Marten framework.

## Installation Steps

To install Marten Turbo in your project, follow these steps:

1. **Update your `shard.yml` file:**

Add the following dependency to your `shard.yml` file:

```yaml
dependencies:
    marten_turbo:
    github: treagod/marten-turbo
```

2.	**Install the dependencies:**

After updating shard.yml, run the following command to install the dependencies:

```bash
shards install
```

3.	**Add Marten Turbo to your project:**

In your main project file (usually src/project.cr), require the Marten Turbo library by adding the following line:

```crystal
require "marten_turbo"
```

## Post-Installation

Once the installation is complete, you can start using Marten Turbo’s features in your project. For example, you can now use the `dom_id` template helper and Turbo handlers in your Marten framework application.


For detailed usage instructions, refer to the [Usage Guide](usage.md).
