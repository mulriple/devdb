%% @author author <author@example.com>
%% @copyright YYYY author.

%% @doc Supervisor for the skel application.

-module(skel_sup).
-author('author <author@example.com>').
-include("erl_logger.hrl").
-behaviour(supervisor).

%% External exports
-export([start_link/0, upgrade/0]).

%% supervisor callbacks
-export([init/1]).

%% @spec start_link() -> ServerRet
%% @doc API for starting the supervisor.
start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% @spec upgrade() -> ok
%% @doc Add processes if necessary.
upgrade() ->
    {ok, {_, Specs}} = init([]),

    Old = sets:from_list(
            [Name || {Name, _, _, _} <- supervisor:which_children(?MODULE)]),
    New = sets:from_list([Name || {Name, _, _, _, _, _} <- Specs]),
    Kill = sets:subtract(Old, New),

    sets:fold(fun (Id, ok) ->
                      supervisor:terminate_child(?MODULE, Id),
                      supervisor:delete_child(?MODULE, Id),
                      ok
              end, ok, Kill),

    [supervisor:start_child(?MODULE, Spec) || Spec <- Specs],
    ok.

%% @spec init([]) -> SupervisorTree
%% @doc supervisor callback.
init([]) ->
    Ip = skel:get_config(ip, "127.0.0.1"),
    Port = skel:get_config(port, 8000),
    DocRoot = skel_deps:local_path(["priv", "www"]),
    WebConfig = [
         {ip, Ip},
         {port, Port},
         {docroot, DocRoot}],
    ?INFO_MSG("start server on#~p", [WebConfig]),

    Web = {skel_web,
           {skel_web, start, [WebConfig]},
           permanent, 5000, worker, dynamic},

    %% get the base dir
    BaseDir = skel_deps:get_base_dir(),

    %% 在这里添加我们需要启动的application:
    Router = {erails_controller_server,
	      {erails_controller_server, start, [BaseDir]},
	      permanent, 5000, worker, dynamic},

    SessionServer = {erails_session_server,
		     {erails_session_server,start,[]},
		     permanent, 5000, worker, dynamic},

    Processes = [Web, Router, SessionServer],
    {ok, {{one_for_one, 10, 10}, Processes}}.


%%
%% Tests
%%
-include_lib("eunit/include/eunit.hrl").
-ifdef(TEST).
-endif.
