-module(thrift_transport).

-export([behaviour_info/1]).

-export([new/2,
  write/2,
  read/2,
  flush/1,
  close/1
]).

behaviour_info(callbacks) ->
  [{read, 2},
    {write, 2},
    {flush, 1},
    {close, 1}
  ].

-record(transport, {module, data}).

-ifdef(transport_wrapper_module).
-define(debug_wrap(Transport),
  case Transport#transport.module of
    ?transport_wrapper_module ->
      Transport;
    _Else ->
      {ok, Result} = ?transport_wrapper_module:new(Transport),
      Result
  end).
-else.
-define(debug_wrap(Transport), Transport).
-endif.

new(Module, Data) when is_atom(Module) ->
  Transport0 = #transport{module = Module, data = Data},
  Transport1 = ?debug_wrap(Transport0),
  {ok, Transport1}.

-spec write(#transport{}, iolist() | binary()) -> {#transport{}, ok | {error, _Reason}}.
write(Transport, Data) ->
  Module = Transport#transport.module,
  {NewTransData, Result} = Module:write(Transport#transport.data, Data),
  {Transport#transport{data = NewTransData}, Result}.

-spec read(#transport{}, non_neg_integer()) -> {#transport{}, {ok, binary()} | {error, _Reason}}.
read(Transport, Len) when is_integer(Len) ->
  Module = Transport#transport.module,
  {NewTransData, Result} = Module:read(Transport#transport.data, Len),
  {Transport#transport{data = NewTransData}, Result}.

-spec flush(#transport{}) -> {#transport{}, ok | {error, _Reason}}.
flush(Transport = #transport{module = Module, data = Data}) ->
  {NewTransData, Result} = Module:flush(Data),
  {Transport#transport{data = NewTransData}, Result}.

-spec close(#transport{}) -> {#transport{}, ok | {error, _Reason}}.
close(Transport = #transport{module = Module, data = Data}) ->
  {NewTransData, Result} = Module:close(Data),
  {Transport#transport{data = NewTransData}, Result}.
