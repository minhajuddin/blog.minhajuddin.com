title: A simpler way to generate an incrementing version for elixir apps
date: 2017-01-18 12:44:32
tags:
- Version
- SemVer
- Automatic Generation
- Elixir
- Hex
---

Mix has the notion of versions built into it. If you open up a mix file you'll see a line like below:

```elixir
# mix.exs
defmodule Webmonitor.Mixfile do
  use Mix.Project

  def project do
    [app: :webmonitor,
     version: "0.1.0",
# ...
```

If you are using Git, there is a simple way to automatically generate a meaningful semantic version.
All you need to do is:

  1. Tag a commit with a version tag, like below:

```sh
git tag --annotate v1.0 --message 'First production version, Yay!'
```

  2. Put a helper function which can use this info with `git describe` to generate a version

```elixir

  defp app_version do
    # get git version
    {description, 0} = System.cmd("git", ~w[describe]) # => returns something like: v1.0-231-g1c7ef8b
    _git_version = String.strip(description)
                    |> String.split("-")
                    |> Enum.take(2)
                    |> Enum.join(".")
                    |> String.replace_leading("v", "")
  end

```

  3. Use the return value from this function as the version


```elixir
# mix.exs
defmodule Webmonitor.Mixfile do
  use Mix.Project

  def project do
    [app: :webmonitor,
     version: app_version(),
# ...
```

The way this works is simple. [From the man pages of git-describe](https://git-scm.com/docs/git-describe)

>NAME
>       git-describe - Describe a commit using the most recent tag reachable from it
>
>DESCRIPTION
>       The command finds the most recent tag that is reachable from a commit. If the tag points to the commit, then only the tag is shown. Otherwise, it suffixes the tag name with the
>       number of additional commits on top of the tagged object and the abbreviated object name of the most recent commit.

So, if you have a tag `v1.0` like above, and if you have 10 commits on top of it, `git-describe` will print `v1.0-100-g1c7ef8b` where `v1.0` is the latest git tag reachable from the
current commit, `100` is the number of commits since then and `g1c7ef8b` is the short commit hash of the current commit. We can easily transform this to `1.0.100` using the above helper function.
Now, you have a nice way of automatically managing versions. The patch version is bumped whenever a commit is made, the major and minor version can be changed by creating a new tag, e.g. `v1.2`

This is very useful when you are using [distillery](https://github.com/bitwalker/distillery) for building your releases
