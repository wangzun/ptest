-module(ptest_gl).

-export([start/0]).

start() ->
	Data = test_data:original(),
	B = protocal_payload:encode_person(Data),
	{Data,_} = protocal_payload:decode_person(B),
	Size = erlang:byte_size(B),
	Fun1 = fun() -> protocal_payload:encode_person(Data) end, 
	Fun2 = fun() -> protocal_payload:decode_person(B) end, 
	{Time,_}= test_data:count_func(Fun1,100),
	{Time1,_}= test_data:count_func(Fun2,100),
	io:format("binanry size : ~p   encode time : ~p  decode time : ~p~n",[Size,Time,Time1]).

