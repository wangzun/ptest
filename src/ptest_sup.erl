-module(ptest_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD1(I, Type,Args), {I, {I, start_link, [Args]}, permanent, 5000, Type, [I]}).
-define(CHILD2(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).
%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
	Args = {"http://120.24.163.94:9099/",200,200},
	{ok, { {one_for_one, 5, 10},
	       [?CHILD2(worker_sup,worker),
		?CHILD1(ptest_init,worker,Args)]} }.

