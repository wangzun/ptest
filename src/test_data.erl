-module(test_data).

-export([start/0,
	 original/0,
	 kv_data/0,
	 test1/0,
	count_func/2]).

kv_data() ->
	{[
	  {<<"type">>, <<"workers">>},
	  {<<"data">>,
	   [
	    {[{<<"workerid">>, <<"std.1">>},{<<"slots">>, []}]}
	   ]
	  }
	 ]}.


list_data(Num) ->
	lists:map(
	  fun(Index) ->
			  "wangzundddd" ++ integer_to_list(Index)
	  end,lists:seq(1,Num)).

original() ->
	{person,"wangzun","fsfaef83rsfs322g33dd","34242555",list_data(10000),12,{location,"fasfsfaf","fafsaa"}}.

count_func(Func,Num) ->
	Func1 =
	fun() ->
			lists:foreach(
			  fun(_) ->
					  Func()
			  end,lists:seq(1,Num))
	end,
	timer:tc(Func1).

start() ->
	Data = original(),
	B = term_to_binary(Data),
	Size = erlang:byte_size(B),
	Fun1 = fun() -> term_to_binary(Data) end, 
	Fun2 = fun() -> binary_to_term(B) end, 
	{Time,_}= test_data:count_func(Fun1,100),
	{Time1,_}= test_data:count_func(Fun2,100),
	io:format("binanry size : ~p   encode time : ~p  decode time : ~p~n",[Size,Time,Time1]).



test1() ->
	io:format("test1 : encode decode size time ! ~n "),
	io:format("erlang ---------------------------------------------------------------------  ~n "),
	start(),
	io:format("gl game --------------------------------------------------------------------  ~n "),
	ptest_gl:start(),
	io:format("thrift ---------------------------------------------------------------------  ~n "),
	ptest_thrift:start(),
	io:format("proto ----------------------------------------------------------------------  ~n "),
	ptest_proto:start().
