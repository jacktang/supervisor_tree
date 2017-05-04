%%%-------------------------------------------------------------------
%%% @author Jack Tang <himars@gmail.com>
%%% @copyright (C) 2017, jack
%%% @doc
%%%
%%% @end
%%% Created :  4 May 2017 by Jack Tang <himars@gmail.com>
%%%-------------------------------------------------------------------
-module(supervisor_tree).

%% API
-export([start_supervisor/3]).
-export([empty_sup/0]).
-export([add_sup/2]).
-export([sup_spec/3,
         child_spec/1,
         child_spec/2,
         child_spec/3,
         child_spec/4,
         child_spec/5,
         dchild_spec/1,
         dchild_spec/2,
         dchild_spec/3,
         dchild_spec/4]).

-define(MAXR, 1000).
-define(MAXT, 3600).
-define(valid_strategy(S), ((S =:= one_for_one) orelse
                            (S =:= one_for_all) orelse
                            (S =:= rest_for_one) orelse
                            (S =:= simple_one_for_one))).

%%%===================================================================
%%% API
%%%===================================================================
start_supervisor(SupName, SupModule, Args) ->
    supervisor:start_link({local, SupName}, SupModule, [SupName | Args]).

empty_sup() ->
    supervisor_tmpl(one_for_one, []).

add_sup(Strategy, Specs) when ?valid_strategy(Strategy) andalso is_list(Specs)->
    supervisor_tmpl(Strategy, Specs);
add_sup(Strategy, Spec) when ?valid_strategy(Strategy) andalso is_map(Spec) ->
    supervisor_tmpl(Strategy, [Spec]).

sup_spec(SupName, SupModule, Args) when (is_atom(SupName) andalso
                                         is_atom(SupModule) andalso
                                         is_list(Args)) ->
    #{id => SupName,                               % mandatory
      start => {?MODULE, start_supervisor, [SupName, SupModule, Args]},      % mandatory
      restart => transient,                     % optional
      shutdown => infinity,                     % optional
      type => supervisor,                       % optional
      modules => [SupModule]}.

child_spec(Module) ->
    child_spec(Module, []).
child_spec(Module, Args) ->
    child_spec(Module, Module, Args, transient).
child_spec(Module, Args, Restart) ->
    child_spec(Module, Module, Args, Restart).  % Restart = transient, temporary

child_spec(Name, Module, Args, Restart) ->
    #{id => Name,                               % mandatory
      start => {Module, start_link, Args},      % mandatory
      restart => Restart,                       % optional
      type => worker,                           % optional
      modules => [Module]}.
child_spec(Name, Module, Args, Restart, Shutdown) ->
    #{id => Name,                               % mandatory
      start => {Module, start_link, Args},      % mandatory
      restart => Restart,                       % optional
      shutdown => Shutdown,                     % optional
      type => worker,                           % optional
      modules => [Module]}.

dchild_spec(Module) ->
    dchild_spec(Module, []).
dchild_spec(Module, Args) ->
    child_spec(undefined, Module, Args, transient).
dchild_spec(Module, Args, Restart) ->
    child_spec(undefined, Module, Args, Restart).
dchild_spec(Module, Args, Restart, Shutdown) ->
    child_spec(undefined, Module, Args, Restart, Shutdown).

%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------

%%%===================================================================
%%% Internal functions
%%%===================================================================
supervisor_tmpl(Restart, Specs) when is_list(Specs)->
    SupFlags = #{strategy => Restart,
                 intensity => ?MAXR,
                 period => ?MAXT},
    {ok, {SupFlags, Specs}}.
