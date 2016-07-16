#!/usr/bin/python

import cgi, cgitb
import MySQLdb
print "Content-type:text/html\r\n\r\n"

# Open database connection
db = MySQLdb.connect("localhost","root","swecha","yahoo" )

# prepare a cursor object using cursor() method
cursor = db.cursor()



form = cgi.FieldStorage()
searchstring = form.getvalue('search')
# print "%s string" % searchstring
searchstring=searchstring.lower()
words=[]

words=searchstring.split(' ')   # Spliting of words by space
# print words.__len__()
# print words


# Stop words
stop=[]
with open('StopWords.txt') as f:
    line=f.read()
    temp=[]
    temp=line.split('\n')
    for c in temp:
        stop.append(c.strip('"'))
        # print word,"<br>"

# print stop

# print words
# Removing stop words
for wc in words:
    if wc in stop:              # [stop.__contains__(wc)]
        words.remove(wc)

# print "<br>"
# print words

# Finance table data
finance= {
    'marketcap' : ['market','capital','marketcapital','market capital'],
    'e_value' : ['enterprise','value','enterprisevalue','enterprise value'],
    'ret_on_assets' : ['returns','assets','return assets'],
    'tot_cash' : ['cash','totalcash'],
    'op_cash' : ['operating','cashflow','cash flow','operating cash flow','operatingcashflow'],
    'lev_free_cf' : ['leveredfreecashflow','levered','free','cash flow','leveredfree','cashflow','levered free','levered free cash','levered free cash flow'],
    'tot_debt' : ['total debt','debt','total','totaldebt'],
    'curr_ratio' : ['current','ratio','current ratio','currentratio'],
    'gross_profit' : ['grossprofit','gross profit','gross'],
    'prof_margin' : ['profitmargin','margin','profit margin'],
}

management = {
    'high_paid_emp' : ['high','paid','emlpoyee','highpaid','highpaidemployee','high paid employee','high paid'],
    'executive_list' : ['executivelist','executive','list','executive list'],
    'high_pay' : ['high pay','pay','highpay'],
    'mgt_ticker' : ['ticker']
}
profile = {
    'name' : ['name'],
    'Address' : ['address'],
    'phonenum' : ['phonenum','phone','phone number','phonenumber'],
    'website' : ['website'],
    'ticker' : ['ticker'],
    'Index_mem' : ['indexmembership','index membership','index','membership'],
    'sector' : ['sector'],
    'industry' : ['industry'],
    'full_time' : ['full time employees','fulltimeemployees'],
    'bus_summ' : ['summary']
}

qwery = ""
qwery += "select "
f = 0
print "<br>"
fnas=[]
pro=[]
mang=[]
result=""
# print words,"<br>"
for w in words:
    # finance data
    for key in finance:
        if w in finance[key]:
            # print key, 'corresponds to', finance[key]
            words.remove(w)
            fnas.append(key)
            qwery+=key+" "
            f=1

for w in words:
    # for management data
    for key1 in management:
        if w in management[key1]:
            words.remove(w)
            mang.append(key1)
            qwery+=key1+" "
            f=2

for w in words:
    #for profile data
    for key2 in profile:
        if w in profile[key2]:
            words.remove(w)
            pro.append(key2)
            qwery+=key2+" "
            f=3

# print fnas,"<br>",pro,"<br>",mang,"<br>"


def dataFromList(list):
    return ','.join(list)

def ticker():
    for cmp in words:
        qw="SELECT ticker from profiles where name LIKE '"
        qw+=cmp
        qw+="%'"
        # execute SQL query using execute() method.
        if cursor.execute(qw):
            # print qw,"<br>"
            # Fetch a single row using fetchone() method.
            data = cursor.fetchone()
            # print data
            return data[0]

def QueryPaser(qwer):
    if cursor.execute(qwer):
        results = cursor.fetchall()
        num=len(cursor.description)
        res=[]
        # print num,"<br>"
        for row in results:
            for i in range(0,num):
                res.append(row[i])
    return ',<br>'.join(res)


ans=""
if len(fnas)!=0:
    # print fnas,"<br>"
    q="SELECT "
    q+=dataFromList(fnas)
    q+=" FROM finance where fin_ticker= '"
    q+=ticker()+"'"
    # print q,"<br>"
    ans+=QueryPaser(q)+"<br>"

if len(pro)!=0:
    # print pro,"<br>"
    q="SELECT "
    q+=dataFromList(pro)
    q+=" FROM profiles where ticker= '"
    q+=ticker()+"'"
    # print q,"<br>"
    ans+=QueryPaser(q)+"<br>"

if len(mang)!=0:
    # print mang,"<br>"
    q="SELECT "
    q+=dataFromList(mang)
    q+=" FROM management where mgt_ticker= '"
    q+=ticker()+"'"
    # print q,"<br>"
    ans+=QueryPaser(q)+"<br>"

if f==0:
    qwery+=" * from profiles where ticker = '"
    # Name to ticker
    qwery +=ticker()+"'"
    ans+=QueryPaser(qwery)


# print words
# print "<br>"
# print qwery

# print fnas,"<br>",pro,"<br>",mang,"<br>"

print "Q: ",searchstring,"<br>ANS: ",ans

# disconnect from server
db.close()


