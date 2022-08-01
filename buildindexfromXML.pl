=pod 

=head1 NAME

<buildindexfromXML.pl> takes XML file(s) and produces files with segmentation of texts, paragraphs, sentences, tokens

=head1 VERSION

Draft Version

=head1 SYNOPSIS

A - Preprocessing
- takes XML file (flag -i InputFilename) or a directory with XML files (flag -d InputDir/). The outputfile name is automatically created.
- strips XML tags starting from tag <$textstring>, e.g. "document" and enumerates texts and paragraphs. Output in Filenam.sen .
- invokes a tokenizer (augmented Tokenizer of Dipper) with a list of abbreviations. Output in Filename.tok .
- finds multiword entities by a list of multiwordlexemes (flag -m MWLFilename). Output in Filename.tokmwl .
- repairs words with special characters, e.g. Eckventil(e). Flag -r, output in Filename.tokrmwl .
- if Filename.tokmwl exists, you can start with the repair by flag -swr.  
- creates a file of the format textnumber#paragraphnumber#sentencenumber#wordnumber#token\n . Output in Filename.tokwot
- if Filename.tokrmwl exists, you can start with creating Filename.tokwot by flag -ji.


B - Generation of indices
- in default mode, for the sake of speed, a mix of shell, awk and perl commands are invoked.
- if you prefer or have to skip this mode, choose flag -no. Caution: for big data, this can be extremely time-consuming.

For the tokenised corpus in Filename.tokwot
- builds inverted index, output in Filename_invertedtextindex.out
- sorts/uniqs this, output in Filename_invertedtextindexintermediate.out, then delete beginning whitespaces of this file
- changes and formats the columns, output in Filename Filename_invertedtextindexsorted.out
- creates the general text index of the format Token/tTextno#Textno[...], output in Filename_invertedgeneralindex.out 

If chosen to build the indexes for each text of the TOKENIZED file (flag -bi)
- creates a subdirectory Tokenscorpus, copies Filename_tokwot into it and creates for each text a file (name FILENO) with tokens

If chosen to build the indexes for each text of the LEMMATIZED file (flag -blif Filename.lemmas)
- you need a file with the lemmatized corpus of the format textnumber#paragraphnumber#sentencenumber#wordnumber#token\n . 
  You could create it with the treetagger or other programs:  Inputfilename: Filename.lemmas
- creates a subdirectory Lemmascorpus, copies Filename_lemmas into it and creates for each text a file (name FILENO) with tokens
- for the further processing, the program 
- builds inverted index, output in Filename.lemmas_invertedtextindex.out
- sorts/uniqs this, output in Filename.lemmas_invertedtextindexintermediate.out, then delete beginning whitespaces of this file
- changes and formats the columns, output in Filename Filename.lemmas_invertedtextindexsorted.out
- processes ambiguous lemmatization, e.g. Zweifel|Zweifeln, by creating two entries, 
  outputfile: Filename.lemmas_invertedtextindexsorted.out_repaired
- creates the general text index of the format Lemma/tTextno#Textno[...], output in Filename.lemmas_invertedgeneralindex.out 

If chosen to build the MERGED indexes for each text of the tokenized and the lemmatized files (flag -merge Filename.lemmas)
- you need a file with the lemmatized corpus of the format textnumber#paragraphnumber#sentencenumber#wordnumber#token\n,
  e.g. Filename.lemmas .
- the indexes for each text must exist (subdirectories: Tokenscorpus, create by flag -bi; Lemmascorpus: create by flag -blif)
- creates a subdirectory Mergedcorpus and creates for each text a file (name FILENO) with tokens and lemmas
- for the further processing, the program uses Filename.lemmas (same as for blif) as basename, and
- creates the general text index of the format LemmaorToken/tTextno#Textno[...] by appending and resorting the general text index
  of Filename_invertedgeneralindex.out and Filename.lemmas_invertedgeneralindex.out. Intermediate files:
  Filename_invertedgeneralindexintermediatelemmasandtokens.out and Filename_invertedgeneralindexmergeddoubles.out
  Output in Filename_invertedgeneralindexmerged.out 

=head1 CALLS:

COMPLETE
nohup perl buildindexfromXML.pl -m multiwordlexemes -r -bi -merge wpd15.i5.xml.lemmas -blif wpd15.i5.xml.lemmas -i wpd15.i5.xml -ts idsCorpus/idsDoc/idsText > out1008 &

Variant of COMPLETE
nohup perl buildindexfromXML.pl -i wpd15.i5.xml -ts 'idsCorpus/idsDoc/idsText' -m multiwordlexemes -r -bi -blif wpd15.i5.xml.lemmaindex -merge wpd15.i5.xml.lemmaindex > out2708 &

WITHOUT generating lemmatized and merged indices
nohup perl buildindexfromXML.pl -m multiwordlexemes -r -bi -i wpd15.i5.xml -ts idsCorpus/idsDoc/idsText > outputfile &

START with repair
nohup perl buildindexfromXML.pl -swr -r -swr -bi -merge wpd15.i5.xml.lemmas -blif wpd15.i5.xml.lemmas -i wpd15.i5.xml -ts idsCorpus/idsDoc/idsText > out1008 &

START with repair
nohup perl buildindexfromXML.pl -r -swr  -bi -merge subcorpus_10_document_1.xml.lemmas -blif subcorpus_10_document_1.xml.lemmas -d Boschfiles/ > out0808 &

START with Index
# nohup perl buildindexfromXML.pl -ji -bi -merge wpd.i5.xml.lemmas -blif wpd.i5.xml.lemmas -i wpd.i5.xml > out1008 &

=head1 OPTIONS

see buildindexfromXML.pl -h

=head1 DIRECT SUBROUTINES

=head2 process_text_with_twig

iterates through huge XML data and prints out (relatively) clean code. Counts texts and paragraphs, one sentence per line

=head find_mwl

looks for multiword items
and also for words which have multiword items as a part


=head2 repair_quotesetc

repair words with quotes, parentheses and multi-word units as first parts

=head2 buildindices

takes a file of the format TeXTNR#1#1#1#token\n
for each text it creates a file with the frequency counts in it
and stores the file TEXTNR in $pathcorpus

=head2  repairdoublelemmas

repair entries with ambiguous lemma information, e.g. "Bohnenspross|Bohnensprosse 1049175	1"
create a new entry for each analysis

=head2 mergeindices

