#!/usr/bin/perl

use strict;
use warnings;

use Template;
use Getopt::Long;
use List::Util 'shuffle';
use Data::Dumper;

my $usage = "usage: generate_number_puzzle.pl --datafile=puzzle-numbers01.dat";

my ($datafile);
die $usage unless GetOptions(
	'datafile=s'  => \$datafile,
);
$datafile ||= 'data/puzzle-numbers01.dat';
my $backup_datafile = 'data/addition_to_10-bkp.dat';

my $template_config = {
	INCLUDE_PATH    => ["."],
};

my $meta = get_meta_data($datafile);
print Dumper($meta);
my $formulas_datafile = 'data/' . $meta->{formulas};
my $answer = $meta->{answer};

my $required_letters = get_required_letters($answer);
my ($formulas, $letter_key) = get_formulas($formulas_datafile, $required_letters, $backup_datafile);
my $answer_format = get_answer_format($answer, $letter_key);

my $template_vars = {
	meta       => $meta,
	formulas   => $formulas,
	letters    => $required_letters,
	answer_format    => $answer_format,
};
print Dumper($template_vars);
exit;

my $tt = Template->new($template_config);
$tt->process('puzzle.tt', $template_vars);
exit;

sub get_meta_data
{
	my ($datafile) = @_;
	my $meta;
	
	open META_FH, "<:raw", $datafile;
	while (my $line = <META_FH>)
	{
		chomp $line;
		my ($key, $value) = split(/:\s+/, $line, 2);
		$key = lc($key);
		$meta->{$key} = $value;
	};
	return $meta;
}

sub get_formulas
{
	my ($datafile, $required_letters, $backup_datafile) = @_;
	my $count = scalar(@$required_letters);
	my $possible_formulas;
	my $formulas;
	my $letter_key;

	open META_FH, "<:raw", $datafile;
	while (my $line = <META_FH>)
	{
		chomp $line;
		my ($key, $value) = split(/\s+/, $line, 2);
		push (@{ $possible_formulas->{$key}}, $value);
	}
	close(META_FH);
	my @answers = shuffle(keys %$possible_formulas);
	
	my $i = 0;
	while ($i < $count)
	{
		my $answer = $answers[$i];
		last unless $answer;
		my $question = shuffle(@{$possible_formulas->{$answer}});
		
		# Put a & at the begining and end, and swap the spaces for '&'
		(my $formatted_question = '&' . $question . '&') =~ s/ /\&/g;
		
		push(@$formulas, { 
			answer => $answer, 
			question => $question, 
			formatted_question => $formatted_question,
			letter => $required_letters->[$i],
		});
		$letter_key->{$required_letters->[$i]} = $answer;
		$i++;	
	}
	if ($i < $count)
	{
		# We don't have enough questions
		die "We don't have enough questions" unless $backup_datafile;
		
		open META_FH, "<:raw", $backup_datafile;
		while (my $line = <META_FH>)
		{
			chomp $line;
			my ($answer, $question) = split(/\s+/, $line, 2);
			
			# Put a & at the begining and end, and swap the spaces for '&'
			(my $formatted_question = '&' . $question . '&') =~ s/ /\&/g;
			
			push(@$formulas, { 
				answer => $answer, 
				question => $question, 
				formatted_question => $formatted_question,
				letter => $required_letters->[$i],
			});
			$letter_key->{$required_letters->[$i]} = $answer;
			$i++;
			last unless $required_letters->[$i];
		}
	}
	return ($formulas, $letter_key);
}

sub get_required_letters
{
	my ($string) = @_;
	my $letters;
	
	# Remove whitespace and upper case
	$string =~ s/\s+//g;
	$string = uc($string);
	
	# Split, and store as hash
	my @all_letters = split(//, $string);
	$letters->{$_} = 1 foreach @all_letters;
	my @uniq_letters = sort keys %$letters;
	return \@uniq_letters;
}

sub get_answer_format
{
	my ($answer_string, $letter_key) = @_;
	my $answer_format;
	
	# Split to determine size
	my @all_letters = split(//, $answer_string);
	
	my $line = 0;
	my $line_size = 0;
	foreach my $letter (@all_letters)
	{
		$letter = uc($letter);
		my $answer = $letter_key->{$letter};
		$line_size++;
		if ($letter eq ' ')
		{
			$line_size++;
			if ($line_size > 16)
			{
				$line++;
				$line_size = 0;
			}
			$answer = ' ';
		}
		push (@{$answer_format->[$line]}, $answer);
	}
	return $answer_format;
}
