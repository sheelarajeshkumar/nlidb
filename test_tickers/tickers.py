import sys
reload(sys)
sys.setdefaultencoding('utf-8')
import pyexcel as pe
import pyexcel.ext.xlsx
records = pe.get_records(file_name="yahoo.xlsx")
c=0
#f = open("tickers.txt", "w")
for record in records:
	print ("%s::%s" %(record['Ticker'].encode('utf-8'),record['Name'].encode('utf-8')))
	#f.write("%s::%s\n" % (record['Ticker'], record['Name']))

#f.close()
