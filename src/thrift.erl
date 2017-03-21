-module(thrift).
-export([
	 encode/1,
	 decode/1
	]).

-include("thrift_constants.hrl").
-include("thrift_protocol.hrl").

decode(Bin) ->
	Proto0 = {protocol,
		  thrift_binary_protocol,
		  {binary_protocol,
		   {transport, thrift_framed_transport,
		    {framed_transport,
		     {transport,
		      thrift_socket_transport, {data, undefined, infinity}
		     },
		     Bin, []
		    }
		   }, false, true
		  }
		 },
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
	Proto0 = {protocol,
		  thrift_binary_protocol,
		  {binary_protocol,
		   {transport, thrift_framed_transport,
		    {framed_transport,
		     {transport,
		      thrift_socket_transport, {data, undefined, infinity}
		     },
		     [], []
		    }
		   }, false, true
		  }
		 },
	StructName = erlang:element(1, Data),
	StructDef = simple_types:struct_info(StructName),
	Begin = #protocol_message_begin{name = atom_to_list(StructName),
					type = 1,
					seqid = 1},
	{Proto1, ok} = thrift_protocol:write(Proto0, Begin),
	{Proto2, ok} = thrift_protocol:write(Proto1, {StructDef, Data}),
	{Proto3, ok} = thrift_protocol:write(Proto2, message_end),
	{protocol,
	 thrift_binary_protocol,
	 {binary_protocol,
	  {transport, thrift_framed_transport,
	   {framed_transport,
	    {transport,
	     thrift_socket_transport, {data, undefined, infinity}
	    },
	    [], Bin
	   }
	  }, false, true
	 }
	} = Proto3,
	{ok, Bin}.

