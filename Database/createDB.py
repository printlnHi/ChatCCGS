import sqlite3


#NOTE: Create() is INCREDIBLY dangerous. It will DELETE ALL DATA IN THE DATABASE
# in order to redeclare. DUMP ALL ARCHIVED MESSAGES BEFORE

def Create(filename):
    try:
        if(input("WARNING: THIS WILL DELETE ALL EXISTING DATA IN THE DB FILE\nReset/Create Database? (Y/N): ") == "Y"):
            con = sqlite3.connect(filename)
            cur = con.cursor()

            print("Dropping all tables")
            cur.executescript("""DROP TABLE IF EXISTS Messages;
                                DROP TABLE IF EXISTS Archived;
                                DROP TABLE IF EXISTS Students;
                                DROP TABLE IF EXISTS Blocks;
                                DROP TABLE IF EXISTS Classes;
                                DROP TABLE IF EXISTS Enrolments""")
            
            print("Declaring tables")
            cur.executescript("""CREATE TABLE Students(ID INT, password TEXT, name TEXT, PRIMARY KEY(ID));

                                CREATE TABLE Archived(ID INT, content TEXT, datestamp TEXT,
                                authorID INT, recipientID INT, PRIMARY KEY (ID), FOREIGN KEY(authorID)
                                REFERENCES Students(ID), FOREIGN KEY (recipientID) REFERENCES Students(ID));
                                
                                CREATE TABLE Messages(ID INT, content TEXT, datestamp TEXT,
                                authorID INT, recipientID INT, PRIMARY KEY (ID), FOREIGN KEY(authorID)
                                REFERENCES Students(ID), FOREIGN KEY (recipientID) REFERENCES Students(ID));

                                CREATE TABLE Blocks(blockID INT, blockerID INT, blockedID INT, PRIMARY KEY(blockID),
                                FOREIGN KEY (blockerID) REFERENCES Students(ID), FOREIGN KEY (blockedID) REFERENCES Students(ID));

                                CREATE TABLE Classes(ID TEXT, PRIMARY KEY(ID));

                                CREATE TABLE Enrolments(ID INT, studentID INT, classID TEXT, PRIMARY KEY(ID), FOREIGN KEY (classID)
                                REFERENCES Classes(ID), FOREIGN KEY (studentID) REFERENCES Students(ID));""")

            print("Tables declared. Committing")

            con.commit()

                                
        
    except sqlite3.Error:
        print("SQL error occurred creating database")
        if con:
            print("Rolling back DB")
            con.rollback()


if __name__ == "__main__":
    Create(input("File name: "))
