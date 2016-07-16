#!/usr/bin/perl -w
#use strict;
use HTML::TableExtract;
use Data::Dumper;
use XML::Writer;
use IO::File;
use XML::Simple;
use DBI;
=begin
my $driver = "mysql"; 
my $database = "yahoo";
my $dsn = "DBI:$driver:database=$database";
my $userid = "root";
my $password = "swecha";
my $dbh = DBI->connect($dsn, $userid, $password,{AutoCommit => 1}) or die $DBI::errstr;
$xml = new XML::Simple;

opendir my $dir, "Companies/" or die "Cannot open directory: $!";
@files = readdir $dir;
closedir $dir;

$c=1;
foreach my $d(@files){
    if ($d=~/^[a-zA-Z]/) {
       print $d."   $c\n";
         $c++;
    }
}
=cut

#Opening writer for writing data into xml file
$output = new IO::File(">Statistics.xml");
$writer = new XML::Writer(OUTPUT => $output);
$output2 = new IO::File(">Profile.xml");
$writer2 = new XML::Writer(OUTPUT => $output2);
$output3 = new IO::File(">Management.xml");
$writer3 = new XML::Writer(OUTPUT => $output3);
$writer2->startTag("Profile");
$writer->startTag("Statistics");
$writer3->startTag("management");


