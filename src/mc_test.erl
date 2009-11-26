-module(mc_test).

-compile(export_all).

main() ->
    AsciiAddrs = [mc_addr:local(ascii)],
    AsciiPool = mc_pool:create(AsciiAddrs,
                               [mc_bucket:create("default", AsciiAddrs)]),
    BinaryAddrs = [mc_addr:local(binary)],
    BinaryPool = mc_pool:create(BinaryAddrs,
                                [mc_bucket:create("default", BinaryAddrs)]),
    {mc_downstream:start(),
     mc_accept:start(11300,
                     {mc_server_ascii,
                      mc_server_ascii_proxy, AsciiPool}),
     mc_accept:start(11400,
                     {mc_server_ascii,
                      mc_server_ascii_proxy, BinaryPool}),
     mc_accept:start(11500,
                     {mc_server_binary,
                      mc_server_binary_proxy, AsciiPool}),
     mc_accept:start(11600,
                     {mc_server_binary,
                      mc_server_binary_proxy, BinaryPool})}.

% To build:
%   make clean && make
%
% To run tests:
%   erl -pa ebin -noshell -s mc_test test -s init stop
%
tests() -> [mc_ascii,
            mc_client_ascii,
            mc_client_ascii_ac,
            mc_binary,
            mc_client_binary,
            mc_client_binary_ac,
            mc_bucket,
            mc_pool,
            mc_downstream,
            mc_server_ascii_proxy
           ].

test() ->
    cover:start(),
    cover:compile_directory("src", [{i, "include"}]),
    Tests = tests(),
    lists:foreach(
      fun (Test) ->
              io:format("  ~p...~n", [Test]),
              apply(Test, test, [])
      end,
      Tests),
    file:make_dir("tmp"),
    lists:foreach(
      fun (Test) ->
              {ok, _Cov} =
                  cover:analyse_to_file(
                    Test,
                    "tmp/" ++ atom_to_list(Test) ++ ".cov.html",
                    [html])
      end,
      Tests),
    ok.


