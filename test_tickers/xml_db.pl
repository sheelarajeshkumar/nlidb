#!/usr/bin/perl -w
use XML::Simple;
use DBI;
use Data::Dumper;
use XML::XPath;

my $dbh = DBI->connect('dbi:mysql:yahoo', 'root', 'swecha') || die $DBI::errstr;




magData(); #insert into managment table
profileData(); #insert data into profile Table
finanData(); #insert data into finance table
$dbh->disconnect;

sub magData{
my $xp = XML::XPath->new(filename => 'Management.xml');
my $sth = $dbh->prepare(qq{INSERT INTO `management`(`serialno`, `mgt_ticker`, `high_paid_emp`, `executive_list`, `high_pay`) VALUES (?,?,?,?,?)});
foreach my $row ($xp->findnodes('/management/COMPANY')) {

    # extract from the XML
    my $sr = $row->find('serialno')->string_value;
    my $tk = $row->find('TICKER')->string_value;
    my $highpay = $row->find('high_paid_emp')->string_value;
    my $high_pay = $row->find('high_pay')->string_value;
    my $ex_list = $row->find('executive_list')->string_value;
    
    # insert into the db (using placeholders)
    $sth->execute($sr,$tk,$highpay,$ex_list,$high_pay) || die $DBI::errstr;
}


print "Success!!! \n";
}


sub profileData{
my $xp = XML::XPath->new(filename => 'Profile.xml');
my $sth = $dbh->prepare(qq{INSERT INTO `profiles`(`ticker`, `name`, `Address`, `phonenum`, `website`, `Index_mem`, `sector`, `industry`, `full_time`, `bus_summ`) VALUES (?,?,?,?,?,?,?,?,?,?)});
foreach my $row ($xp->findnodes('/Profile/COMPANY')) {

    # extract from the XML
    my $name = $row->find('name')->string_value;
    my $tk = $row->find('TICKER')->string_value;
    my $Address = $row->find('Address')->string_value;
    my $phonenum = $row->find('Phone')->string_value;
    my $website = $row->find('Website')->string_value;
    my $Index_mem = $row->find('Index_Membership')->string_value;
    my $sector = $row->find('Sector')->string_value;
    my $industry = $row->find('Industry')->string_value;
    my $full_time = $row->find('Full_Time_Employees')->string_value;
    my $bus_summ = $row->find('Summary')->string_value;

    # insert into the db (using placeholders)
    $sth->execute($tk,$name,$Address,$phonenum,$website,$Index_mem,$sector,$industry,$full_time,$bus_summ) || die $DBI::errstr;
}


print "Success!!! \n";
}


sub finanData{
my $xp = XML::XPath->new(filename => 'Statistics.xml');
my $sth = $dbh->prepare(qq{INSERT INTO `finance`(`sno`, `fin_ticker`, `marketcap`, `e_value`, `ret_on_assets`, `tot_cash`, `op_cash`, `lev_free_cf`, `tot_debt`, `curr_ratio`, `gross_profit`, `prof_margin`) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)});
foreach my $row ($xp->findnodes('/Statistics/COMPANY')) {

    # extract from the XML
    my $sr = $row->find('serialno')->string_value;
    my $tk = $row->find('TICKER')->string_value;
    
    my $marketcap = $row->find('Market_Cap__intraday_5')->string_value;
    my $e_value = $row->find('Enterprise_Value__Apr_4_2016_3')->string_value;
    my $ret_on_assets= $row->find('Return_on_Assets__ttm_')->string_value;
    
    my $tot_cash= $row->find('Total_Cash__mrq_')->string_value;
    my $op_cash= $row->find('Operating_Cash_Flow__ttm_')->string_value;
    my $lev_free_cf= $row->find('Levered_Free_Cash_Flow__ttm_')->string_value;
    
    my $tot_debt= $row->find('Total_Debt__mrq_')->string_value;
    my $curr_ratio= $row->find('Current_Ratio__mrq_')->string_value;
    my $gross_profit= $row->find('Gross_Profit__ttm_')->string_value;
    my $prof_margin= $row->find('Profit_Margin__ttm_')->string_value;

    
    # insert into the db (using placeholders)
    $sth->execute($sr,$tk,$marketcap,$e_value,$ret_on_assets,$tot_cash,$op_cash,$lev_free_cf,$tot_debt,$curr_ratio,$gross_profit,$prof_margin) || die $DBI::errstr;
}

print "Success!!! \n";
}


