-module(test_data).

-export([original/0,
	count_func/2]).

list_data(Num) ->
	lists:map(
	  fun(Index) ->
			  "wangzundddd" ++ integer_to_list(Index)
	  end,lists:seq(1,Num)).

original() ->
	{person,"wangzun","fsfaef83rsfs322g33dd","34242555",list_data(100000),12,{location,"fasfsfaf","fafsaa"}}.

count_func(Func,Num) ->
	Func1 =
	fun() ->
			lists:foreach(
			  fun(_) ->
					  Func()
			  end,lists:seq(1,Num))
	end,
	timer:tc(Func1).
