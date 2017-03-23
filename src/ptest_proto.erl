-module(ptest_proto).

-export([start/0]).

start() ->
	protobuffs_compile:scan_file("proto/simple.proto"),
	Data = test_data:original(),
        B = simple_pb:encode(Data),
	B1 =  list_to_binary(B),
	Size = erlang:byte_size(B1),
        Fun1 = fun() -> simple_pb:encode(Data) end,
	Fun2 = fun() -> simple_pb:decode_person(B1) end,
	{Time,_}= test_data:count_func(Fun1,100),
	{Time1,_}=test_data:count_func(Fun2,100),
	io:format("binanry size : ~p   encode time : ~p  decode time : ~p~n",[Size,Time,Time1]).


