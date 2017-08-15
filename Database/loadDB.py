import sqlite3

def AddDataFromCSVsToDB(filename, studentCSV, enrolmentCSV, classCSV):
    try:

        print("Connecting to DB")

        con = sqlite3.connect(filename)
        cur = con.cursor()

        print("Emptying old tables")

        cur.executescript("""DELETE FROM Classes;
                            DELETE FROM Students;
                            DELETE FROM Enrolments;""")

        #Student CSV
        print("Starting student CSV")
        
        student = open(studentCSV, 'rU')
        header = student.readline()
        fieldnames = header.strip().split(',')
        
        records = []
        for line in student.readlines():
            record = line.strip().split(',')
            records.append(record)

        print("Inserting data")

        cur.executemany("INSERT INTO Students(ID, name, password) VALUES(?,?,?);",records)

        #Enrolment CSV

        print("Starting enrolment CSV")
        
        enrolment = open(enrolmentCSV, 'rU')
        header = enrolment.readline()
        fieldnames = header.strip().split(',')
        
        records = []
        for line in enrolment.readlines():
            record = line.strip().split(',')
            records.append(record)

        print("Inserting data")

        cur.executemany("INSERT INTO Enrolments(ID, studentID, classID) VALUES(?,?,?);",records)

        #Classes CSV

        print("Starting Classes CSV")
        
        classes = open(classCSV, 'rU')
        header = classes.readline()
        fieldnames = header.strip().split(',')
        
        records = []
        for line in classes.readlines():
            record = line.strip().split(',')
            records.append(record)

        print("Inserting data")

        cur.executemany("INSERT INTO Classes(ID) VALUES(?);",records)

        print("Done. Committing DB and closing files")

        con.commit()

        classes.close()
        enrolment.close()
        student.close()
        
    except sqlite3.Error:
        print("SQL error. Rolling back DB")
        if con:
            con.rollback()
    finally:
        if con:
            con.close()

def Main(manual):
    if manual:
        AddDataFromCSVsToDB(input("DB: "),input("StudentCSV: "), input("EnrolmentCSV: "), input("ClassCSV: "))
    else:
        AddDataFromCSVsToDB("test.db","Data/studentData.csv","Data/enrolmentData.csv","Data/classData.csv")

if __name__ == "__main__":
    Main(False) if input("Would you like to automatically input parameters? (Y/N) ") == "Y" else Main(True)
