-module(ptest_thrift).
-include("simple_types.hrl").

-export([start/0]).

start() ->
	Data = test_data:original(),
	thrift:encode(Data).

