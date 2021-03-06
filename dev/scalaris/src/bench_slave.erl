%  @copyright 2009-2010 Konrad-Zuse-Zentrum fuer Informationstechnik Berlin

%   Licensed under the Apache License, Version 2.0 (the "License");
%   you may not use this file except in compliance with the License.
%   You may obtain a copy of the License at
%
%       http://www.apache.org/licenses/LICENSE-2.0
%
%   Unless required by applicable law or agreed to in writing, software
%   distributed under the License is distributed on an "AS IS" BASIS,
%   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%   See the License for the specific language governing permissions and
%   limitations under the License.

%% @author Christian Hennig <hennig@zib.de>
%% @doc Slave for local benchmark.
%% @end
%% @version $Id: bench_slave.erl 953 2010-08-03 13:52:39Z kruber@zib.de $
-module(bench_slave).
-author('hennig@zib.de').
-vsn('$Id: bench_slave.erl 953 2010-08-03 13:52:39Z kruber@zib.de $').

-export([run_1/0, start/0]).

-spec start() -> pid().
start() ->
    application:start(scalaris),
	erlang:spawn(?MODULE,run_1,[]).

-spec run_1() -> ok.
run_1() ->
    Size = list_to_integer(os:getenv("NODES_VM")),
    io:format("Do ~p~n",[Size]),
    admin:add_nodes(Size-1),
    receive {halt} -> ok
    end.
    %halt(1).
