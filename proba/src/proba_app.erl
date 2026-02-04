%%%-------------------------------------------------------------------
%% @doc proba public API
%% @end
%%%-------------------------------------------------------------------

-module(proba_app).

-behaviour(application).

-export([start/2, stop/1, start/0]).

start() ->
    start(normal, []).

start(_StartType, _StartArgs) ->
    {ok, SupPid} = proba_sup:start_link(),
    _Pid = proba_server:start(),
    io:format("Starting Cowboy~n"),
    Dispatch = cowboy_router:compile([
        {'_', [
            {"/", http_hendler, []},
            {"/login", http_hendler, []},
            {"/msg", http_hendler, []},
            {"/messages", http_hendler, []},
            {"/users", http_hendler, []},
            {"/conversation", http_hendler, []}
        ]}
    ]),
    try cowboy:start_clear(http, [{port, 8082}, {ip, {0, 0, 0, 0}}], #{env => #{dispatch => Dispatch}}) of
        {ok, _Pid2} ->
            io:format("Cowboy started on port 8082~n"),
            {ok, SupPid};
        {error, Reason} ->
            io:format("Cowboy error: ~p~n", [Reason]),
            {ok, SupPid}
    catch
        Error ->
            io:format("Cowboy exception: ~p~n", [Error]),
            {ok, SupPid}
    end.

stop(_State) ->
    ok.

%% internal functions
