-module(worker_sup).

-behaviour(supervisor).

%% API
-export([start_link/0,start_child/1]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor

-define(SERVER,worker_sup).

%% ===================================================================
%% API functions
%% ===================================================================

start_child(Args) ->
  supervisor:start_child(?SERVER, [Args]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
    {ok, { {one_for_one, 5, 10}, []} }.
	
