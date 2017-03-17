%% -----------------------------------------------------------------
%% create time : error
%% create by rebar
%% @author wangzun <wangzun0009@gmail.com>
%% -----------------------------------------------------------------

-module(worker).
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

-record(state,{url,time}).

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
	{Url,Time}=Args,
	{ok,#state{url=Url,time=Time},Time}.

handle_call(_Request, _From, State) ->
	{reply, ok, State}.

handle_cast(_Msg, State) ->
	{noreply, State}.

handle_info(timeout, State) ->
	#state{url=Url,time=Time}=State,
	case catch do_http_req(Url) of
		Catch ->
			io:format("catch : ~p",[Catch])
	end,
	{noreply, State,Time};

handle_info(_Info, State) ->
	{noreply, State}.

terminate(_Reason, _State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

%% ------------------------------------------------------------------
%% Internal Function Definitions
%% ------------------------------------------------------------------

do_http_req(Url) ->
	Headers = [{"AccessToken", "A6E56CD1-B178-8B82-E6E0-02DCF13D7A25"}],
	V = httpc:request(Url),
%%	io:format("http : ~p",[V]),
	ok.
%%	case httpc:request(post, {Url, Headers, "application/x-www-form-urlencoded", ""}, [{timeout, 30000}], []) of
%%		{ok, {_, _, Body}} ->
%%			{ok, Body};
%%		_X -> {error, usercenter_error}
%%	end.
