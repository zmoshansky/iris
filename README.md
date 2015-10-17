[Iris - is the personification of the rainbow and messenger of the gods. Iris links the gods to humanity. She travels with the speed of wind from one end of the world to the other, and into the depths of the sea and the underworld (spaghetti code can I get a hell yeah?).](https://en.wikipedia.org/wiki/Iris_(mythology))
======

A simple RPC system that filters calls based on Module, Function, Arity (MFA).

[![Build Status](https://travis-ci.org/zmoshansky/iris.svg)](https://travis-ci.org/zmoshansky/iris) [![Hex.pm](http://img.shields.io/hexpm/v/iris.svg)](https://hex.pm/packages/iris) [![Hex.pm](http://img.shields.io/hexpm/dt/iris.svg)](https://hex.pm/packages/iris) [![Github Issues](http://githubbadges.herokuapp.com/zmoshansky/iris/issues.svg)](https://github.com/zmoshansky/iris/issues) [![Pending Pull-Requests](http://githubbadges.herokuapp.com/zmoshansky/iris/pulls.svg)](https://github.com/zmoshansky/iris/pulls)

#### Warning ####
First and foremost, this module allows remote calls into your codebase. It should be checked thoroughly for any potential security threats.

Allow lists and module prefixing should help to reduce, and hopefully eliminate, the risk of inadvertent damage. Additionally, tests and `mix dialyzer` have been used to try and assert correctness as much as possible.

```
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```

#### Description ####
Iris checks calls against an allow list before proceeding to dispatch them. It takes a list containing the [Module, Function, Args], aka MFA, as specified in the docs and shown in tests. Iris will only convert strings to existing atoms in an effort to prevent unlimited atoms from being created.

Iris can optionally add an `assigns` parameter which will be passed as the first argument to the function being requested. This is particularly useful to add local data to the RPC call, ex.) session information for a user.

`mod_prefix` can also be used to "namespace" the module string, this can help to hide the app structure, or add another layer of defense; assuming the allow list failed, or the wrong module is accidently added.


#### Config ####
Iris is easily configured and allows for multiple option sets. The key `:public` or `:private` is used to specify groupings of allowed calls and module prefixes. These groupings can be used to compose forms of MAC or other authentication layers. See `config.exs` and the tests to get a better idea.

```
config :iris, :public,
  allow: %{
    :"Elixir.Iris.Test.TestModule" => %{test_public: [1]}
  },
  mod_prefix: "Elixir.Iris.Test."

config :iris, :private,
  allow: %{
    :"Elixir.Iris.Test.TestModule" => %{test_private: [1], test_assigns: [2]}
  },
  mod_prefix: "Elixir.Iris.Test."
```
