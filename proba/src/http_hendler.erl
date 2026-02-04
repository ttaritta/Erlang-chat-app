-module(http_hendler).
-export([init/2]).

cors_headers() ->
    #{
        <<"access-control-allow-origin">> => <<"*">>,
        <<"access-control-allow-methods">> => <<"GET, POST, OPTIONS">>,
        <<"access-control-allow-headers">> => <<"content-type">>
    }.

init(Req0, State) ->
    Method = cowboy_req:method(Req0),
    Path   = cowboy_req:path(Req0),
    handle_request(Method, Path, Req0, State).

%% JEDNA FUNKCIJA za sve endpoint-e
handle_request(<<"OPTIONS">>, _, Req0, State) ->
    Req1 = cowboy_req:reply(204, cors_headers(), Req0),
    {ok, Req1, State};

handle_request(<<"GET">>, <<"/">>, Req0, State) ->
    Html = <<"OK">>,
    Headers = maps:merge(#{<<"content-type">> => <<"text/plain">>}, cors_headers()),
    Req1 = cowboy_req:reply(200, Headers, Html, Req0),
    {ok, Req1, State};

handle_request(<<"GET">>, <<"/users">>, Req0, State) ->
    chat_server ! {get_users, self()},
    receive
        {users, Users} ->
            UsersList = [atom_to_binary(U, utf8) || U <- Users],
            Json = jsx:encode(UsersList),
            Headers = maps:merge(#{<<"content-type">> => <<"application/json">>}, cors_headers()),
            Req1 = cowboy_req:reply(200, Headers, Json, Req0),
            {ok, Req1, State}
    after 1000 ->
        Headers = maps:merge(#{<<"content-type">> => <<"text/plain">>}, cors_headers()),
        Req1 = cowboy_req:reply(500, Headers, <<"Timeout">>, Req0),
        {ok, Req1, State}
    end;

handle_request(<<"GET">>, <<"/messages">>, Req0, State) ->
    Qs   = cowboy_req:parse_qs(Req0),
    Name = proplists:get_value(<<"name">>, Qs),
    From = proplists:get_value(<<"from">>, Qs),
    Pid  = proba_server:get_pid(Name),
    case Pid of
        undefined ->
            Headers = maps:merge(#{<<"content-type">> => <<"text/plain">>}, cors_headers()),
            Req1 = cowboy_req:reply(404, Headers, <<"User not found">>, Req0),
            {ok, Req1, State};
        _ ->
            case From of
                undefined ->
                    Pid ! {get_messages, self()};
                _ ->
                    Pid ! {get_messages_from, self(), From}
            end,
            receive
                {messages, Msgs} ->
                    Pairs = [ [F,T,Ts] || {Ts,F,_To,T} <- Msgs ],
                    Json = jsx:encode(Pairs),
                    Headers = maps:merge(#{<<"content-type">> => <<"application/json">>}, cors_headers()),
                    Req1 = cowboy_req:reply(200, Headers, Json, Req0),
                    {ok, Req1, State}
            after 1000 ->
                Headers = maps:merge(#{<<"content-type">> => <<"text/plain">>}, cors_headers()),
                Req1 = cowboy_req:reply(500, Headers, <<"Timeout">>, Req0),
                {ok, Req1, State}
            end
    end;

handle_request(<<"POST">>, <<"/login">>, Req0, State) ->
    io:format("LOGIN REQUEST RECEIVED~n"),
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    io:format("Body: ~p~n", [Body]),
    Json = jsx:decode(Body, [return_maps]),
    io:format("Json decoded: ~p~n", [Json]),
    Name = maps:get(<<"name">>, Json),
    io:format("Username: ~p~n", [Name]),
    chat_user:start(Name),
    io:format("User started: ~p~n", [Name]),
    Headers = maps:merge(#{<<"content-type">> => <<"text/plain">>}, cors_headers()),
    Req2 = cowboy_req:reply(200, Headers, <<"Logged in">>, Req1),
    {ok, Req2, State};

handle_request(<<"POST">>, <<"/msg">>, Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Json = jsx:decode(Body, [return_maps]),
    From = maps:get(<<"from">>, Json),
    To   = maps:get(<<"to">>, Json),
    Text = maps:get(<<"text">>, Json),
    chat_server ! {msg, From, To, Text},
    Headers = maps:merge(#{<<"content-type">> => <<"text/plain">>}, cors_headers()),
    Req2 = cowboy_req:reply(200, Headers, <<"OK">>, Req1),
    {ok, Req2, State};


handle_request(<<"GET">>, <<"/conversation">>, Req0, State) ->
    Qs   = cowboy_req:parse_qs(Req0),
    A    = proplists:get_value(<<"a">>, Qs),
    B    = proplists:get_value(<<"b">>, Qs),
    PidA = proba_server:get_pid(A),
    PidB = proba_server:get_pid(B),
    case {PidA, PidB} of
        {undefined, _} ->
            Json = jsx:encode([]),
            Headers = maps:merge(#{<<"content-type">> => <<"application/json">>}, cors_headers()),
            Req1 = cowboy_req:reply(200, Headers, Json, Req0),
            {ok, Req1, State};
        {_, undefined} ->
            Json = jsx:encode([]),
            Headers = maps:merge(#{<<"content-type">> => <<"application/json">>}, cors_headers()),
            Req1 = cowboy_req:reply(200, Headers, Json, Req0),
            {ok, Req1, State};
        _ ->
            %% fetch A<-B
            PidA ! {get_messages_from, self(), B},
            %% fetch B<-A
            PidB ! {get_messages_from, self(), A},
                MsgsA = receive
                                {messages, M1} -> M1
                            after 1000 -> []
                            end,
                MsgsB = receive
                                {messages, M2} -> M2
                            after 1000 -> []
                            end,
                Combined = lists:sort(fun({Ts1,_,_,_}, {Ts2,_,_,_}) -> Ts1 =< Ts2 end, MsgsA ++ MsgsB),
                Pairs2 = [ [F,T,Ts] || {Ts,F,_To,T} <- Combined ],
            Json = jsx:encode(Pairs2),
            Headers = maps:merge(#{<<"content-type">> => <<"application/json">>}, cors_headers()),
            Req1 = cowboy_req:reply(200, Headers, Json, Req0),
            {ok, Req1, State}
    end;

handle_request(_, _, Req0, State) ->
    Headers = maps:merge(#{<<"content-type">> => <<"text/plain">>}, cors_headers()),
    Req1 = cowboy_req:reply(404, Headers, <<"Not found">>, Req0),
    {ok, Req1, State}.
