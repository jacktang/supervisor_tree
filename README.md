# supervisor_tree

The Erlang library module tries to put whole supervisor tree in one file.

example_sup.erl
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
