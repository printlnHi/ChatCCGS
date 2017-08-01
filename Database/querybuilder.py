def createQueries(in_name, out_name, table):
  file_in = open(in_name, 'rU')
  file_out = open(out_name, 'a')
  
  file_out.write("print('start inserting data into " + table + " table<br />')\n")

  header = file_in.readline()
  field_names = header.strip().split(',')

  records = []
  for line in file_in.readlines():
    record = line.strip().split(',')
    records.append(record)

  for record in records:
    if record[0] != "":
      line = "cursor.execute('''INSERT INTO " + table + " ("
      for name in field_names:
        line += name + ', '
      line = line[:-2] + ') VALUES ('
      for field in record:
        if field.isdigit():
          line += field.strip() + ', '
        else:
          line += '"' + field.strip() + '", '
        out_line = line[:-2] + ")''')\n"
      file_out.write(out_line)

  file_out.write("print('finish inserting data into " + table + " table<br />')\n")

# This adds the code for the start of the CGI program
def setupCGI(dbName, out_file):
  script = '''#!/usr/bin/python
print('Content-type: text/html\\n\\n')

import cgi
import cgitb; cgitb.enable()
import sqlite3\n\n'''
  script += "mydb = '" + dbName + "'\n"
  script += '''conn = sqlite3.connect(mydb)
cursor = conn.cursor()\n\n'''
  f_out = open(out_file, "w")
  f_out.write(script)
  
# This adds the code for the end of the CGI program
def closeCGI(out_file):
  script = 'conn.commit()\ncursor.close()'
  f_out = open(out_file, "a")
  f_out.write(script)

##############################
# CHANGE THE FOLLOWING LINES TO PRODUCE YOUR CGI PROGRAM:
#
#
# These are the input csv files for your data.
# Remember the first line should list the names of each field
in_files = ["Data/classData.csv", "Data/enrolmentData.csv","Data/studentData.csv"]

# These are the tables that each csv file corresponds to
tables = ["Classes", "Enrolments","Students"]

# The name of the database
database = "test.db"

# The name of the python file that you will create
out_file = "insert_records.py"
#
##############################

# This runs the program!
setupCGI(database, out_file)
for i in range(len(in_files)):
  createQueries(in_files[i], out_file, tables[i])
closeCGI(out_file)
