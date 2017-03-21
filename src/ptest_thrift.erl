-module(ptest_thrift).
-include("simple_types.hrl").

-export([start/0]).

start() ->
	Data = test_data:original(),
	{ok,B}= thrift:encode(Data),
	erlang:byte_size(list_to_binary(B)).

