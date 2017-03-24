-module(thrift).
-export([
	 encode/1,
	 decode/1
	]).

-include("thrift_constants.hrl").
-include("thrift_protocol.hrl").

-record(framed_transport, {wrapped, % a thrift_transport
  read_buffer, % iolist()
  write_buffer % iolist()
}).

-record(transport, {module = thrift_framed_transport, data = #framed_transport{}}).

-record(binary_protocol, {transport= #transport{},
  strict_read = true,
  strict_write = true
}).

-record(protocol, {module, data}).
%% module =  thrift_binary_protocol
%% data =  #binary_protocol{}


decode(Bin) ->
	{ok,Transport} = thrift_framed_transport:new(undefined),
	{ok,Proto} = thrift_binary_protocol:new(Transport),
	Proto0= Proto#protocol{data=#binary_protocol{transport= #transport{data = #framed_transport{read_buffer = Bin}}}},
	{Proto1, MessageBegin} = thrift_protocol:read(Proto0, message_begin),
	case MessageBegin of
		{protocol_message_begin, Function, _, _Seqid} ->
			StructDef = {struct, {simple_types, list_to_atom(Function)}},
			{_Proto2, {ok, Result}} = thrift_protocol:read(Proto1, StructDef),
			{ok, Result};
		_ ->
			{error, decode}
	end.


encode(Data) ->
	{ok,Transport} = thrift_framed_transport:new(undefined),
	{ok,Proto0} = thrift_binary_protocol:new(Transport),
	StructName = erlang:element(1, Data),
	StructDef = simple_types:struct_info(StructName),
	Begin = #protocol_message_begin{name = atom_to_list(StructName),
					type = 1,
					seqid = 1},
	{Proto1, ok} = thrift_protocol:write(Proto0, Begin),
	{Proto2, ok} = thrift_protocol:write(Proto1, {StructDef, Data}),
	{Proto3, ok} = thrift_protocol:write(Proto2, message_end),
	#protocol{data=#binary_protocol{transport= #transport{data = #framed_transport{write_buffer= Bin}}}} =Proto3,
	{ok, Bin}.

