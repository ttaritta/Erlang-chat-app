-module(proba_server).
-export([start/0, send/3, get_pid/1, loop/1]).

%% startuje server i registruje ga
start() ->
    case whereis(chat_server) of
        undefined ->
            Pid = spawn(?MODULE, loop, [#{}]),
            register(chat_server, Pid),
            io:format("chat_server started with PID: ~p~n", [Pid]),
            Pid;
        Pid ->
            io:format("chat_server already running with PID: ~p~n", [Pid]),
            Pid
    end.

%% manuelno slanje poruke
send(From, To, Text) ->
    chat_server ! {msg, From, To, Text}.

%% get pid for user
get_pid(Name) ->
    Lower = string:to_lower(binary_to_list(Name)),
    LowerAtom = list_to_atom(Lower),
    chat_server ! {get_pid, self(), LowerAtom},
    receive
        {pid, Pid} -> Pid
    after 1000 -> undefined
    end.

%% Users = #{Username => Pid}
loop(Users) ->
    receive
        %% registracija usera
        {join, Username, Pid} ->
            Lower = string:to_lower(atom_to_list(Username)),
            LowerAtom = list_to_atom(Lower),
            io:format("User ~p joined~n", [Username]),
            NewUsers = maps:put(LowerAtom, Pid, Users),
            loop(NewUsers);

        %% poruka od HTTP handlera
        {msg, From, To, Text} ->
            %% Normalize both From and To to lowercase
            FromLower = string:to_lower(binary_to_list(From)),
            FromLowerBin = list_to_binary(FromLower),
            ToLower = string:to_lower(binary_to_list(To)),
            ToLowerBin = list_to_binary(ToLower),
            ToAtom = list_to_atom(ToLower),
            
            case maps:get(ToAtom, Users, undefined) of
                undefined ->
                    io:format("User ~p not found~n", [ToAtom]);
                ToPid ->
                    %% deliver to recipient only
                    ToPid ! {chat_msg, FromLowerBin, ToLowerBin, Text}
            end,
            loop(Users);

        %% get pid
        {get_pid, FromPid, Name} ->
            FromPid ! {pid, maps:get(Name, Users, undefined)},
            loop(Users);

        %% get all users
        {get_users, FromPid} ->
            UserList = maps:keys(Users),
            FromPid ! {users, UserList},
            loop(Users)
    end.
