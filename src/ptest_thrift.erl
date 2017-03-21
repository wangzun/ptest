-module(ptest_thrift).
-include("simple_types.hrl").

-export([start/0]).

start() ->
	Data = test_data:original(),
	{ok,B}= thrift:encode(Data),
	erlang:byte_size(list_to_binary(B)),
	Fun1 = fun() -> thrift:encode(Data) end, 
	Fun2 = fun() -> thrift:decode(B) end, 
	test_data:count_func(Fun1,100),
	test_data:count_func(Fun2,100).

