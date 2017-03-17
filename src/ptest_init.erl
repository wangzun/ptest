%% -----------------------------------------------------------------
%% create time : error
%% create by rebar
%% @author wangzun <wangzun0009@gmail.com>
%% @doc start and stop ptest_init
%% -----------------------------------------------------------------

-module(ptest_init).
-behaviour(gen_server).
-define(SERVER, ?MODULE).

%% ------------------------------------------------------------------
%% API Function Exports
%% ------------------------------------------------------------------

-export([start_link/0]).
-export([start_link/1]).

%% ------------------------------------------------------------------
%% gen_server Function Exports
%% ------------------------------------------------------------------

-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
	 terminate/2, code_change/3]).

-record(state,{url,time,num}).

%% ------------------------------------------------------------------
%% API Function Definitions
%% ------------------------------------------------------------------
start_link(Args) ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, [Args], []).

start_link() ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%% ------------------------------------------------------------------
%% gen_server Function Definitions
%% ------------------------------------------------------------------

init([Args]) ->
	io:format("~p",[Args]),

	{Url,Time,Num} = Args,
	do_init_worker(Url,Time,Num),
	{ok, #state{url=Url,time=Time,num=Num}}.

handle_call(_Request, _From, State) ->
	{reply, ok, State}.

handle_cast(_Msg, State) ->
	{noreply, State}.

handle_info(_Info, State) ->
	{noreply, State}.

terminate(_Reason, _State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

%% ------------------------------------------------------------------
%% Internal Function Definitions
%% ------------------------------------------------------------------


do_init_worker(Url,Time,Num) ->
	lists:foreach(
	  fun(Index) ->
			  Param = 
			  {get_name(Index),{worker, start_link, [{Url,Time}]},
			   transient, 2000, worker, []},
			  case catch  supervisor:start_child(worker_sup, Param) of
				  A ->
					  ok
			  end
	  end,lists:seq(1,Num)).

get_name(Index) ->
	"worker"++ integer_to_list(Index).
