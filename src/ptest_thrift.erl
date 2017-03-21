-module(ptest_thrift).
-include("simple_types.hrl").

-export([start/0]).

start() ->
	Data = test_data:original(),
	{ok,B}= thrift:encode(Data),
	Size = erlang:byte_size(list_to_binary(B)),
	Fun1 = fun() -> thrift:encode(Data) end, 
	Fun2 = fun() -> thrift:decode(B) end, 
	{Time,_}= test_data:count_func(Fun1,100),
	{Time1,_}= test_data:count_func(Fun2,100),
	io:format("thrift encode binanry size : ~p   encode time : ~p  decode time : ~p",[Size,Time,Time1]).

