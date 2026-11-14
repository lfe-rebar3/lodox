# Lodox

[![Travis CI][travis badge]][travis builds]
[![Release][tag badge]][latest release]
[![Erlang][erlang badge]][erlang downloads]
[![Documentation][doc badge]][docs]
[![MIT License][license badge]](LICENSE)

[travis builds]: https://travis-ci.org/lfe-rebar3/lodox
[travis badge]: https://travis-ci.org/lfe-rebar3/lodox.svg
[tag badge]: https://img.shields.io/github/tag/lfe-rebar3/lodox.svg
[latest release]: https://github.com/lfe-rebar3/lodox/releases/latest
[erlang badge]: https://img.shields.io/badge/erlang-R16B03%20%7C%20%E2%89%A517.5-red.svg
[erlang downloads]: http://www.erlang.org/downloads
[doc badge]: https://img.shields.io/badge/docs-100%25-green.svg
[docs]: https://lfe-rebar3.github.io/lodox
[license badge]: https://img.shields.io/badge/license-MIT-blue.svg

---

**DEPRECATED**: LFE users should migrate to [ldoc](https://github.com/lfex/ldoc) (a clone of the more maintained cljdoc)

---

_Like [Codox] for [LFE]._
Check out the [self-generated documentation][docs].

**Requires** Erlang 16B03-1 or >= 17.5 *and* [pandoc].

[Codox]: https://github.com/weavejester/codox
[LFE]: https://github.com/rvirding/lfe
[pandoc]: http://pandoc.org


# Installation

First, make sure you have the [lfe-compile] plugin as a dependency in your
project's `rebar.config`:

```erlang
{plugins, [
  {'lfe-compile', "0.6.0", {pkg, rebar3_lfe_compile}}
]}.
```

Then in your project's `rebar.config`, include the [provider post-hook]:

```erlang
{provider_hooks, [{post, [{compile, {lfe, compile}}]}]}
```

Finally, add Lodox to your `project_plugins` list.

```erlang
{project_plugins, [
  {lodox, {git, "git://github.com/lfe-rebar3/lodox.git", {tag, "0.16.2"}}}
]}.
```

[lfe-compile]: https://github.com/lfe-rebar3/compile
[provider post-hook]: https://www.rebar3.org/v3.0/docs/configuration#section-provider-hooks


# Usage

In order for Lodox to work, your project must first be compiled:

```sh
rebar3 compile
```

Then, to invoke Lodox, simply run:

```sh
rebar3 lfe lodox
```

Alternatively, you can `do` both at once:

```sh
rebar3 do compile, lfe lodox
```

If all goes well, the output will look something like:

    Generated lodox vX.Y.Z docs in /path/to/lodox/docs

And, as promised, [generated documentation][docs] will be in the `docs/` (or
`{'output-path', "path/to/docs"}`) subdirectory of your project.


## API Documentation

For more information on how to use Lodox, see the [API documentation][docs],
especially the the [Topics] section.

[Topics]: https://lfe-rebar3.github.io/lodox/index.html#Topics


# License

Lodox is licensed under [the MIT License](LICENSE).

Significant code and inspiration from [Codox]. Copyright © 2015 James Revees

> Codox is distributed under the Eclipse Public License either version 1.0 or
> (at your option) any later version.
