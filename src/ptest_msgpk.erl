-module(ptest_msgpk).

-export([start/0]).

start() ->
	Data = test_data:kv_data(),
	B = msgpack:pack(Data,[{map_format,jsx}, {spec,new}]),
	io:format("~p",[B]),
	{ok, Data} = msgpack:unpack(B,[{map_format,jsx}, {spec,new}]),
	Size = erlang:byte_size(B),
	Fun1 = fun() -> msgpack:pack(Data) end, 
	Fun2 = fun() -> msgpack:unpack(B) end, 
	{Time,_}= test_data:count_func(Fun1,100),
	{Time1,_}= test_data:count_func(Fun2,100),
	io:format("thrift encode binanry size : ~p   encode time : ~p  decode time : ~p",[Size,Time,Time1]).

