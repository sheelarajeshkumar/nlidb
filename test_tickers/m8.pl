#!/usr/bin/perl -w
use HTML::TableExtract;
use LWP::Simple; #interact with web


$url  = "http://finance.yahoo.com/q/cp?s=^DJI"; #get the html file
$file = 'yahoo.html';
$parentDir = 'Companies';
$fixedmain = 'http://finance.yahoo.com/q?s=';
$fixedprofile = 'http://finance.yahoo.com/q/pr?s=';
$fixedstatistics = 'http://finance.yahoo.com/q/ks?s=';
$filename = 'tickers'; #to store the tickers and corresponding company name

#generateTicket();  #Generates tickets

open(FILE, '<',$filename);

while (my $row = <FILE>)
{
  	chomp $row;
	@split = split ('::',$row);
  	#print $split[0],"\n";
	push @Dir,$parentDir;
	push @Dir,$split[0];
	print "@Dir\n";
	$ret = createdir(@Dir);
	#print "$ret\n\n";
	@Dir = ();
	undef @Dir;

	$mainURL = $fixedmain.$split[0];
	print "$mainURL\n";			
	$mainfile = $split[0].".html";
	getstore($mainURL,$ret . '/' .$mainfile);
	
	$ProfileURL = $fixedprofile.$split[0];
	print "$ProfileURL\n";			
	$Profilefile = "profile.html";
	getstore($ProfileURL,$ret . '/' .$Profilefile);
	
	$StatisticsURL = $fixedstatistics.$split[0];
	print "$StatisticsURL\n";			
	$Statisticsfile = "statistics.html";
	getstore($StatisticsURL,$ret . '/' .$Statisticsfile);
	
}

close FILE;

sub createdir
{	
	$f="";
	@arr = @_;
	for($index=0;$index<=$#arr;$index++)
	{
        	$f.=$arr[$index];
    		mkdir $f,0755; # create directories
		$f.="/";    
	}
	return $f;

}


sub generateTicket{
    
    getstore($url, $file); #opens the link and 	
    $te = HTML::TableExtract->new( headers => [qw(Symbol Name)] ); #opne the downloaded html file and extract table data with tickers and contained data
    $te->parse_file($file); #pars the html file
    open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
    # Examine all matching tables
    foreach $ts ($te->tables)
    {
        #print "Table (", join(',', $ts->coords), "):\n";
        foreach $row ($ts->rows)
        {
            $f =  join('::', @$row);
            print $fh $f,"\n"; #write the ticker and company name into file
        }
    }
    close $fh; # close tickers.txt
}