Takes two directories: 1 with files with tokens, 2 with files with lemmas (format: Token/Lemma#freq)
and creates a synopsis for each pair of file in /Mergedcorpus

=head2 remove_duplicates_insecondcol

For every tab-segmented line with two columns, this sorts and unifies the entries of the second column (delimiter #)


=head1 DIAGNOSIS

File $sFileName could not be opened - check for path and name
File is created but empty, check sleep and wait processes


=head1 CONFIGURATION AND ENVIRONMENT

Linux or Unix-like environments

=head1 INCOMPATABILITIES

Not known


=head1 BUGS AND LIMITATIONS

=head1 AUTHOR(S)

Petra Steiner
=head1 COPYRIGHT

Distribution only by Petra Steiner

=cut

#!/usr/bin/perl -w 

use strict;
use warnings;
use DB_File;
use Fcntl;
use Tie::File;

use MLDBM qw (DB_File FreezeThaw);
use Encode qw (encode decode);
use FreezeThaw;

use Data::Dumper qw(Dumper);

use List::Util qw(first);
use List::MoreUtils qw(first_index indexes);
    
$Data::Dumper::Useqq = 1;

use DBM_Filter;

use I18N::Langinfo qw(langinfo CODESET);
my $codeset = langinfo(CODESET);

# print "Codeset: $codeset\n\n";

use Encode qw(decode);

@ARGV = map { decode $codeset, $_ } @ARGV;

#no warnings 'utf8';
use utf8::all;
use open ':utf8';
#use utf8;
use open qw(:encoding(UTF-8));

use Getopt::Long;
use Cwd;
use File::Basename;
use File::Path qw(make_path);
use File::Copy;
use locale;

binmode STDIN, ":encoding(UTF-8)";
binmode STDOUT, 'utf8';
binmode STDERR, ":encoding(UTF-8)";

select(STDERR);
$| = 1;
select(STDOUT);
$| = 1;

use XML::Twig;
use XML::Entities;

use Sort::Key::Natural qw(natkeysort);

use List::MoreUtils qw(uniq apply indexes);

BEGIN { our $start_run = time(); }


my($sInputFilename,
   $sInputDir,
   @aFileList,
   $sSentenceFilename,
   $sTokenFilename,
   $sTokenwithoutTagsFilename,
   $sMWLFilename,
   $srepairedMWLFilename,
   $sMWLTokenFilename,
   $itokens,
   $SOUTPUT,
   $line,
   $help,
   $helpfile,
   $repair,
   $startwithrepair,
   $justindex,
   $noawk,
   @args,
   $buildtextindices,
   $buildlemmaindexfile,
   $mergeindices,
   $repairdoublelemmas,
   $pathtokenscorpus,
   $textstring,
   $ntext,
   $counter,
   $ntextbefore,
   $nsentence,
   $nparagraph,
   $ntextparagraph,
   $nhead,
   $nparagraphscomplete,
   @anodestodelete,
   @atextsigles,
   $textsigle,
   $textsiglestring,
   $countstring,
   $textbodystring,
   $ntextbody,
   $pr,
@atextbodies,
   $textbody,
   $paragraphstring,
   @aparagraphstrings,
   @asentences,
   $decodedsentence,
   @asentencesoutput,
   $sentencestring,
   $sentenceindex,
   $sentence,
   $soutputsentence,
   $spuresentence,
   @tagsinsentence,
   @tagnames,
   @alltagsinsentence,
   $headstring,
   @aheadorparagraphs,
   $headorparagraph,
   $nodename,
   $parser,
   $ref_list,
   $base,
   $base1, # the main base
   $pathname,
   @alist,
   @keys,
   $key,
   $value,
   $cmd,
   %halltokens,
   %htokenfreqsintext,
   $hashfilealltokens,
   $outputalltokens,
   $outputjustalltokens,
   $outputjustalltokenswithoutdigits,
   %hindextexts,
   $hashfileindextexts,
   $outputindextexts,
   $skey,
   %hindexparagraphs,
   $hashfileindexparagraphs,
   $outputindexparagraphs,
   %hindexsentences,
   $hashfileindexsentences,
   $hashfiletextlengthintoken,
   $hashfileinvertedtextindex,
   $hashfileinvertedtextindexsorted,
   %hinvertedtextindex,
   $outputfiletextlengthintoken,
   $outputfileinvertedtextindex,
   $outputfileinvertedtextindexlemmas,
   $outputfileinvertedtextindexintermediate,
   $outputfileinvertedtextindexintermediatelemmas,
   $outputfileinvertedgeneralindexlemmas,
   $outputfileinvertedgeneralindexintermediatelemmas,
   $outputfileinvertedgeneralindexintermediatelemmasandtokens,
   $outputfileinvertedgeneralindexmergeddoubles,
   $outputfileinvertedgeneralindexmerged,
   $outputfileinvertedtextindexsorted,
   $outputfileinvertedtextindexsortedlemmas,
   $outputfileinvertedgeneralindex,
   $outputfilerepaireddoubles,
   $outputindexsentences,
   $token, 
   $ntokencount,
   $ntokenintext,
   $nsentencecount,
   $nparagraphcount,
   $ntypescount,
   $db1,
   $db2,
   $db3,
   $db4,
   $db5,
   $db6,
   $flag,
   $ntoken,
   %hMWL,
   $firstpart,
   $rest, 
   @restlist,
   $ref_restlist,
   @list,
   @tokenlist,
   $ref_tokenlist,
   @tokenlist2,
   @possiblestartsofoverlap,
   @matches,
   @exactmatches,
   @all_matches,
   @partmatches,
   @store_exactmatches,
   $flagmwl,
   $flagpossibleoverlap,
    );

our ( $nallheadorparagraphs,
      $nallsentences,
    );

# possible defaults:
$sInputFilename = "mld.i5.xml";
#$sInputFilename = "wpd15.i5.xml";
#$sInputFilename = "/home/steiner/programs/Perl/Texts/mld.i5.xml";

$helpfile = "buildindexfromXML.help";

# default for IDS corpora
$textstring = 'idsCorpus/idsDoc/idsText';

# default for other corpora
#$textstring = 'document';

$base1 = basename($sInputFilename);
$pathname = cwd();

# possible defaults
# $justindex = 1;

# if you like to produce a lot of index stuff
#$noawk = 1;

#if you uncomment this, word with quotes etc. in this files will recognized and repaired
# $repair = 1;

#if you uncomment this/leave this uncommented, no textindices will be build
#$buildtextindices = 1;

#if you uncomment this/leave this uncommented, multiwords in this files will recognized

$sMWLFilename = "multiwordlexemes";

GetOptions(
    'i=s' => \$sInputFilename,
    'd=s' => \$sInputDir,
    't=s' => \$sTokenFilename,
    's=s' => \$sSentenceFilename,
    'm=s' => \$sMWLFilename,
    'r' => \$repair,
    'no' => \$noawk,
    'swr' => \$startwithrepair,
    'bi' => \$buildtextindices,
    'blif=s' => \$buildlemmaindexfile,
    'merge=s' => \$mergeindices, # input: buildlemmaindexfile
    'ts=s' => \$textstring,
    'ji' => \$justindex,
    'h' =>  \$help,
    );

if ($help)
{
    # print "Helpfile: $helpfile";
    open (HELP, '<', $helpfile) or die "couldn't open $helpfile: $!"; 
    while (<HELP>) 
    {print $_}; 
    close HELP;
    exit;
 }

$base1 = basename($sInputFilename);
$pathname = cwd();
@aFileList = ();

push(@aFileList, $sInputFilename);  # for sake of consistency, just one filename inside the array
 
if ($sInputDir) 
{
    $pathname = cwd();
    chdir $sInputDir or die "chdir $sInputDir: $!";
    @aFileList = glob ("*.xml");
    #    $pathname = dirname($aFileList[0]);
    $base1 = basename($aFileList[0]);
}

$base = $base1;
print "(First) inputfile $base, output to $pathname\n";

unless ($sSentenceFilename)
{
    $sSentenceFilename = "$pathname\/$base\.sen";
}

unless ($sTokenFilename)
{    
    $sTokenFilename = "$pathname\/$base\.tok";
}

$sMWLTokenFilename = "$pathname\/$base\.tokmwl";

unless ($textstring)
{
    $textstring = 'idsCorpus/idsDoc/idsText'; # for IDS texts
    #$textstring = 'document';
}

unless ($srepairedMWLFilename)
{
    $srepairedMWLFilename = "$pathname\/$base\.tokrmwl";
}

unless ($sTokenwithoutTagsFilename)
{
    $sTokenwithoutTagsFilename =  "$pathname\/$base\.tokwot";
}

$hashfiletextlengthintoken = "$pathname\/$base\.textlengths";

$hashfileindextexts = "$pathname\/$base\_indextexts\_hash";
$hashfileindexparagraphs = "$pathname\/$base\_indexparagraphs\_hash";
$hashfileindexsentences = "$pathname\/$base\_indexsentences\_hash";
$hashfilealltokens = "$pathname\/$base\_alltokens\_hash";

$hashfileinvertedtextindex = "$pathname\/$base\_invertedtextindex\_hash";
$outputfileinvertedtextindex = "$pathname\/$base\_invertedtextindex.out";

$hashfileinvertedtextindexsorted = "$pathname\/$base\_invertedtextindexsorted\_hash";

$outputfileinvertedtextindexsorted =  "$pathname\/$base\_invertedtextindexsorted.out";
$outputfileinvertedtextindexintermediate =  "$pathname\/$base\_invertedtextindexintermediate.out";
$outputfileinvertedgeneralindex =  "$pathname\/$base\_invertedgeneralindex.out";

$outputfiletextlengthintoken = "$pathname\/$base\_tokenfreqsoftexts.out";
$outputindextexts = "$pathname\/$base\_indextexts.out";
$outputindexparagraphs = "$pathname\/$base\_indexparagraphs.out";
$outputindexsentences = "$pathname\/$base\_indexsentences.out";
$outputalltokens =  "$pathname\/$base\_alltokens.out";
$outputjustalltokens =  "$pathname\/$base\_justalltokens.out";
$outputjustalltokenswithoutdigits = "$pathname\/$base\_justalltokenswithoutdigits.out";


if ($startwithrepair)
{
    print "Start directly with repair for $sTokenFilename\n";
    goto REPAIR_FLAG;
}

if ($justindex)
{
    $sTokenFilename = $srepairedMWLFilename;
 #   print "Indexes for $sTokenFilename\n";
    goto PRODUCE_INDEX;
}


open($SOUTPUT, '>', $sSentenceFilename) or die; #for output with sentences in numbered text-paragraph units

print "Parsing of the XML file(s) starts.\n";

$ntext = 1;
$nallheadorparagraphs = 0;
$nallsentences = 0;

if ($sInputDir)
{
    foreach $sInputFilename (@aFileList)
    {
	
	$parser = XML::Twig->new(
	    twig_handlers => 
	    {$textstring => sub {process_text_with_twig( @_, $ntext, $SOUTPUT)} });
	
	$parser->parsefile($sInputFilename);
	
	print "\nParsing for $sInputFilename (textno $ntext) finished. Created clean code in $sSentenceFilename\n";
	
	print "\nProcessed $ntext texts with $nallheadorparagraphs heads or paragraphs, and $nallsentences sentences.\n";
	
	$ntext++;
	
	#$parser->purge;
	$parser->dispose;
    }
}

if ($sInputFilename)
{
    $parser = XML::Twig->new(
	twig_handlers => 
	{$textstring => sub {process_text_with_twig( @_, $ntext++, $SOUTPUT)} });
	
    $parser->parsefile($sInputFilename);
	
    print "\nParsing for $sInputFilename (textno $ntext) finished. Created clean code in $sSentenceFilename\n";
    
    print "\nProcessed $ntext texts with $nallheadorparagraphs heads or paragraphs, and $nallsentences sentences.\n";
        
    #$parser->purge;
    $parser->dispose;
    #$textstring = "";
    
}

    
close($SOUTPUT);

chdir $pathname;

# tokenize
# the command is: 
# perl tokenize.perl -x -z -a abbrev.lex mld.i5.xml.sen mld.tok2

print "\n\nStarting the tokenizer.\n";

$cmd = qq(perl tokenize.perl \-x \-z \-a abbrev.lex $sSentenceFilename $sTokenFilename);
print "\nCMD: $cmd\n";
`$cmd`;

print "Output file: $sTokenFilename\n";

if ($sMWLFilename)   
{

### first: read multiword lexemes into a hash

    %hMWL = ();
   open $itokens, '<', $sMWLFilename or die "Could not open $sMWLFilename: $!";    
    print "Creating the hash with multiword units\n";
    
    while ($line = <$itokens>)
    {
	$line =~ s/\r?\n$//; # just in case it comes from windows
	chomp $line;
	if ($line=~ /(.*?)\s(.*)/)
	{
	    $firstpart = $1;
	    $rest = $2;
#	    print "First: $firstpart, rest: $rest\n";
	    # the key is the first part, but it is possible that there are more than one multiword units
	    if (exists $hMWL{$firstpart})
	    {
		@restlist = @{$hMWL{$firstpart}};				 
		push(@restlist, $rest);
		@list = uniq (sort @restlist);
		@{$hMWL{$firstpart}} = @list;
	    }
	    else
	    {

		push(@{$hMWL{$firstpart}}, $rest); 
	    } 
	}
    }

    close $itokens;
    @restlist = ();
    print "Finished creating the hash with multiword units\n";

##### second: check tokenized file for multiword units and glue them together as tokens

    open $itokens, '<', $sTokenFilename or die "Could not open $sTokenFilename: $!";
    
    open (OUTPUT, '>', $sMWLTokenFilename) or die "Could not open $sMWLTokenFilename: $!";

    @tokenlist = ();
    @store_exactmatches = ();

    print "Finding multi-word units, writing to $sMWLTokenFilename \n";
    $ntokencount = 0;
    $nparagraphcount = 0;
    $nsentencecount = 0;
    
    while ($line = <$itokens>)
    {
	chomp $line;
	$line =~ s/\&amp\;/\&/g;
	$line =~ s/\&lt\;/\</g;
	$line =~ s/\&gt\;/\>/g;
	
#	$line =~ s/(\<tok\>.+)\"(.*)/$1$2/g; # remove quotes left in tokens, if it is not at the start
	
	$token = $line;
	if ($line =~ m/sent\_bound/)
	{
	    $nsentencecount++;
	}	       
	while ($token =~ s/<\S[^<>]*(?:>|$)//gs) {};
#	print "Token: $token\n";

	if ($token =~ m/\d+\#\d+/)
	{
	    $nparagraphcount++;
	}
	else
	{
	    $ntokencount++;
	}
	
	$token =~ s/ +//g;
	
	if ($flagmwl) # sth has been found before
	{
	    # first check for possible overlap
	    if (exists $hMWL{$token})
	    {
		$flagpossibleoverlap = 1;
		push (@possiblestartsofoverlap, $token);
		# print "Possiblestartsofoverlap: @possiblestartsofoverlap \n";		
	    }

	    # check if this token is the start of one of the strings in restlist
	    
	   # print "MWLToken: $token Restlist: @restlist\n";

	    @exactmatches = grep { /^\Q$token\E$/ } @restlist;
	   # print "Exact matches: @exactmatches\n";

	    #@all_matches = grep { /^\Q$token\E/ } @restlist;
	    #print "All matches: @all_matches\n";

	    # Boeing 747-Flotte
	    #Token in MWL hash: Boeing, Restlist: 737-300 747 747-400 747F
	    #747-Flotte
	    
	    @partmatches = ();

	    $token =~ /^(.*?)[\-\.\\]/;
	    $firstpart = $1; # e.g. 747

	    if ($firstpart)
	    {
		@partmatches =  grep { /^\Q$firstpart\E$/ } @restlist;
		# print "Part: $firstpart, token: $token, Partial matches: @partmatches\n";
	    }
	    
	    @matches = grep { /^\Q$token\E\s/ } @restlist;
	    # print "Matches: @matches\n";

	    if (@exactmatches && @matches) # exact match found for this token and a multiword unit and longer match is still possible
	    {

		push (@tokenlist, $token);
		#print "Old restlist: @restlist\n";
		@store_exactmatches = @exactmatches; # store the exact match in case that this is the end of the search path
		
		@restlist = apply {$_ =~ s/^$token //} @matches;
		#print "New restlist: @restlist\n";
	    }

	    
	    elsif (@exactmatches) # only one and exact match found for this token - a multiword unit
	    {
		print OUTPUT " <tok>@tokenlist $token</tok>\n";
		@tokenlist = ();
		@possiblestartsofoverlap = ();
		@store_exactmatches = (); 
		undef $flagmwl;
		undef $flagpossibleoverlap;
		@restlist = ();
	    }    

	    elsif (@partmatches) # partial match found for this token - a multiword unit or punctuation mark
	    {
		if ($token =~ /^(.*?)[\.]/)
		{
		    print OUTPUT " <tok>@tokenlist $firstpart</tok>\n<tok>.</tok>\n<sent_bound/>\n";
		}
		else
		{
		    print OUTPUT " <tok>@tokenlist $token</tok>\n";
		}
		@tokenlist = ();
		@possiblestartsofoverlap = ();
		@store_exactmatches = ();
		undef $flagmwl;
		undef $flagpossibleoverlap;
		@restlist = ();
	    }    
	    
	    elsif (@exactmatches) # only one and exact match found for this token - a multiword unit
	    {
		print OUTPUT " <tok>@tokenlist $token</tok>\n";
		@tokenlist = ();
		@possiblestartsofoverlap = ();
		@store_exactmatches = (); 
		undef $flagmwl;
		undef $flagpossibleoverlap;
		@restlist = ();
	    }    
	    
	    elsif (@matches) # it could be the first part of a multiword unit
	    {
		push (@tokenlist, $token);
		# remove token+whitespace from elements of matches
		@restlist = apply {$_ =~ s/^$token //} @matches; # delete this token from the restlist
		# print "New matches: @restlist\n";
	    }
	    
	    #nothing found for this token

	    else
	    {
		# but found an MWL for the tokens before
		if (@store_exactmatches)
		{
		    # first print out this as MWL
		   # print "store_exactmatches: @store_exactmatches\n";
		    print OUTPUT " <tok>@tokenlist</tok>\n";
		    @tokenlist = ();
		    @possiblestartsofoverlap = ();
		    @store_exactmatches = ();
		    undef $flagmwl;
		    undef $flagpossibleoverlap;
		    @restlist = ();
		    # check if token could be the start of a new multiword lexeme ("Lufthansa" in "Die Lufthansa")
		    if (exists $hMWL{$token})
		    {
		# in this case start searching with a new restlist, of the recent token	   
			@restlist = @{$hMWL{$token}};
			push (@tokenlist, $token);
			# print "Token in MWL hash: $token, Restlist: @restlist\n";
			$flagmwl = 1;
		    }
		    else
		    {
			print OUTPUT " <tok>$token</tok>\n";
		    }
		}

		# no mwl before but check if one the tokens in tokenlist could be the start of a new multiword lexeme ("Lufthansa" in "Die Lufthansa A.E.R.O. GmbH")
	
		elsif ($flagpossibleoverlap)
		{
		    @restlist = ();
		    
		   # print "PSOO: @possiblestartsofoverlap tokenlist: @tokenlist\n";
		    my $possiblefirstoverlap = shift @possiblestartsofoverlap;
		    
		    unless (@possiblestartsofoverlap) # was last in array
		    {
			undef $flagpossibleoverlap;
		    }
			
		    # print "possiblefirstoverlap: $possiblefirstoverlap\n";
		    # in this case print out everything before the first token of overlap
		    @tokenlist2 = @tokenlist;
		    while ($_= shift(@tokenlist2))
		    {
			# print "Token of tokenlist2: $_\n";
			unless ($_ eq $possiblefirstoverlap)
			{
			    print OUTPUT " <tok>$_</tok>\n";			    
			}
			
			# later (general): check if tokenlist is empty
			# now: deal with the rest of tokenlist, do it in a sub
			else # found possible overlap
			{
			    # print "restlist before @restlist\n";
			    ($ref_tokenlist, $ref_restlist) = find_mwl($token, $_, @tokenlist2);
			    #e.g. token: Business $_ : Lufthansa,  " "
			    # , International, ""
			    @tokenlist = @$ref_tokenlist;
			    @restlist = @$ref_restlist;
			    #print "New tokenlist: @tokenlist\n";
			    # e.g. Lufthansa Business
			    
			    if ((! @tokenlist2) && (! @restlist) && (exists $hMWL{$token}))
			    {
			     #	print "#else\n";
				@possiblestartsofoverlap = ();
				undef $flagpossibleoverlap;
				@tokenlist = ();
				@restlist = @{$hMWL{$token}};
				push (@tokenlist, $token);
				# print "Token in MWL hash: $token, Restlist: @restlist\n";
				#flag to 1
				$flagmwl = 1;
				undef $flagpossibleoverlap;
			    }
			    elsif ($flagpossibleoverlap) # other overlaps
			    {
				$possiblefirstoverlap = shift @possiblestartsofoverlap;
				unless (@possiblestartsofoverlap) # was last in array
				{
				    undef $flagpossibleoverlap;
				}
			    }
			    else # no other overlaps
			    {
				undef $flagpossibleoverlap;
				last;
			    }			    
			}
		    }
		    
		    if ((! @tokenlist2) && (! @restlist) && (exists $hMWL{$token}))
		    {
			# print "#else\n";
			@possiblestartsofoverlap = ();
			undef $flagpossibleoverlap;
			@tokenlist = ();
			@restlist = @{$hMWL{$token}};
			push (@tokenlist, $token);
			# print "Token in MWL hash: $token, Restlist: @restlist\n";
			#flag to 1
			$flagmwl = 1;
			undef $flagpossibleoverlap;
		    }
		}    
		
		# no mwl before but check if token could be the start of a new multiword lexeme ("Lufthansa" in "Die Lufthansa")
		elsif (exists $hMWL{$token})
		{
		    # in this case print only tokenlist and start searching with a new restlist
		    foreach (@tokenlist)
		    {
			print OUTPUT " <tok>$_</tok>\n";
		    }
		    @possiblestartsofoverlap = ();
		    undef $flagpossibleoverlap;
		    @tokenlist = ();
		    @restlist = @{$hMWL{$token}};
		    push (@tokenlist, $token);
		   # print "Token in MWL hash: $token, Restlist: @restlist\n";
		    #flag to 1
		    $flagmwl = 1;
		}
		    
		else # print out everything
		{
		    push (@tokenlist, $token);
#		    print "last else for flagmwl: @tokenlist\n";
		    # print tokenlist and token to OUTPUT - line by line with <tok>-tag
		    foreach (@tokenlist)
		    {
			print OUTPUT " <tok>$_</tok>\n";
		    }
		    #flag to 0, empty tokenlist
		    @tokenlist = ();
		    @possiblestartsofoverlap = ();
		    undef $flagmwl;
		   # undef $flagpossibleoverlap;
		}
		undef $flagpossibleoverlap;		
	    }
	    
	} # END of if flagmwl
	
	elsif (exists $hMWL{$token})
	{
	    @restlist = @{$hMWL{$token}};
	    push (@tokenlist, $token);
#	    print "Token in MWL hash: $token, Restlist: @restlist\n";
	    $flagmwl = 1;
	}

	elsif (exists $hMWL{lcfirst($token)})
	{
	    @restlist = @{$hMWL{lcfirst($token)}};
	    push (@tokenlist, $token);
	    # print "Lowercase token in MWL hash: $token\n";
	    $flagmwl = 1;
	}
	
	else # no mwl, just print it to output
	{
	    print OUTPUT "$line\n";
	}
    }
    close $itokens;
    close OUTPUT;
	
    %hMWL = (); #empty space
    
    print "Processed $ntokencount tokens in $nparagraphcount paragraphs and $nsentencecount sentences.\nPlease note that \":\" is considered as sentence delimiter, therefore the numbers can differ from the xml annotation.\n";
    $sTokenFilename = $sMWLTokenFilename; # as input for the next step
} # end if $sMWLfilename

 REPAIR_FLAG:

if ($repair)
{
    $sTokenFilename = $sMWLTokenFilename; # as input for the next step
    $srepairedMWLFilename = "$pathname\/$base\.tokrmwl";
    repair_quotesetc($sTokenFilename, $srepairedMWLFilename);
    $sTokenFilename = $srepairedMWLFilename;
}


# remove the tags

# PRODUCE_INDEX:

open(TOUTPUT, '>', $sTokenwithoutTagsFilename) or die;

open $itokens, '<', $sTokenFilename or die "Could not open $sTokenFilename: $!";

# now put out the file without tags and build the indexes for the word forms
# (lemmatizing plus smor in the next programming step)

print "\nBuilding the indexes for the word forms.\n";


#first the noawk version


if ($noawk)
{
# hindextexts
# hindexparagraphs
# hindexsentences

# first initialize the tied hashes

    use MLDBM qw (DB_File Storable);

    %hindextexts = ();
    %halltokens = ();
    %htokenfreqsintext = ();
    %hinvertedtextindex = ();
    
    
    $flag = 'start';
    $nsentence = 1;
    $ntoken = 0;
    $ntokencount = 0;
    $ntextbefore = 1;
    $ntokenintext = 0;
    $counter = 0;
    
    while (my $line = <$itokens>)
    {
	chomp $line;
	# print "$line\n";
	
	if ($line=~ /\<tok\>(\d+)\#(\d+)\<\/tok\>/)
	{
	    $ntext = $1;
	    $nparagraph = $2;
	    if ($ntext > $ntextbefore)
	    {
		#  print ".";
		# print "$ntext ";
		$htokenfreqsintext{$ntextbefore} = $ntokenintext;
		$ntextbefore = $ntext;
		$ntokenintext = 0;
	    }
	    
	    $nsentence = 1;
	    $ntoken = 0;
	    #	print TOUTPUT "Index: $ntext $nparagraph \n";
	    $flag = 'sentence';
	    next;
	}
	
	
	if ($flag eq 'start') 
	{
	    $ntoken++;
	    $ntokenintext++;
	    while ($line =~ s/<\S[^<>]*(?:>|$)//gs) {};
	    $line =~ s/^ +//g;
	    $flag = 'sentence';
	    unless ($line eq '') 
	    {
		push(@{ $hinvertedtextindex{$line} }, $ntext); 
		# push text no into array and assign it to the line (word token).
		$ntokencount++;
		#	    print "$line\n";
		print TOUTPUT "$ntext\#$nparagraph\#$nsentence\#$ntoken\#$line\n";
		$halltokens{$line}++;
		$skey = $line . "#" . $ntext; 
		$hindextexts{$skey}++;
	    }
	    next;
	}
	
	if ($flag eq 'sentence' && $line !~ /sent_bound/)
	{
	    $ntoken++;
	    $ntokenintext++;
	    while ($line =~ s/<\S[^<>]*(?:>|$)//gs) {};
	    $line =~ s/^ +//g;
	    
	    unless ($line eq '') 
	    {
		push(@{ $hinvertedtextindex{$line} }, $ntext); 
		$ntokencount++;
		#  print "$line\n";
		print TOUTPUT "$ntext\#$nparagraph\#$nsentence\#$ntoken\#$line\n";
		$halltokens{$line}++;
		$skey = $line . "#" . $ntext; 
		$hindextexts{$skey}++;
	    }
	    next;
	}
	
	# end of sentence: set flag to start again, increment sentence number, set token number to 0 again
	if ($flag eq 'sentence' && $line =~ /sent_bound/)
	{
	    $nsentence++;
	    $ntoken = 0;
	    $flag = 'start';
	    next;
	}
    }
    
    # add the number of tokens of the last text;
    
    $htokenfreqsintext{$ntext} = $ntokenintext;
    
    $ntypescount = keys %halltokens;
    
    print "\nIndexes finished: No of units: $ntokencount, no of types: $ntypescount\n";
    
    close $itokens;
    
    close(TOUTPUT);    
}

###


### next part for noawk 
unless ($noawk)
{
    # short cuts via linux and awk
    
    # extract just tokens and text numbers
    # no hashes are necessary

    use MLDBM qw (DB_File Storable);  

    %halltokens = ();
    
    $flag = 'start';
    $nsentence = 1;
    $ntoken = 0;
    $ntokencount = 0;
    $ntextbefore = 1;
    $ntokenintext = 0;
    $counter = 0;
    
    while (my $line = <$itokens>)
    {
	chomp $line;
	# print "$line\n";
	
	if ($line=~ /\<tok\>(\d+)\#(\d+)\<\/tok\>/)
	{
	 $ntext = $1;
	 $nparagraph = $2;
	 if ($ntext > $ntextbefore)
	 {
	     #  print ".";
	     # print "$ntext ";
	     $ntextbefore = $ntext;
	     $ntokenintext = 0;
	 }
	 
	 $nsentence = 1;
	 $ntoken = 0;
	 $flag = 'sentence';
	 next;
     }
     
     if ($flag eq 'start') 
     {
	 $ntoken++;
	 $ntokenintext++;
	 while ($line =~ s/<\S[^<>]*(?:>|$)//gs) {};
	 $line =~ s/^ +//g;
	 $flag = 'sentence';
	 unless ($line eq '') 
	    {
		$ntokencount++;
		print TOUTPUT "$ntext\#$nparagraph\#$nsentence\#$ntoken\#$line\n";
		$halltokens{$line}++;
		$skey = $line . "#" . $ntext; 
	    }
	    next;
     }
	
     if ($flag eq 'sentence' && $line !~ /sent_bound/)
	{
	    $ntoken++;
	    $ntokenintext++;
	    while ($line =~ s/<\S[^<>]*(?:>|$)//gs) {};
	    $line =~ s/^ +//g;
	    
	    unless ($line eq '') 
	    {
		$ntokencount++;
		#  print "$line\n";
		print TOUTPUT "$ntext\#$nparagraph\#$nsentence\#$ntoken\#$line\n";
		$halltokens{$line}++;
		$skey = $line . "#" . $ntext; 
	    }
	    next;
	}
	
	# end of sentence: set flag to start again, increment sentence number, set token number to 0 again
	if ($flag eq 'sentence' && $line =~ /sent_bound/)
	{
	    $nsentence++;
	    $ntoken = 0;
	    $flag = 'start';
	    next;
	}
    }
 
    $ntypescount = keys %halltokens;
    print "\nIndexes finished: No of units: $ntokencount, no of types: $ntypescount\n";
   
    undef %halltokens;
    close $itokens;
    
    close(TOUTPUT);

}



### temporally here as it can be convenient to start after the indexing ... Just uncomment here and comment above
  
#PRODUCE_INDEX:

unless($noawk)
{
    print "\nExtracting tokens and text numbers from $sTokenwithoutTagsFilename to $outputfileinvertedtextindex\n";   

## concise form - not suitable for big data    
##    $cmd = qq[paste \<\(cut \-d\'#\' \-f5\- $sTokenwithoutTagsFilename\) \<\(cut \-d\'#\' \-f1,1 $sTokenwithoutTagsFilename\) \| sort \-k1,1 \-k2,2g \> $outputfileinvertedtextindex 2\>errors];
    
    $cmd = qq[cut \-d\'#\' \-f5\- $sTokenwithoutTagsFilename \>tempcut1];
    print "\nCMD: $cmd\n";
    @args = ( "bash", "-c", $cmd);
    system(@args);

    $cmd = qq[cut \-d\'#\' \-f1,1 $sTokenwithoutTagsFilename \>tempcut2];
    print "\nCMD: $cmd\n";
    @args = ( "bash", "-c", $cmd);
    system(@args);
    
    $cmd = qq(wait);
    print "\nCMD: $cmd\n";
    @args = ( "bash", "-c", $cmd);
    system(@args);

    $cmd = qq[paste tempcut1 tempcut2 > temp];

    print "\nCMD: $cmd\n";
    @args = ( "bash", "-c", $cmd);
    system(@args);

    while (`lsof temp`)
    {
	sleep 300;
	print ".";
    }

    sleep 300;
    print "\n";
      
    
    $cmd = qq[sort \-k1,1 \-k2,2g temp \> $outputfileinvertedtextindex 2\>errors];
  
    print "\nCMD: $cmd\n";
    @args = ( "bash", "-c", $cmd);
    system(@args);

    $cmd = qq(lsof $outputfileinvertedtextindex);
    
       while (`$cmd`)
       {
	   sleep 300;
	   print ".";
       }

    sleep 300;
    print "\n";
    
    print "Finished sorting\n";   
    sleep(30);
    
#sort uniq
    
 print "\nuniq and count to $outputfileinvertedtextindexintermediate\n";
 $cmd = qq[uniq \-c $outputfileinvertedtextindex \> $outputfileinvertedtextindexintermediate];
 print "\nCMD: $cmd\n";
# e.g. uniq -c /media/steiner/zweite/programs/Perl/Indexbuilder2/subcorpus_10_document_1.xml_invertedtextindex.out > /media/steiner/zweite/programs/Perl/Indexbuilder2/subcorpus_10_document_1.xml_invertedtextindexintermediate.out
    `$cmd`;

    $cmd = qq(lsof $outputfileinvertedtextindexintermediate);
    
    while (`$cmd`)
    {
	sleep 300;
	print ".";
    }

    sleep 300;
    print "\n";

#delete leading whitespaces
    `rm tempcut1`;
    `rm tempcut2`;
   # `rm temp`;
    
 $cmd = qq(sed \"s\/\^\[ \\t\]\*\/\/\" \-i $outputfileinvertedtextindexintermediate);
# e.g. sed "s/^[ \t]*//" -i /media/steiner/zweite/programs/Perl/Indexbuilder2/subcorpus_10_document_1.xml_invertedtextindexintermediate.out

 print "\nCMD: $cmd\n";
    `$cmd`;
    $cmd = qq(wait);
    print "\nCMD: $cmd\n";
    @args = ( "bash", "-c", $cmd);
    system(@args);

 $cmd = qq(lsof $outputfileinvertedtextindexintermediate);
    
       while (`$cmd`)
       {
	   sleep 300;
	   print ".";
       }

    sleep 300;
    print "\n";
    
    
# $cmd = qq[paste \-d \"\t\" \<\(cut \-d\' ' \-f2 $outputfileinvertedtextindexintermediate\) \<\(cut \-d\' ' \-f1 $outputfileinvertedtextindexintermediate) \> $outputfileinvertedtextindexsorted 2\>errors];

    
 print "\nChanging the columns and formating of $outputfileinvertedtextindexintermediate to $outputfileinvertedtextindexsorted\n";

 $cmd = qq[cut \-d\' ' \-f2 $outputfileinvertedtextindexintermediate \> cuttemp1];

    print "\nCMD: $cmd\n";
    @args = ( "bash", "-c", $cmd);
    system(@args);

    $cmd = qq[cut \-d\' ' \-f1 $outputfileinvertedtextindexintermediate \> cuttemp2];
    print "\nCMD: $cmd\n";
    @args = ( "bash", "-c", $cmd);
    system(@args);
    
    $cmd = qq(wait);
    print "\nCMD: $cmd\n";
    @args = ( "bash", "-c", $cmd);
    system(@args);

    
$cmd = qq[paste \-d \"\t\" cuttemp1 cuttemp2 \> $outputfileinvertedtextindexsorted 2\>errors];

    
# e.g.   paste -d "	" <(cut -d' ' -f2- /media/steiner/zweite/programs/Perl/Indexbuilder2/subcorpus_10_document_1.xml_invertedtextindexintermediate.out) <(cut -d' ' -f1 /media/steiner/zweite/programs/Perl/Indexbuilder2/subcorpus_10_document_1.xml_invertedtextindexintermediate.out) > /media/steiner/zweite/programs/Perl/Indexbuilder2/subcorpus_10_document_1.xml_invertedtextindexsorted.out 2>errors

 print "\nCMD: $cmd\n";
 @args = ( "bash", "-c", $cmd);
 system(@args);

 $cmd = qq(lsof $outputfileinvertedtextindexsorted);
    
    while (`$cmd`)
    {
	sleep 300;
	print ".";
    }

    sleep 300;
    print "\n";
    
# building the general text index     
    #awk -F$'\t' ' BEGIN{OFS="\t";} {if(a[$1])a[$1]=a[$1]"#" $2; else a[$1]=$2;}END{for (i in a)print i,a[i];}' subcorpus_10_document_1.xml_invertedtextindexsorted.out | sort > test &

 print "\nBuilding the general text index for $outputfileinvertedtextindexsorted to  $outputfileinvertedgeneralindex\n";

    $cmd = qq(awk \-F\$\'\\t\' \' BEGIN\{OFS\=\"\\t\"\;\} \{if\(a\[\$1\]\)a\[\$1\]\=a\[\$1\]\"\#\" \$2\; else a\[\$1\]\=\$2\;\}END\{for \(i in a\)print i,a\[i\]\;\}\' cuttemp1 > temp2 \&);
    
    print "\nCMD: $cmd\n";
    @args = ( "bash", "-c", $cmd);
    system(@args);


    sleep(300);
   
    while (!-e "temp2" or -z "temp2" or `lsof temp2`)
    {
	sleep 600;
	print ".";
    }

    sleep 600;
    print "\n";

   # `rm cuttemp1`;
    `rm cuttemp2`;

    
    $cmd = qq(sort \-k 1\,1n temp2 \> $outputfileinvertedgeneralindex \&);    
    print "\nCMD: $cmd\n";
    @args = ( "bash", "-c", $cmd);
    system(@args);

  #  $cmd = qq(wait);
  #  print "\nCMD: $cmd\n";
  #  @args = ( "bash", "-c", $cmd);
  #  system(@args);

    $cmd = qq(lsof $outputfileinvertedgeneralindex);
    print "\nCMD: $cmd\n";

     while (`$cmd`)
     {
	 sleep 300;
	 print "*";
     }
    sleep 300;
    print "\n";

   # `rm temp2`;
}

else
{
    convert_temporary_hash_to_tied_hash(\%hindextexts, $hashfileindextexts);
    convert_temporary_hash_to_tied_hash(\%halltokens, $hashfilealltokens);
    convert_temporary_hash_to_tied_hash(\%htokenfreqsintext, $hashfiletextlengthintoken);
    convert_temporary_hash_to_tied_hash(\%hinvertedtextindex, $hashfileinvertedtextindex);
	    
    %hindextexts = ();
    %halltokens = ();
    %htokenfreqsintext = ();
    %hinvertedtextindex = ();
    
    output_of_tied_hashs($hashfiletextlengthintoken, $outputfiletextlengthintoken);
    
    print "Output of token frequencies in texts: $outputfiletextlengthintoken \n";
    
    output_of_tied_hash_witharraysinlines($hashfileinvertedtextindex, $outputfileinvertedtextindex);
    
    print "Output of inverted text index: $outputfileinvertedtextindex \n";
    
    sort_arrays_of_tied_hash($hashfileinvertedtextindex, $hashfileinvertedtextindexsorted, $outputfileinvertedtextindexsorted);
    
    print "Output of sorted inverted text index: $hashfileinvertedtextindexsorted, $outputfileinvertedtextindexsorted \n";
    
    output_of_tied_hashs($hashfileindextexts, $outputindextexts);
    
    print "Output of text indexes: $outputindextexts \n";
    
    sleep(10);
    
    output_of_tied_hashs($hashfilealltokens, $outputalltokens);
    
    print "Output of token indexes: $outputalltokens \n";
    
    output_of_tied_hashs_justkeys($hashfilealltokens, $outputjustalltokens);
    
    print "List of tokens: $outputjustalltokens \n";
    
    output_of_tied_hashs_justkeyswithoutdigits($hashfilealltokens, $outputjustalltokenswithoutdigits);
    
    print "List of tokens without digits: $outputjustalltokenswithoutdigits \n";
}


### temporally here as it can be convenient to start after the indexing ... Just uncomment here and comment above
  
PRODUCE_INDEX:


if ($buildtextindices)
{
    $pathtokenscorpus = "$pathname\/Tokenscorpus";
    unless (-e $pathtokenscorpus && -d $pathtokenscorpus)
    {
	make_path($pathtokenscorpus, {verbose => 1, mode => 0764}) or die "Failed to create path: $pathtokenscorpus\n";
    }
    copy($sTokenwithoutTagsFilename, $pathtokenscorpus) or die "Copy failed: $!"; 
    $base = basename($sTokenwithoutTagsFilename);
    buildindices($base, $pathtokenscorpus);
}


### temporally here as it can be convenient to start after the indexing ... Just uncomment here and comment above
  
#PRODUCE_INDEX:


if ($buildlemmaindexfile && (!-e $buildlemmaindexfile))
{
    print "\n\n$buildlemmaindexfile does not exist. Building the files you need for the lemmatization process.\n";
    print "Starting to extract the information from $sTokenwithoutTagsFilename\n";
    $cmd = qq[cut \-d\'#\' \-f5\- $sTokenwithoutTagsFilename \>lemmas.inlines];
    print "\nCMD: $cmd\n";
    @args = ( "bash", "-c", $cmd);
    system(@args);

    $cmd = qq[cut \-d\'#\' \-f1-4 $sTokenwithoutTagsFilename \>lemmas.justindex];
    print "\nCMD: $cmd\n";
    @args = ( "bash", "-c", $cmd);
    system(@args);

    $pathtokenscorpus = "$pathname\/Justtokens";
    unless (-e $pathtokenscorpus && -d $pathtokenscorpus)
    {
	make_path($pathtokenscorpus, {verbose => 1, mode => 0764}) or die "Failed to create path: $pathtokenscorpus\n";
    }

    
#  split files in processible size
    print "Now split the file if it is too large to be called by the lemmatizer\n";
   
    $cmd = qq[split \-d \-l 50000000 lemmas.inlines $pathtokenscorpus\/lemmas.inlines];
    print "\nCMD: $cmd\n";
    @args = ( "bash", "-c", $cmd);
    system(@args);
    
    print "Finished building the input for the lemmatization. Now start the lemmatizer with the files in $pathtokenscorpus. After you have built the lemmatized index files, concatenate them and paste them to lemmas.justindex. Then restart this program with -blif $buildlemmaindexfile.\n";
    exit;
}
    
if ($buildlemmaindexfile)
{
    print "\nStarting with the lemmatized file:\n";
    $pathtokenscorpus = "$pathname\/Lemmascorpus";
    unless (-e $pathtokenscorpus && -d $pathtokenscorpus)
    {
	make_path($pathtokenscorpus, {verbose => 1, mode => 0764}) or die "Failed to create path: $pathtokenscorpus\n";
    }
    print "$pathname\/$buildlemmaindexfile and create the index files in  $pathtokenscorpus\n";
    copy("$pathname\/$buildlemmaindexfile", $pathtokenscorpus) or die "Copy failed: $!"; 

    $base = basename($buildlemmaindexfile);
    
    buildindices($base, $pathtokenscorpus);
    
### include the procedures for building the generalindex of the lemmatized corpus
    
    $outputfileinvertedtextindexlemmas = "$pathname\/$base\_invertedtextindex.out"; # base is from buildlemmaindex
    $outputfileinvertedtextindexsortedlemmas =  "$pathname\/$base\_invertedtextindexsorted.out";
    $outputfileinvertedtextindexintermediatelemmas =  "$pathname\/$base\_invertedtextindexintermediate.out";
    $outputfileinvertedgeneralindexlemmas =  "$pathname\/$base\_invertedgeneralindex.out";

    
## concise form - not suitable for big data        
    $cmd = qq[paste \<\(cut \-d\'#\' \-f5\- $pathname\/$buildlemmaindexfile\) \<\(cut \-d\'#\' \-f1,1 $pathname\/$buildlemmaindexfile\) \| sort \-k1,1 \-k2,2g \> $outputfileinvertedtextindexlemmas 2\>errors];

####
    $cmd = qq[cut \-d\'#\' \-f5\- $buildlemmaindexfile \>tempcut1];
    print "\nCMD: $cmd\n";
    @args = ( "bash", "-c", $cmd);
    system(@args);

    $cmd = qq[cut \-d\'#\' \-f1,1 $buildlemmaindexfile \>tempcut2];
    print "\nCMD: $cmd\n";
    @args = ( "bash", "-c", $cmd);
    system(@args);
    $cmd = qq(wait);
    print "\nCMD: $cmd\n";
    @args = ( "bash", "-c", $cmd);
    system(@args);

    $cmd = qq[paste tempcut1 tempcut2 > temp];

    print "\nCMD: $cmd\n";
    @args = ( "bash", "-c", $cmd);
    system(@args);  

    while (`lsof temp`)
    {
	sleep 300;
	print ".";
    }

    sleep 300;
    print "\n";
      
    $cmd = qq[sort \-k1,1 \-k2,2g temp \> $outputfileinvertedtextindexlemmas 2\>errors];
  
    print "\nCMD: $cmd\n";
    @args = ( "bash", "-c", $cmd);
    system(@args);
    $cmd = qq(lsof $outputfileinvertedtextindexlemmas);
    
    while (`$cmd`)
    {
	sleep 300;
	print ".";
    }
    
    sleep 300;
    print "\n";
    
    print "Finished sorting\n";   
    sleep(30);

#### sort uniq
    
    print "\nCMD: $cmd\n";
    @args = ( "bash", "-c", $cmd);
    system(@args);

    print "\nuniq and count $outputfileinvertedtextindexlemmas to $outputfileinvertedtextindexintermediatelemmas\n";
    $cmd = qq[uniq \-c $outputfileinvertedtextindexlemmas \> $outputfileinvertedtextindexintermediatelemmas];
    print "\nCMD: $cmd\n";
    `$cmd`;

 $cmd = qq(lsof $outputfileinvertedtextindexintermediatelemmas);
    
    while (`$cmd`)
    {
	sleep 300;
	print ".";
    }

    sleep 300;
    print "\n";
    
    `rm tempcut1`;
    `rm tempcut2`;
    `rm temp`;
    
    $cmd = qq(sed \"s\/\^\[ \\t\]\*\/\/\" \-i $outputfileinvertedtextindexintermediatelemmas);
    print "\nCMD: $cmd\n";
    `$cmd`;

    $cmd = qq(wait);
    print "\nCMD: $cmd\n";
    @args = ( "bash", "-c", $cmd);
    system(@args);

 $cmd = qq(lsof $outputfileinvertedtextindexintermediatelemmas);
    
    while (`$cmd`)
    {
	sleep 300;
	print ".";
    }

    sleep 300;
    print "\n";
    
    print "\nChanging the columns and formating of $outputfileinvertedtextindexintermediatelemmas to $outputfileinvertedtextindexsortedlemmas\n";
   
#  $cmd = qq[paste \-d \"\t\" \<\(cut \-d\' ' \-f2\- $outputfileinvertedtextindexintermediatelemmas\) \<\(cut \-d\' ' \-f1 $outputfileinvertedtextindexintermediatelemmas) \> $outputfileinvertedtextindexsortedlemmas 2\>errors];

    $cmd = qq[cut \-d\' ' \-f2 $outputfileinvertedtextindexintermediatelemmas \> cuttemp1];

    print "\nCMD: $cmd\n";
    @args = ( "bash", "-c", $cmd);
    system(@args);

    $cmd = qq[cut \-d\' ' \-f1 $outputfileinvertedtextindexintermediatelemmas \> cuttemp2];
    print "\nCMD: $cmd\n";
    @args = ( "bash", "-c", $cmd);
    system(@args);
    
    $cmd = qq(wait);
    print "\nCMD: $cmd\n";
    @args = ( "bash", "-c", $cmd);
    system(@args);
    
$cmd = qq[paste \-d \"\t\" cuttemp1 cuttemp2 \> $outputfileinvertedtextindexsortedlemmas 2\>errors];

 print "\nCMD: $cmd\n";
 @args = ( "bash", "-c", $cmd);
 system(@args);

 $cmd = qq(lsof $outputfileinvertedtextindexsortedlemmas);
    
    while (`$cmd`)
    {
	sleep 300;
	print ".";
    }

    sleep 300;
    print "\n";


# repair "Zweifel|Zweifeln	50699	1"

    $outputfilerepaireddoubles  = "$outputfileinvertedtextindexsortedlemmas\_repaired";
    print "\nRepairing ambiguous lemmas in $outputfileinvertedtextindexsortedlemmas by creating double entries $outputfilerepaireddoubles\n";

    repairdoublelemmas($outputfileinvertedtextindexsortedlemmas, $outputfilerepaireddoubles);

    $cmd = qq(sed \"s\/\^\[ \\t\]\*\/\/\" \-i $outputfilerepaireddoubles);
    print "\nCMD: $cmd\n";
    `$cmd`;

    $cmd = qq(wait);
    print "\nCMD: $cmd\n";
    @args = ( "bash", "-c", $cmd);
    system(@args);

 $cmd = qq(lsof $outputfilerepaireddoubles);
    
    while (`$cmd`)
    {
	sleep 300;
	print ".";
    }

    sleep 300;
    print "\n";
     
    print "\nBuilding the general text index for $outputfilerepaireddoubles to  $outputfileinvertedgeneralindexlemmas:\n";

    ## concise commmand: not suitable for big data
   ##  $cmd = qq(awk \-F\$\'\\t\' \' BEGIN\{OFS\=\"\\t\"\;\} \{if\(a\[\$1\]\)a\[\$1\]\=a\[\$1\]\"\#\" \$2\; else a\[\$1\]\=\$2\;\}END\{for \(i in a\)print i,a\[i\]\;\}\' $outputfilerepaireddoubles \| sort \-k 1\,1n \> $outputfileinvertedgeneralindexlemmas \&);

    $cmd = qq[cut \-f1,2 $outputfilerepaireddoubles \> cuttemp1];

    print "\nCMD: $cmd\n";
    @args = ( "bash", "-c", $cmd);
    system(@args);

    $cmd = qq(wait);
    print "\nCMD: $cmd\n";
    @args = ( "bash", "-c", $cmd);
    system(@args);
    
    $cmd = qq(awk \-F\$\'\\t\' \' BEGIN\{OFS\=\"\\t\"\;\} \{if\(a\[\$1\]\)a\[\$1\]\=a\[\$1\]\"\#\" \$2\; else a\[\$1\]\=\$2\;\}END\{for \(i in a\)print i,a\[i\]\;\}\' cuttemp1 > temp2 \&);
    
    print "\nCMD: $cmd\n";
    @args = ( "bash", "-c", $cmd);
    system(@args);

    sleep(300);
   
    while (!-e "temp2" or -z "temp2" or `lsof temp2`)
    {
	sleep 600;
	print ".";
    }

    sleep 600;
    print "\n";
    
    $cmd = qq(sort \-k 1\,1n temp2 \> $outputfileinvertedgeneralindexlemmas \&);    
    print "\nCMD: $cmd\n";
    @args = ( "bash", "-c", $cmd);
    system(@args);

   $cmd = qq(lsof $outputfileinvertedgeneralindexlemmas);
    print "\nCMD: $cmd\n";

    while (`$cmd`)
     {
	 sleep 300;
	 print "*";
     }
    sleep 300;
    print "\n";
    print "Finished indexing for lemmas.\n";
}

## if mergeindices #
## first check if the file exist - it is the same as buildlemmaindexfile

if ($mergeindices && (!-e $mergeindices))
{
    print "\n$mergeindices does not exist. Now building the files you need for the lemmatization process.\n";
    print "Starting to extract the information from $sTokenwithoutTagsFilename\n";
    $cmd = qq[cut \-d\'#\' \-f5\- $sTokenwithoutTagsFilename \>lemmas.inlines];
    print "\nCMD: $cmd\n";
    @args = ( "bash", "-c", $cmd);
    system(@args);

    $cmd = qq[cut \-d\'#\' \-f1-4 $sTokenwithoutTagsFilename \>lemmas.justindex];
    print "\nCMD: $cmd\n";
    @args = ( "bash", "-c", $cmd);
    system(@args);
    $pathtokenscorpus = "$pathname\/Justlemmas";
    unless (-e $pathtokenscorpus && -d $pathtokenscorpus)
    {
	make_path($pathtokenscorpus, {verbose => 1, mode => 0764}) or die "Failed to create path: $pathtokenscorpus\n";
    }

    
#  split files in processible size
    print "Now split the file if it is too large to be called by the lemmatizer\n";
   
    $cmd = qq[split \-d \-l 50000000 lemmas.inlines $pathtokenscorpus\/lemmas.inlines];
    print "\nCMD: $cmd\n";
    @args = ( "bash", "-c", $cmd);
    system(@args);

    print "Finished building the input for the lemmatization. Now start the lemmatizer with the files in $pathtokenscorpus. After you have built the lemmatized index files, concatenate them and paste them to lemmas.justindex. Then restart this program with -blif $mergeindices for building the text indices. In addition you can also add the option -merge $mergeindices. The filenames for blif and merge should be identical. \n";
  
    exit;    
}

if ($mergeindices)
{
    $pathtokenscorpus = "$pathname\/Mergedcorpus";
    unless (-e $pathtokenscorpus && -d $pathtokenscorpus)
    {
	make_path($pathtokenscorpus, {verbose => 1, mode => 0764}) or die "Failed to create path: $pathtokenscorpus\n";
    }
    mergeindices("$pathname\/Tokenscorpus", "$pathname\/Lemmascorpus", $pathtokenscorpus);
    
    $outputfileinvertedgeneralindex =  "$pathname\/$base1\_invertedgeneralindex.out";

    # merge the general text indices for lemmas and tokens
    # cat and sort -u
    
    $base = basename($mergeindices);
    
    $outputfileinvertedgeneralindexlemmas =  "$pathname\/$base\_invertedgeneralindex.out";
    $outputfileinvertedgeneralindexintermediatelemmasandtokens = "$pathname\/$base1\_invertedgeneralindexintermediatelemmasandtokens.out";
    
    $cmd = qq(cat $outputfileinvertedgeneralindex $outputfileinvertedgeneralindexlemmas \| sort \-u \> $outputfileinvertedgeneralindexintermediatelemmasandtokens);
    print "\nCMD: $cmd\n";
    `$cmd`;
    
    # and now awk
    $outputfileinvertedgeneralindexmergeddoubles = "$pathname\/$base1\_invertedgeneralindexmergeddoubles.out";
    $outputfileinvertedgeneralindexmerged = "$pathname\/$base1\_invertedgeneralindexmerged.out";

    print "\nCoercing the textnumbers of $outputfileinvertedgeneralindexintermediatelemmasandtokens to $outputfileinvertedgeneralindexmergeddoubles\n";

    ## concise but not suitable for big data
  ##  $cmd = qq(awk \-F\$\'\\t\' \' BEGIN\{OFS\=\"\\t\"\;\} \{if\(a\[\$1\]\)a\[\$1\]\=a\[\$1\]\"\#\" \$2\; else a\[\$1\]\=\$2\;\}END\{for \(i in a\)print i,a\[i\]\;\}\' $outputfileinvertedgeneralindexintermediatelemmasandtokens \| sort \-k 1\,1n \> $outputfileinvertedgeneralindexmergeddoubles \&);

    $cmd = qq[cut \-d\' ' \-f2 $outputfileinvertedgeneralindexintermediatelemmasandtokens \> cuttemp1];

    print "\nCMD: $cmd\n";
    @args = ( "bash", "-c", $cmd);
    system(@args);

    $cmd = qq(wait);
    print "\nCMD: $cmd\n";
    @args = ( "bash", "-c", $cmd);
    system(@args);
    
    $cmd = qq(awk \-F\$\'\\t\' \' BEGIN\{OFS\=\"\\t\"\;\} \{if\(a\[\$1\]\)a\[\$1\]\=a\[\$1\]\"\#\" \$2\; else a\[\$1\]\=\$2\;\}END\{for \(i in a\)print i,a\[i\]\;\}\' cuttemp1 > temp2 \&);
    
    print "\nCMD: $cmd\n";
    @args = ( "bash", "-c", $cmd);
    system(@args);

    sleep(300);
   
    while (!-e "temp2" or -z "temp2" or `lsof temp2`)
    {
	sleep 600;
	print ".";
    }
    sleep 60;
    
    while (!-e "temp2" or -z "temp2" or `lsof temp2`)
    {
	sleep 600;
	print "+";
    }
    print "\n";
    `rm cuttemp1`;
    
    $cmd = qq(sort \-k 1\,1n temp2 \> $outputfileinvertedgeneralindexmergeddoubles \&);    
    print "\nCMD: $cmd\n";
    @args = ( "bash", "-c", $cmd);
    system(@args);

    $cmd = qq(lsof $outputfileinvertedgeneralindexmergeddoubles);
    print "\nCMD: $cmd\n";

    while (`$cmd`)
     {
	 sleep 300;
	 print "*";
     }
    sleep 300;
    print "\n";
       
    #uniq the second column
    
    sleep(60); # please do not uncomment - obviously writing the last file takes some time
    
    print "Removing duplicate text numbers of $outputfileinvertedgeneralindexmergeddoubles to $outputfileinvertedgeneralindexmerged\n\n";
    
    remove_duplicates_insecondcol($outputfileinvertedgeneralindexmergeddoubles, $outputfileinvertedgeneralindexmerged);
    print "Finished producing the merged indices.\n";
}

my $end_run = time();
my $run_time = $end_run - our $start_run;
print "Job took $run_time seconds\n";
exit(0);


######
# Uses XML::Twig for processing huge XML data
#
# iterates through huge XML data and prints out (relatively) clean code, everything which is between sentence tags. 
# Counts texts and paragraphs, one sentence per line
#####

sub process_text_with_twig
{
    my ($twig, $text, $ntext, $SOUTPUT) = @_;
    my (
	$textbodystring,
#	$paragraphstring,
	$sentencestring,
	$headstring,
	@alltagsinsentence,
	@textbodies,
	@headorparagraphs,
	$headorparagraph,
	$parent,
	@childnodes,
	@nodesnames,
	$nodename,
	$ntextparagraph,
	@asentences,
	@tagsinsentence,
	@asentencesoutput,
	);
 
    $textbodystring = './/text';
   # $paragraphstring = './/p';
    $sentencestring = './/s';
    $headstring = './/head';
    @alltagsinsentence = ();

    @atextbodies = $text->findnodes($textbodystring);
    
    $nparagraph = 0;
    
    for $textbody (@atextbodies) #<text>
    {
	print ".";
	@aheadorparagraphs = $textbody->findnodes('.//s/..'); # get everything which is the parent of <s>
	# the problem here is that one does not know how deep <s> is embedded, so get everything and filter out errors later
	$nallheadorparagraphs += $#aheadorparagraphs + 1;
	    
	# following a non-s and being parent of s
	
	for $headorparagraph (@aheadorparagraphs)
	{
	    my $parent = $headorparagraph->parent;
	    my @childnodes = $parent->children;
#	    print "Parent: ";
 #       $parent->print;
#		print "\n";	
	    
	    my @nodenames = map {$_->name} @childnodes;
	    
	    if (! (grep {$_ eq "s"} @nodenames))  
		# if there is an s on the same level, this entity is not further processed.
	    {
		# print "* $headorparagraph *+ ";
		
		$nodename = $headorparagraph->name;
		# print "Processing $nodename\n";
		
		$ntextparagraph = ""; # dummy
		@asentences = $headorparagraph->findnodes($sentencestring);
		# $nsentence = 0;
		@asentencesoutput = ();
		
		for $sentence (@asentences)
		{
		    $sentence->findnodes("./*");
		    @tagsinsentence = $sentence->cut_children( sub { ($_[0]->is_empty)});
		    @tagnames = map {$_->name()} @tagsinsentence;
		    if (@tagnames) 
		    {
			    # print "Tags in sentence: @tagnames\n";
			$spuresentence = $sentence->toString;
	#		print "spuresentence: $spuresentence\n";
			
			# remove tags from $sentence
			while ($spuresentence =~ s/<\S[^<>]*(?:>|$)//gs) {};
					   # print "$spuresentence\n";
			$soutputsentence = $spuresentence;
		    }
		    else
		    {
			 # $soutputsentence = $sentence;
			$soutputsentence = $sentence->toString;
			#print "Soutputsentence without tags:***$soutputsentence**\n";
		    }
		    
		    # cleaning linebreaks and double spaces
		    $soutputsentence =~ s/\n/ /g;

		    $decodedsentence = XML::Entities::decode ('all', $soutputsentence); 

		    # cleaning <s>-tags and others if necessary
		  #  while ($decodedsentence =~ s/<\S[^<>]*(?:>|$)/ /gs) {}; # 23.02. as \n is deleted
		    while ($decodedsentence =~ s/<\S[^<>]*(?:>)/ /gs) {};
		    $decodedsentence =~ s/ +/ /g;
		    $decodedsentence =~ s/PGN\:0\s*//g; # some weird stuff
		
		    #  print $SOUTPUT "$sentenceindex $soutputsentence\n";
		    if ($decodedsentence) # not empty string
		    {
			push @asentencesoutput, $decodedsentence;
		    }
		    push (@alltagsinsentence, @tagnames);
		    
		} # end of all sentences
		if (@asentencesoutput) # check if there are valid entries
		{
		    $nparagraph++;
		    $nallsentences += $#asentencesoutput + 1;
		   # print "Processed $nallsentences sentences\n";
		    $ntextparagraph = $ntext . '#' . $nparagraph;
		    print $SOUTPUT "$ntextparagraph\n";
		    empty_buffer ($SOUTPUT, @asentencesoutput);
		    @asentencesoutput = ();
		}
	    }
	}
    }
    
    @atextbodies = ();
    $twig->purge;
    #$twig->dispose;
    $text = "";
}

##########
# looks for multiword items
# and also for words which have multiword items as a part
# treats cases of overlaps by choosing the longer possible variant
##############


sub find_mwl{
    my ($token, $firstoftokenlist, @tokenlist) = @_;
    # e.g. Business, Lufthansa, ''
    my (@restlist,
	$stringoftokenlist,
	);
#    print "start of find_mwl: token: $token, firstoftokenlist: $firstoftokenlist Tokenlist: @tokenlist\n";
    # e.g. Business, Lufthansa
    
    unshift (@tokenlist, $firstoftokenlist);
    $stringoftokenlist = (join(" ", @tokenlist)); 
  
   # print "Stringoftokenlist: $stringoftokenlist\n";
    
    @restlist = @{$hMWL{$firstoftokenlist}};
#    print "Restlist in find_mwl: @restlist\n";
    @exactmatches = grep { /^\Q$token\E$/ } @restlist;
#    print "Exact matches: @exactmatches\n";
    
    @partmatches = ();
    $stringoftokenlist =~ /^(.*?)[\-\.\\]/;
    $firstpart = $1; # e.g. 747
    
    if ($firstpart)
    {
	@partmatches =  grep { /^\Q$firstpart\E$/ } @restlist;
	# print "Part: $firstpart, token: $token, Partial matches: @partmatches\n";
    }
    @matches = grep { /^\Q$token\E\s/ } @restlist;
#    print "Matches: @matches\n";

    if (@exactmatches && @matches) # exact match found for this token and a multiword unit and longer match is still possible
    {
	
	push (@tokenlist, $token);
#	print "Old restlist: @restlist\n";
	# print OUTPUT " <tok>@tokenlist $token</tok>\n";
	@store_exactmatches = @exactmatches;	
	@restlist = apply {$_ =~ s/^@tokenlist //} @matches;
#	print "New restlist: @restlist\n";
    }
    
    elsif (@exactmatches) # only one and exact match found for this token - a multiword unit
    {
	print OUTPUT " <tok>@tokenlist $token</tok>\n";
	@tokenlist = ();
	@possiblestartsofoverlap = ();
	@store_exactmatches = (); 
	undef $flagmwl;
	undef $flagpossibleoverlap;
	@restlist = ();
    }
    elsif (@partmatches) # partial match found for this token - a multiword unit or punctuation mark
    {
	if ($stringoftokenlist =~ /^(.*?)[\.]/)
	{
	    print OUTPUT " <tok>@tokenlist $firstpart</tok>\n<tok>.</tok>\n<sent_bound/>\n";
	}
	else
	{
	    print OUTPUT " <tok>@tokenlist $token</tok>\n";
	}
	@tokenlist = ();
	@store_exactmatches = ();
	undef $flagmwl;
	undef $flagpossibleoverlap;
	@restlist = ();
    }
    
    elsif (@exactmatches) # only one and exact match found for this token - a multiword unit
    {
	print OUTPUT " <tok>@tokenlist $token</tok>\n";
	@tokenlist = ();
	@possiblestartsofoverlap = ();
	@store_exactmatches = (); 
	undef $flagmwl;
	undef $flagpossibleoverlap;
	@restlist = ();
    }
    elsif (@matches) # it could be the first part of a multiword unit
    {
	push (@tokenlist, $token);
	# remove token+whitespace from elements of matches
	@restlist = apply {$_ =~ s/^$token //} @matches; # delete this tokenlist from the restlist
#	print "New matches: @restlist\n";
	undef $flagpossibleoverlap; # first try to find the next sequence
    }
    #nothing found for the firstoftokenlist, print it out, remove it from tokenlist
    else
    {
	#print "#nothing\n";
	#print "new tokenlist1: @tokenlist\n";
	print OUTPUT " <tok>$firstoftokenlist</tok>\n";
	shift @tokenlist;
	#print "new tokenlist2: @tokenlist\n";
	push (@tokenlist, $token);
	@restlist = ();
    }    
 
    return (\@tokenlist, \@restlist);
}


## repair words with quotes and multi-word units as first parts

sub repair_quotesetc{
    my ($stokMWLFilename, $srepairedMWLFilename) = @_;
    my (@sentence_buffer,
	@new_sentence_buffer,
	$OUTPUT);

    open $itokens, '<', $stokMWLFilename or die "Could not open $stokMWLFilename: $!";    
    print "Punctuation/special characters in words repair; writing to $srepairedMWLFilename\n";
    open($OUTPUT, '>', $srepairedMWLFilename) or die "couldn't open $srepairedMWLFilename: $!";
    
    while ($line = <$itokens>)
    {
       #  print "Line: $line\n";
	chomp $line;
	$line =~ s/\&amp\;/\&/g;
	$line =~ s/\&lt\;/\</g;
	$line =~ s/\&gt\;/\>/g;
	if ($line =~ m/sent\_bound/) # process
	{
	    @new_sentence_buffer = processquotesetc(@sentence_buffer);
	    push @new_sentence_buffer, $line;
	    empty_buffer ($OUTPUT, @new_sentence_buffer);
	    @sentence_buffer = ();
	}
	else # just slurp in
	{
	    push @sentence_buffer, $line;
	}
    }
    @sentence_buffer = ();
    @new_sentence_buffer = ();
    close $OUTPUT;
    close $itokens;
}

sub processquotesetc{
    my (@buff) = @_;  # buffer of one sentence
    my (@quotesintokenindexes,
	@numberofquotesintoken,
	$index_twq,
	$token,
	$count,
	@before,
	$indexquote,
	$indexbeforequote,
	$indexafterquote,
	@newbuff,
	@newtoken,
	$newtoken,
	$counterpart,
	$losttokens,
	);

    my %quoteset = (
	'(' => ')',
	')' => '(',
	'\'' => '\'',
	'"' => '"',
	'`' => '`',
	'[' => ']',
	']' => '[',
	);

    @quotesintokenindexes = indexes {/\<tok\>(.+)([\)\"\'\`])\S{2,}\<\/tok\>/} @buff; # look for tokens with quotesetc inside

# set a limit to avoid text which is totally chaotic
    
    if (@quotesintokenindexes && ($#quotesintokenindexes < 20))  # further processing
    {
#	print "Buffer: @buff\n";
#	print "Pos with quotesetc:  @quotesintokenindexes\n";
	$losttokens = 0;
	foreach $index_twq (@quotesintokenindexes) # check if number is uneven, work from behind
	{
	    $index_twq = $index_twq - $losttokens;
	    
	    $token = $buff[$index_twq];
#	    print "Token with quotesetc: $token\n";
	    $count = () = $token =~ /([\)\(\"\'\`])/g;
#	    print "$count quotesetc in token $token\n";
	    $counterpart = $quoteset{$1}; 
	    
	    @before = indexes {/\<tok\>\Q$counterpart\E\<\/tok\>/} @buff[0..$index_twq-1];

#	    print "Before: @before *\n";
	    #only if number is odd and a single quote before in the sentence
	    if (($count%2 == 1) && @before)
	    {
		$indexquote = $before[$#before];
		$indexbeforequote = $indexquote - 1;
		$indexafterquote = $indexquote + 1;
		@newbuff[0..$indexbeforequote] = @buff[0..$indexbeforequote];
		# print "newbuff: @newbuff\n";
		# now build a new entry containing the quotes
		@newtoken = ();
		$newtoken = " <tok>$counterpart";
	#	print "Newtoken: $newtoken\n";
		foreach (@buff[$indexafterquote..$index_twq]) # index++ because quote already in string
		{
		    $_ =~ /\<tok\>(.+)\<\/tok\>/;
		    $losttokens++; # for subtracting it from the next values of index_twq
		    push (@newtoken, $1); # collect the new mwl token 
		}
		$newtoken .=  (join ' ', @newtoken)  . "</tok>"; # add to starting tag and add end tag
	#	print "Newtoken2: $newtoken\n";
		@newbuff[$indexquote] = $newtoken;
		my $nextindex = $index_twq + 1;
		#add the rest to new token
	#	print "Newbuff2: @newbuff\n";
		push @newbuff, @buff[$nextindex..$#buff];
		@buff =  @newbuff;
	#	print "Refurbished @buff\n";
	    }
	}
    } # end case there was a quoteetc
    return @buff;
}

    
sub empty_buffer {
    my ($STREAM, @buff) = @_;
    my ($j);
    # empty buffers 
    while ( $#buff >= 0 ) {

	# don't use replace-function here
	# because some of the buffer entries already contain XML markup!
	$j = shift @buff; 
	print $STREAM "$j\n";
    }
}

sub output_of_tied_hashs {
    my ($inputhashfile, $outputtextfile) = @_;
    my (%hinput,
	@keys,
	$key,
	$value,
	@valuearray,
	$db,
	);

   $db = tie (%hinput, 'MLDBM' , $inputhashfile, O_RDONLY, 0666, $DB_BTREE);

    Dumper($db->{DB});
    $db->{DB}->Filter_Push('utf8');
    
    open (AUSGABE, ">$outputtextfile") || die "Fehler! ";
    @keys = natkeysort { $_} keys %hinput;

    foreach $key (@keys)
	{
	    $value = $hinput{$key};
            print AUSGABE "$key\\\\$value\n";
	}
    close AUSGABE;
    undef $db;   
    untie (%hinput);

# later put in the path to the file to the returnValue
    return ("$outputtextfile");
}


sub output_of_tied_hash_witharraysinlines {
    my ($inputhashfile, $outputtextfile) = @_;
    my (%hinput,
	@keys,
	$key,
	$value,
	@valuearray,
	$ref,
	$db,
	);

	# print "Output of tied hash with arrays ...";	
	
    $db = tie (%hinput, 'MLDBM' , $inputhashfile,  O_RDONLY, 0666, $DB_BTREE);
    
    Dumper($db->{DB});
    $db->{DB}->Filter_Push('utf8');

    open (AUSGABE, ">$outputtextfile") || die "Fehler! ";
    
    @keys = natkeysort { $_} keys %hinput;
    foreach $key (@keys)
    {
          #  print "$key\n";
	    @valuearray = @{$hinput{$key}};

	    foreach $ref (@valuearray)
	    {		
		print AUSGABE "$key\t$ref\n";
	    }
	}
    close AUSGABE;
    undef $db;   
    untie (%hinput);
# later put in the path to the file to the returnValue
    return ("$outputtextfile");
}

sub sort_arrays_of_tied_hash {
    my ($inputhashfile, $outputhashfile, $outputtextfile) = @_;
    my (%hinput,
	%houtput,
	@keys,
	$key,
	$key2,
	@keys2,
	$value,
	@valuearray,
	$ref,
	$db,
	$tmp,
	);

	# print "Sort arrays of tied hash  ...";	
	
    $db1 = tie (%hinput, 'MLDBM' , $inputhashfile,  O_RDONLY, 0666, $DB_BTREE);
    
    Dumper($db1->{DB});
    $db1->{DB}->Filter_Push('utf8');


    $db2 = tie (%houtput, 'MLDBM' , $outputhashfile,  O_TRUNC|O_CREAT, 0666, $DB_BTREE);
    
    Dumper($db2->{DB});
    $db2->{DB}->Filter_Push('utf8');

    open (AUSGABE, ">$outputtextfile") || die "Fehler! ";
    
    @keys = natkeysort { $_} keys %hinput;
    foreach $key (@keys)
    {
	# print "$key\n";  # e.g. lemma/morph/token
	@valuearray = @{$hinput{$key}};
	my %intermediatehash; # keys: Textnummer, values: frequencies
	$intermediatehash{$_}++ for @valuearray;
	@keys2 =  natkeysort { $_} keys %intermediatehash;
	
	foreach $key2 (@keys2)
	{
	    $tmp = $houtput{$key};
	    $tmp->{$key2} = $intermediatehash{$key2}; # 
	    print AUSGABE "$key $key2 $intermediatehash{$key2}\n";
	}
    }
    close AUSGABE;
    undef $db1;   
    untie (%hinput);
    undef $db2;   
    untie (%houtput);
    
# later put in the path to the file to the returnValue
    return ("$outputhashfile");
}


sub output_of_tied_hashs_justkeys {
    my ($inputhashfile, $outputtextfile) = @_;
    my (%hinput,
	@keys,
	$key,
	$value,
	@valuearray,
	$db,
	);

   $db = tie (%hinput, 'MLDBM' , $inputhashfile, O_RDONLY, 0666, $DB_BTREE);

    Dumper($db->{DB});
    $db->{DB}->Filter_Push('utf8');
    
    open (AUSGABE, ">$outputtextfile") || die "Fehler! ";
    @keys = natkeysort { $_} keys %hinput;

    foreach $key (@keys)
	{
#	    $value = $hinput{$key};
#            print AUSGABE "$key\\\\$value\n";
	    print AUSGABE "$key\n";
	}
    close AUSGABE;
    undef $db;   
    untie (%hinput);

# later put in the path to the file to the returnValue
    return ("$outputtextfile");
}



sub output_of_tied_hashs_justkeyswithoutdigits {
    my ($inputhashfile, $outputtextfile) = @_;
    my (%hinput,
	@keys,
	$key,
	$value,
	@valuearray,
	$db,
	);

   $db = tie (%hinput, 'MLDBM' , $inputhashfile, O_RDONLY, 0666, $DB_BTREE);

    Dumper($db->{DB});
    $db->{DB}->Filter_Push('utf8');
    
    open (AUSGABE, ">$outputtextfile") || die "Fehler! ";
    @keys = natkeysort { $_} keys %hinput;

    foreach $key (@keys)
	{
#	    $value = $hinput{$key};
	    #            print AUSGABE "$key\\\\$value\n";
	    unless ($key =~ /^(\d|\.|\-|\,|\\)+$/)
	    {
		print AUSGABE "$key\n";
	    }
	}
    close AUSGABE;
    undef $db;   
    untie (%hinput);

# later put in the path to the file to the returnValue
    return ("$outputtextfile");
}


##########
# hashes in virtual memory are faster to retrieve than those which are stored in a file
#########
sub convert_tied_hash_to_temporary_hash {
    my ($inputtiedhashfile) = @_;
    my (%hinput,
	%houtput,
	@keys,
	$key,
	$value,
#	@valuearray,
#	$ref,
	$db,
	);

	print "Convert ...";	
	
    $db = tie (%hinput, 'MLDBM' , $inputtiedhashfile,  O_RDONLY, 0644, $DB_BTREE) or die "Could not bind $inputtiedhashfile: $!";
    
    Dumper($db->{DB});
    $db->{DB}->Filter_Push('utf8');
    
    %houtput = ();

    print "sort keys ...";
    @keys = natkeysort { $_} keys %hinput;
    print "sorted ...\n";
    
    while (($key, $value) = each %hinput)
    {
#	print "$key\n";
	$houtput{$key} = $value;
    }	
	undef $db;   
	untie (%hinput);
	# later put in the path to the file to the returnValue
    	return  wantarray ? %houtput : \%houtput;
}

#####


sub convert_temporary_hash_to_tied_hash {
    my ($ref_hinput, $outputtiedhashfile) = @_;
    my (%hinput,
	%houtput,
	@keys,
	$key,
	$value,
	$db,
	);

       print "Convert ...";	

    
    $db = tie (%houtput, 'MLDBM' , $outputtiedhashfile,  O_TRUNC|O_CREAT, 0666, $DB_BTREE) or die "Could not bind $outputtiedhashfile: $!";
    
    Dumper($db->{DB});
    $db->{DB}->Filter_Push('utf8');
    
    %houtput = ();

    %hinput = %$ref_hinput;

    print "sort keys ...";
    
    @keys = natkeysort { $_} keys %hinput;

    print "keys sorted ...";
    
    while (($key, $value) = each %hinput)
    {
#	print "$key\n";
	$houtput{$key} = $value;
    }	
	undef $db;   
	untie (%houtput);
    	return  $outputtiedhashfile;
}

############

# takes a file of the format TeXTNR#1#1#1#token\n
# for each text it creates a file with the frequency counts in it
# and stores the file TEXTNR in $pathcorpus

###############

sub buildindices{
    my ($textfile, $pathcorpus) = @_;
    my ($soutputfilename,
	$oldoutputfilename,
	$token,
	%freqhash,
	$pathname,
	$filename,
	@keys,
	$key,
	@substralternatives,
	@uniqsubstr,
	@alternatives,
	$alternative,
	);
    
    $filename = "$pathcorpus\/$textfile";
    $soutputfilename = "1";
    $oldoutputfilename = "1";
    
    if ( ! -e $filename) {die "$filename does not exist."};

    open my $INPUTC, '<:encoding(UTF-8)', $filename or die "couldn't open $textfile: $!";
    
    %freqhash = ();

    print "\nStart creating indices for each text in file $filename. Output to dir $pathcorpus\n";
    
    while(<$INPUTC>)
	{
	  #  print "line: $_ \n";
	    chomp($_);
	    if ($_ =~ /^(\d+?)\#(\d+?)\#(\d+?)\#(\d+?)\#(.*)$/ )
	    {
		$soutputfilename = $1;
		$token = $5;
		if ($oldoutputfilename eq $soutputfilename)
		{
		    #	    if ($token =~ /.+\|.+/)
		    if ($token =~ /^[^}{]+\|[^}{]+/)
		    { 
			@alternatives =	split /[|]/, $token;

			@substralternatives = map {tr/äöü/aou/r,}  (map {lc (substr ($_, 0, 2))} @alternatives);
			@uniqsubstr = uniq @substralternatives;
			# check if the beginnings of the tokens are the same
			if ($#uniqsubstr < 1)
			{
			  #  print "split: @alternatives\n";
			    foreach $alternative (uniq @alternatives)
			    {
				$freqhash{$alternative}++; 
			    }
			}
			else
			{
			    $freqhash{$token}++;
			}
		    }
		    
		    else
		    {
			$freqhash{$token}++;
		    }
		}
		
		else
		{ # sort by value, most frequent first
		    @keys = sort {$freqhash{$b} <=> $freqhash{$a}} keys %freqhash;
		    
		    open my $OUTPUTC, '>:encoding(UTF-8)', "$pathcorpus\/$oldoutputfilename" or die "couldn't open $pathcorpus\/$oldoutputfilename: $!";
		    foreach $key (@keys) 
		    {
			# print "$key\n";
			print $OUTPUTC "$key\#$freqhash{$key}\n";
		    } 
		    close $OUTPUTC;
		    %freqhash = ();
		    $oldoutputfilename = $soutputfilename;
		    $freqhash{$token}++;
		}
	    }
	}
    # last file

    # @keys = sort {$b <=> $a} values %freqhash;
    @keys = sort {$freqhash{$b} <=> $freqhash{$a}} keys %freqhash;		    
    open my $OUTPUTC, '>:encoding(UTF-8)', "$pathcorpus\/$soutputfilename" or die "couldn't open $pathcorpus\/$soutputfilename: $!";
    foreach $key (@keys) 
    {
	print $OUTPUTC "$key\#$freqhash{$key}\n";
    } 
    close $OUTPUTC;
    %freqhash = ();
    
    close $INPUTC;
}


#####
# Takes two directories: 1 with files with tokens, 2 with files with lemmas (format: Token/Lemma#freq)
# and creates for each pair of files a synopsis. If a string exists  in both lemmas and tokens with different frequencies
# the larger value is chosen.
####

sub mergeindices{
    my ($dir, $dir2, $outputdir) = @_;
    my ($base,
	$dirstring,
	@aFileList,
	$inputfilename,
	$token,
	$freq,
	$prevfreq,
	%freqhash,
       	@keys,
	$key,
	);

  #  print "$dir\n";
    
    $dirstring = "$dir\/\[1\-9\]\*";

    print "mergeindices: search for $dirstring\n";
    @aFileList = glob ($dirstring);
   
    # print @aFileList;
    
    foreach $inputfilename (@aFileList)
    {
	chomp ($inputfilename);
	$inputfilename = basename($inputfilename);
	# print "Processing: $inputfilename\n";
	%freqhash = ();

# first read in the first file with frequencies
	open my $INPUT1, '<:encoding(UTF-8)', "$dir\/$inputfilename" or die "couldn't open $inputfilename: $!";
	while(<$INPUT1>)
	{
	    chomp($_);
	   # print "$dir line: $_ \n";
	    if ($_ =~ /^(.+?)\#(\d+?)$/ )
	    {
	#	print "$dir line: $_ \n";
		$token = $1;
		$freq = $2;
		$freqhash{$token} = $freq; 
	    }
	}
	close $INPUT1;

# then treat the second file
	
	open my $INPUT2, '<:encoding(UTF-8)', "$dir2\/$inputfilename" or die "couldn't open $inputfilename: $!";
	
	while(<$INPUT2>)
	{
	   chomp($_);
	    
	    if ($_ =~ /^(.+?)\#(\d+?)$/ )
	    {
	#	print "$dir2 line: $_ \n";
		$token = $1;
		$freq = $2;
		if (exists $freqhash{$token})
		{
		   if ($freqhash{$token} < $freq) # previous freq is smaller
		   {
		    $freqhash{$token} = $freq;	
		   # print "$token : new entry with freq of $freq\n";
		   }
		  # else #nothing, leave entry as is
		   #{
		   #    
		   #}
		}
		else
		{
		$freqhash{$token} = $freq;
		} 
	    }
	}
	close $INPUT2;
    
	    
	# now print out freqhash to new file
	    
	@keys = sort {$freqhash{$b} <=> $freqhash{$a}} keys %freqhash;

	# same filename, different dir	
	open my $OUTPUTC, '>:encoding(UTF-8)', "$outputdir\/$inputfilename" or die "couldn't open $outputdir\/$inputfilename: $!";
	
	foreach $key (@keys) 
	{
	    print $OUTPUTC "$key\#$freqhash{$key}\n";
	} 
	close $OUTPUTC;
	
	%freqhash = ();
    }
}

############

# repair "Bohnenspross|Bohnensprosse 1049175	1" in XY.lemmaindex.sort
# tests for similarity of the tokens, the beginnings have to be the same

sub repairdoublelemmas{
    my ($inputfilename, $soutputfilename) = @_;
    my (
	$token,
	$freq,
	$filename,
	@alternatives,
	@substralternatives,
	@uniqsubstr,
	$alternative,
	);
    
    if ( ! -e $inputfilename) {die "$inputfilename does not exist."};

    open my $INPUTC, '<:encoding(UTF-8)', "$inputfilename" or die "couldn't open $inputfilename: $!";
 
    open my $OUTPUTC, '>:encoding(UTF-8)', "$soutputfilename" or die "couldn't open $soutputfilename: $!";

    while(<$INPUTC>)
	{
	   # print "line: $_ \n";
	    chomp($_);
	    if ($_ =~ /^(.+?)\t(\d+?)\t(\d+?)$/ )
	    {
		$token = $1;
		$filename = $2;
		$freq = $3;
		unless ($token =~ /^[^}{]+\|[^}{]+/) # looking for multi-lemma expressions, but { indicates usually tags
		{
		    print $OUTPUTC "$_\n";
		}
		else
		{
		 #   print "$_\n";
		    @alternatives =  split /[|]/, $token;
		  #  print "@alternatives\n";
		    # first two letters of everything, small letters
		    @substralternatives = map {tr/äöü/aou/r,}  (map {lc (substr ($_, 0, 2))} @alternatives);
		   # @substralternatives =   map {tr/äöü/aou/r, lc (substr ($_, 0, 2))} @alternatives;
		  #  print "Substralts: @substralternatives\n";
		    
		    @uniqsubstr = uniq @substralternatives;
		    
		   # print "uniqsubstr: @uniqsubstr\n";
		    
		    if ($#uniqsubstr < 1)
		    {
		    # should be identical, if not then just print the line

		#	print "split: @alternatives\n";
			foreach $alternative (uniq @alternatives)
			{
			    print $OUTPUTC "$alternative\t$filename\t$freq\n";
			}
		    }
		    else
		    {
			print $OUTPUTC "$_\n";
		    }
		}
	    }
	}
    close $INPUTC;
    close $OUTPUTC;
}

## For every tab-segmented line with two columns, this sorts and unifies the entries of the second column (delimiter #)

sub remove_duplicates_insecondcol{
    my ($inputfile, $outputfile) = @_;
    my ($token,
	$secondcol,
	@asecondcol,
	@uniqasecondcol,
	);


    print "remove duplicates of $inputfile to $outputfile\n";

    open my $OUTPUTA, '>:encoding(UTF-8)', "$outputfile" or die "couldn't open $outputfile: $!";
    
    open my $INPUTA, '<:encoding(UTF-8)', "$inputfile" or die "Could not open $inputfile: $!";    

    
    while (<$INPUTA>)
    {
	chomp ($_);
#	print "Line $_\n";
	
	if ($_ =~ /^(.+?)\t(.+)$/)
	{
	  #  print "Line2 $_\n";
	    $token = $1;
	    $secondcol = $2;
	    @asecondcol = split "\#", $secondcol;
	    @uniqasecondcol = sort {$a <=> $b} uniq @asecondcol;
	    $secondcol = join("\#", @uniqasecondcol);
	    print $OUTPUTA "$token\t$secondcol\n";
	}
	else
	{
	    print $OUTPUTA "$_\n";
	}
    }
    	close $INPUTA;
	close $OUTPUTA;
}
