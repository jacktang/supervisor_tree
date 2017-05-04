# supervisor_tree

The Erlang library module tries to put whole supervisor tree in one file.

# How to Use

Add below code snippet to rebar.config
```
{supervisor_tree,  ".*",   { git, "git://github.com/jacktang/supervisor_tree.git", "master"} }
```

# Tutorial

We are going to develope one standard Erlang/OTP application which named `example_app`, and it contains two kinds processes: `example_store` and `example_handler`. There is one `example_store` process in the application, and many `example_handler`s exist. The `example_handler` process is spawned on demand and add it to supervisor tree. The `src` file structure lists below: 

```
src -- example_app.app.src
    +- example_app.erl
    +- example_sup.erl
    +- example_store.erl
    +- example_handler.erl
    +- example.erl
```

The supervisor tree code in `example_sup.erl`
```
start_link() ->
  supervisor_tree:start_supervisor(example_sup, ?MODULE, []).

init([example_sup]) ->
  StoreConf = application:get_env(example_app, store, []),
  HandlerConf = application:get_env(example_app, handler, []),
  
  Store = supervisor_tree:child_spec(example_stroe, [StoreConf]),
  HandlerSup = supervisor_tree:sup_spec(example_handler_sup, ?MODULE, [HandlerConf]),
  
  supervisor_tree:add_sup(one_for_one, [Store, HandlerSup]);
  
init([handler_sup, HandlerConf]) ->
  Handler = supervisor_tree:dchild_spec(example_handler, [HandlerConf]),
  supervisor_tree:add_sup(simple_one_for_one, [Handler]);

init(_) ->
  supervisor_tree:empty_sup().
```
