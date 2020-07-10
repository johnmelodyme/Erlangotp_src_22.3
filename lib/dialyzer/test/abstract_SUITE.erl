%% This suite contains cases that cannot be written
%% in Erlang itself and must be done via the abstract
%% format.

-module(abstract_SUITE).

-include_lib("common_test/include/ct.hrl").
-include("dialyzer_test_constants.hrl").

-export([suite/0, all/0, init_per_suite/0, init_per_suite/1, end_per_suite/1]).
-export([generated_case/1]).

suite() ->
    [{timetrap, {minutes, 1}}].
all() ->
    [generated_case].

init_per_suite() ->
  [{timetrap, ?plt_timeout}].
init_per_suite(Config) ->
  OutDir = ?config(priv_dir, Config),
  case dialyzer_common:check_plt(OutDir) of
    fail -> {skip, "Plt creation/check failed."};
    ok -> [{dialyzer_options, []}|Config]
  end.

end_per_suite(_Config) ->
    %% This function is required since init_per_suite/1 exists.
    ok.

generated_case(Config) when is_list(Config) ->
    %% Equivalent to:
    %%
    %% -module(foo).
    %% -export(bar).
    %% bar() ->
    %%     Arg = sample,
    %%     case Arg of
    %%         #{} -> map;
    %%         _ -> Arg:fn()
    %%     end.
    %%
    %% Except the case statement and its clauses are marked as autogenerated.
    [] =
	test([{attribute,1,module,foo},
	      {attribute,2,export,[{bar,0}]},
	      {function,3,bar,0,
	       [{clause,3,[],[],
		 [{match,4,{var,4,'Arg'},{atom,4,sample}},
		  {'case',[{location,5},{generated,true}],{var,5,'Arg'},
		   [{clause,[{location,6},{generated,true}],[{map,6,[]}],[],
		     [{atom,6,map}]},
		    {clause,[{location,7},{generated,true}],[{var,7,'_'}],[],
		     [{call,7,{remote,7,{var,7,'Arg'},{atom,7,fn}},[]}]}]}]}]}],
	     Config, [], []),
    %% With the first clause not auto-generated
    [{warn_matching,{_,6},_}] =
	test([{attribute,1,module,foo},
	      {attribute,2,export,[{bar,0}]},
	      {function,3,bar,0,
	       [{clause,3,[],[],
		 [{match,4,{var,4,'Arg'},{atom,4,sample}},
		  {'case',[{location,5},{generated,true}],{var,5,'Arg'},
		   [{clause,6,[{map,6,[]}],[],
		     [{atom,6,map}]},
		    {clause,[{location,7},{generated,true}],[{var,7,'_'}],[],
		     [{call,7,{remote,7,{var,7,'Arg'},{atom,7,fn}},[]}]}]}]}]}],
	     Config, [], []),
    %% With Arg set to [] so neither clause matches
    [{warn_return_no_exit,{_,3},_},
     {warn_matching,{_,6},_},
     {warn_failing_call,{_,7},_}] =
	test([{attribute,1,module,foo},
	      {attribute,2,export,[{bar,0}]},
	      {function,3,bar,0,
	       [{clause,3,[],[],
		 [{match,4,{var,4,'Arg'},{nil,4}},
		  {'case',[{location,5},{generated,true}],{var,5,'Arg'},
		   [{clause,[{location,6},{generated,true}],[{map,6,[]}],[],
		     [{atom,6,map}]},
		    {clause,[{location,7},{generated,true}],[{var,7,'_'}],[],
		     [{call,7,{remote,7,{var,7,'Arg'},{atom,7,fn}},[]}]}]}]}]}],
	     Config, [], []),
    ok.

test(Prog0, Config, COpts, DOpts) ->
    Prog = erl_parse:anno_from_term(Prog0),
    {ok, BeamFile} = compile(Config, Prog, COpts),
    run_dialyzer(Config, succ_typings, [BeamFile], DOpts).

compile(Config, Prog, CompileOpts) ->
    OutDir = ?config(priv_dir, Config),
    Opts = [{outdir, OutDir}, debug_info, return_errors | CompileOpts],
    {ok, Module, Source} = compile:forms(Prog, Opts),
    BeamFile = filename:join([OutDir, lists:concat([Module, ".beam"])]),
    ok = file:write_file(BeamFile, Source),
    {ok, BeamFile}.

run_dialyzer(Config, Analysis, Files, Opts) ->
    OutDir = ?config(priv_dir, Config),
    PltFilename = dialyzer_common:plt_file(OutDir),
    dialyzer:run([{analysis_type, Analysis},
		  {files, Files},
		  {init_plt, PltFilename},
		  {check_plt, false},
		  {from, byte_code} |
		  Opts]).
