-module my_kv.
-export [test/0].
-export [start/0, get/2, set/3, stop/1].
-export [init/0].

%%% TEST ----------------------------------------
test() ->
    KV = my_kv:start(),
    not_found = my_kv:get(a, KV),
    ok = my_kv:set(a, 1, KV),
    1 = my_kv:get(a, KV),
    ok = my_kv:set(a, 2, KV),
    2 = my_kv:get(a, KV),
    not_found = my_kv:get(b, KV),
    ok = my_kv:stop(KV).

%%% API -----------------------------------------
start() ->
    my_server:start(my_kv).
get(Key, KV) ->
    my_server:call(KV, {get, Key}).
set(Key, Value, KV) ->
    my_server:cast(KV, {set, Key, Value}).
stop(KV) -> my_server:stop(KV).

init() -> loop(#{}).

loop(St) ->
  receive
    {call, {get, K}, C} ->
        C ! maps:get(K, St, not_found),
        loop(St);
    {cast, {set, K, V}} ->
        loop(St#{K => V});
    stop -> done
  end.
