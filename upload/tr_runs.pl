#!/usr/bin/perl -w

use strict;
use lib qw(. lib);

use Bugzilla;
use Bugzilla::Config;
use Bugzilla::Error;
use Bugzilla::Constants;
use Bugzilla::Util;
use Bugzilla::User;
use Bugzilla::Testopia::Util;
use Bugzilla::Testopia::Search;
use Bugzilla::Testopia::Table;
use Bugzilla::Testopia::TestRun;
use Bugzilla::Testopia::Constants;

#Bugzilla->login(LOGIN_REQUIRED);

# prevent DOS attacks from multiple refreshes of large data
#$::SIG{TERM} = 'DEFAULT';
#$::SIG{PIPE} = 'DEFAULT';
my $userid = login_to_id("carmark.dlut\@gmail.com");
Bugzilla->set_user(new Bugzilla::User($userid));

my %param_hash = (
					action		=> '',
					plan_id		=> 0,
					run_id		=> 0,
					build		=> undef,
					environment	=> undef,
					new_build	=> undef,
					new_env		=> undef,
					manager		=> undef,
					summary		=> undef,
					notes		=> '',
					target_pass	=> undef,
					target_completion	=> undef,
					getall		=> undef,
					case_ids	=> undef,
				);

sub printUserError{
	my $type = shift;
	my $content = shift;
	print "ERROR:$type: $content\n";
	exit(0);
}

### Create TestRun
sub create_run($){
	my $param = shift;

	my $planid = $param->{plan_id};
	my $plan = Bugzilla::Testopia::TestPlan->new($planid);
	my $prod_version = $param->{prod_version} ? $param->{prod_version} : $plan->product_version();
	my $build    = trim($param->{build});
	my $env      = trim($param->{environment});
	
	### create Build by create method
	if ($param->{new_build}){
		my $b = Bugzilla::Testopia::Build->create({
				'name'        => $param->{new_build},
				'milestone'   => '---',
				'product_id'  => $plan->product_id,
				'description' => '',
				'isactive'    => 1, 
		});
		$build = $b->id;
	}

	### create Environment by create method
	if ($param->{new_env}){
		my $e = Bugzilla::Testopia::Environment->create({
				'name'        => $param->{new_env},
				'product_id'  => $plan->product_id,
				'isactive'    => 1,
		});
		$env = $e->id;
	}
	
	### create TestRun by create method
	my $run = Bugzilla::Testopia::TestRun->create({
			'plan_id'           => $plan->id,
			'environment_id'    => $env,
			'build_id'          => $build,
			'product_version'   => $prod_version,
			'plan_text_version' => $plan->version,
			'manager_id'        => $param->{manager},
			'summary'           => $param->{summary},
			'notes'             => $param->{notes} || '',
			'target_pass'       => $param->{target_pass},
			'target_completion' => $param->{target_completion},
			'status'            => 1,
	});
	
	### Insert case_run 
	if ($param->{getall}){
		my $cgi = Bugzilla->cgi;
		$cgi->param('plan_id', $plan->id);
		$cgi->param('current_tab', 'case');
		$cgi->param('case_status', 'CONFIRMED');
		$cgi->param('viewall', 1);
		my $search = Bugzilla::Testopia::Search->new($cgi);
		my $ref = Bugzilla->dbh->selectcol_arrayref($search->query);
		foreach my $case_id (@$ref){
			$run->add_case_run($case_id) or printUserError("Testopia:tr_runs.pl.create: ",$!);
		}
		printUserError("Testopia:tr_runs.pl.create: ",$search->query);
	}
	else {
		foreach my $case_id (split(',', $param->{case_ids})){
			$run->add_case_run($case_id);
		}
	}
	print "{success: true, run_id: " . $run->id ."}"; 
}

### Update TestRun
sub update_run(){
	my $param = shift;
	my $run_id = $param->{run_id};
	printUserError("Testopia:tr_runs.pl.update_run: ", "Test Run id is none") unless($run_id);

    my $run = Bugzilla::Testopia::TestRun->new($run_id);

	$run->set_manager($param->{manager}) if $param->{manager};
	$run->set_build($param->{build}) if $param->{build};
	$run->set_environment($param->{environment}) if $param->{environment};
	$run->set_target_pass($param->{target_pass}) if $param->{target_pass};
	$run->set_target_completion($param->{target_completion}) if $param->{target_completion};

	$run->update();
            
    printUserError('Testopia.tr_runs.pl:update_runs',  "TestRun $run_id can not editable ") unless($run->canedit);
    print "Success:Testopia.tr_runs.pl:update_runs\n";   
}

### main function for test runs
sub main(){
	$param_hash{plan_id} = 1;
	$param_hash{run_id} = 25;
	$param_hash{build} = 2;
	#$param_hash{environment} = 1;
	#$param_hash{manager} = $userid;
	$param_hash{summary} = 'test run 11';
	$param_hash{notes} = 'test search';
	#$param_hash{target_pass} = '';
	#$param_hash{target_completion} = '';
	$param_hash{getall} = 1;
	#$param_hash{case_ids} = "1,";

	#&create_run(\%param_hash);
	&update_run(\%param_hash);
}

&main();