#creating array the signifies the input fields
@array_stat = ('Market Cap (intraday)5','Enterprise Value (Apr 4, 2016)3','Return on Assets (ttm)','Total Cash (mrq)','Operating Cash Flow (ttm)','Levered Free Cash Flow (ttm)','Total Debt (mrq)','Current Ratio (mrq)','Gross Profit (ttm)','Profit Margin (ttm)');
@array_pro=("Index Membership","Sector","Industry","Full Time Employees");
@files = <Companies/*>;
$se=1;
foreach $file (@files) {   #itteraring through all directorys and trading .html files
    if (-d $file) {
        @ar=split /\//,$file;        
        #print $file."/".$ar[1].".html\n";
        #readTicketData($file."/".$ar[1].".html\n");
        
        $writer2->startTag("COMPANY");
        $writer2->startTag("TICKER");
        $writer2->characters($ar[1]);
        $writer2->endTag("TICKER");
        
        $writer3->startTag("COMPANY");
        $writer3->startTag("serialno");
        $writer3->characters($se);
        $writer3->endTag("serialno");
        $writer3->startTag("TICKER");
        $writer3->characters($ar[1]);
        $writer3->endTag("TICKER");
             readProfileData($file."/profile.html");        #Reading all profile.html data and dumping it into profile.xml
        $writer2->endTag("COMPANY");
        $writer3->endTag("COMPANY");
      
        $writer->startTag("COMPANY");
        $writer->startTag("TICKER");
        $writer->characters($ar[1]);
        $writer->endTag("TICKER");
        $writer->startTag("serialno");
        $writer->characters($se);
        $writer->endTag("serialno");
              readStatisticsData($file."/statistics.html");   #Reading all statistics.html data and dumping it into statistics.xml
        $writer->endTag("COMPANY");
       
       $se++;
        #last;
    }
}


#Ending tags of XML File
$writer->endTag("Statistics");
$writer->end();
$writer2->endTag("Profile");
$writer2->end();
$writer3->endTag("management");
$writer3->end();
$output2->close();
$output->close();
$output3->close();




# read XML file
   #$data = $xml->XMLin("Management.xml");
   
   # print output
   #print Dumper($data);
   
   
   #print $d->{'serialno'},$d->{'TICKER'},$d->{'high_paid_emp'},$d->{'executive_list'},$d->{'high_pay'};
   #$sth = $dbh->prepare("INSERT INTO `management`(`serialno`, `mgt_ticker`, `high_paid_emp`, `executive_list`, `high_pay`) VALUES (?,?,?,?,?);");
   #$sth->execute($data->{'serialno'},$data->{'TICKER'},$data->{'high_paid_emp'},$data->{'executive_list'},$data->{'high_pay'}) or die $DBI::errstr;
   #$sth->finish();
   #$dbh->commit or die $DBI::errstr;
   
   
   
#if (-f $file) {
#        print "This is a file: " . $file;
#}

=begin
sub readTicketData{
    $rt=$_[0];
    $file=$_;
    $te = HTML::TableExtract->new( headers => [qw(Symbol Name)] ); #opne the downloaded html file and extract table data with tickers and contained data
    $te->parse_file($file); #pars the html file
    
    ## Examine all matching tables
    foreach $ts ($te->tables)
    {
        #print "Table (", join(',', $ts->coords), "):\n";
        foreach $row ($ts->rows)
        {
            $f =  join('::', @$row);
           print $f,"\n"; #write the ticker and company name into file
        }
    }
    
}
=cut

sub readProfileData{        # Reads data from profile.html and dump it into prifile.xml
#    table data
   my $rp=$_[0];
   $flag=0;
   #$te = HTML::TableExtract->new( headers => [qw(Details)] );
   my $te = HTML::TableExtract->new(attribs => { border=>"0", cellpadding=>"2" ,cellspacing=>"1", width=>"100%"});
    #$te = HTML::TableExtract->new(attribs => { width=>"580" ,id=>"yfncsumtab", cellpadding=>"0", cellspacing=>"0", border=>"0"});
   $te->parse_file($rp); #pars the html file
   my $listemp="";
    foreach my $ts ($te->tables)
    {
        foreach my $row ($ts->rows)
        {
            my $f=join("",@$row);
            my @spli=split ':',$f;
            my $e=$spli[0];
            if ($e ~~ @array_pro) {        #Smart match is experimental 
                $e=~ s/\s/_/gci;
                $writer2->startTag($e);
                $writer2->characters($spli[1]);
                $writer2->endTag($e); 
            }
            elsif ($e =~/PayExercised/) {
                $flag=1;
            }
            elsif ($flag==1) {
                my @ter=split /,/,$e;
                $flag++;
                $writer3->startTag("high_paid_emp");
                $writer3->characters($ter[0]);
                $writer3->endTag("high_paid_emp"); 
                #print $ter[1],"**\n";
                my @l = split(/(?<=\d)(?=\D)|(?<=\D)(?=\d)/, $ter[1]);      #checking for pattren match from the string
                $writer3->startTag("high_pay");
                $writer3->characters($l[3].$l[4].$l[5].$l[6]);
                $writer3->endTag("high_pay");
                $flag=0;
               
            }
            elsif ($flag==0) {
               @qsa=split /,/,$e;
               #print $qsa[0],"&&&&&\n";
               $listemp.=$qsa[0].",";
            }
            
            
            
            
            
        }
    }
    $writer3->startTag("executive_list");
    $writer3->characters($listemp);
    $writer3->endTag("executive_list"); 
    Profiledata_sum_comp($rp);
}

sub Profiledata_sum_comp{       # Reads data from profile.html and dump it into prifile.xml
#   cmp details with summ
my $phone;
my $web;
    my $rp=$_[0];
    my $address;
    my @ttere=();
    my $mysummar="";
    my $cmp="";
    #setting the attributes for extracting sat data
    my $te = HTML::TableExtract->new(attribs => { width=>"580", id=>"yfncsumtab", cellpadding=>"0" ,cellspacing=>"0", border=>"0"});
    $te->parse_file($rp); #pars the html file
    my $d=0;
    foreach my $ts ($te->tables)
    {        
        foreach my $row ($ts->rows)
        {
            my $f=join('',@$row);
            @ttere=split /\n/,$f;
            #print $ttere[4],"^^^^^^\n";
            $mysummar=$f;
        }
    }
    my $c=0;
    foreach $val(@ttere){
        #print $val,"^^\n";
        if ($c==0) {
            $cmp=$val;
        }
        if ($c<=4) {
            $address.=$val;            
        }else{
            if ($c==5) {
               my @ph=split /\s/,$val;
               $phone=$ph[1];
            }else{
                @p=split /\s/,$val;
                $web=$p[2];
            }
 
        }
        
        if ($c>=6) {
            last;
        }
        $c++;
    }
    my @sum=split /$cmp/,$mysummar;
    $sumary=$sum[2];
    
    $writer2->startTag("Address");
    $writer2->characters($address);
    $writer2->endTag("Address");
    
    $writer2->startTag("name");
    $writer2->characters($cmp);
    $writer2->endTag("name"); 
    
    $writer2->startTag("Phone");
    $writer2->characters($phone);
    $writer2->endTag("Phone");
    
    $writer2->startTag("Website");
    $writer2->characters($web);
    $writer2->endTag("Website");
    
    $writer2->startTag("Summary");
    $writer2->characters($sumary);
    $writer2->endTag("Summary");
    #print $address," %%%%%%%%\n";
    #print $sumary,"  ********\n";
    #print $phone,"^^^^^^^^^^\n";
    #print $web,"@@@@@@@@@@@\n";
}


sub readStatisticsData{     # Reads data from statistics.html and dump it into statistics.xml
    my $rp=$_[0];
   #$te = HTML::TableExtract->new( headers => [qw(Details)] );
   my $te = HTML::TableExtract->new(attribs => { width=>"100%", cellpadding=>"2" ,cellspacing=>"1",border=>"0" });
   $te->parse_file($rp); #pars the html file
    foreach my $ts ($te->tables)
    {
        foreach my $row ($ts->rows)
        {
            my $f=join('',@$row);
            my @spli=split ':',$f;
            my $e=$spli[0];
            if ($e ~~ @array_stat) {            #comparing in a smart way
                #print $f."\n";
                $e=~ s/\s/_/gci;
                $e=~ s/\(/_/gci;
                $e=~ s/\)/_/gci;
                $e=~ s/,//gci;
                #@fn=split '(',$e;
                $writer->startTag($e);
                $writer->characters($spli[1]);
                $writer->endTag($e); 
            }
            
            #print join("\t", @$row);
            #print "\n";
            #print Dumper @$row;
        }
    }    
}
