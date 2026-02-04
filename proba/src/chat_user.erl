-module(chat_user).
-export([start/1, loop/2]).

start(Name) ->
    Username = if is_binary(Name) -> list_to_atom(string:to_lower(binary_to_list(Name)));
                  is_list(Name) -> list_to_atom(string:to_lower(Name));
                  true -> Name
               end,
    Pid = spawn(?MODULE, loop, [Username, []]),
    Pid ! Username,
    Pid.
  

  
loop(Username, Messages) ->
    receive
        %% inicijalna registracija kod servera
        Username ->
            chat_server ! {join, Username, self()},
            io:format("~p registered~n", [Username]),
            loop(Username, Messages);

        %% primljena poruka
        {chat_msg, From, To, Text} ->
            Ts = erlang:system_time(millisecond),
            NewMessages = [{Ts, From, To, Text} | Messages],
            io:format("~p got message from ~p to ~p: ~s~n",
                      [Username, From, To, Text]),
            loop(Username, NewMessages);

        %% zahtev za istoriju
        {get_messages, FromPid} ->
            Sorted = lists:sort(fun({Ts1,_,_,_}, {Ts2,_,_,_}) -> Ts1 =< Ts2 end, Messages),
            FromPid ! {messages, Sorted},
            loop(Username, Messages);

        %% zahtev za poruke od specifičnog korisnika
        {get_messages_from, FromPid, FromUser} ->
            FromUserBinary = if is_atom(FromUser) -> atom_to_binary(FromUser, utf8);
                              true -> FromUser
                             end,
            %% Normalize to lowercase for comparison
            FromUserLower = string:to_lower(binary_to_list(FromUserBinary)),
            FromUserLowerBin = list_to_binary(FromUserLower),
            %% Filter messages where the other user is either From or To
            FilteredMessages = [M || {_, FromU, ToU, _} = M <- Messages, 
                                     string:to_lower(binary_to_list(FromU)) =:= FromUserLower orelse 
                                     string:to_lower(binary_to_list(ToU)) =:= FromUserLower],
            Sorted = lists:sort(fun({Ts1,_,_,_}, {Ts2,_,_,_}) -> Ts1 =< Ts2 end, FilteredMessages),
            FromPid ! {messages, Sorted},
            loop(Username, Messages)
    end.
