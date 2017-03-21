-module(ptest_proto).

-export([start/0]).

start() ->
	protobuffs_compile:scan_file("proto/simple.proto"),
	Data = test_data:original(),
        B = simple_pb:encode(Data),
	erlang:byte_size(list_to_binary(B)).

