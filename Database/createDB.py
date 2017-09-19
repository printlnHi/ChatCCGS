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
                                DROP TABLE IF EXISTS Enrolments;
                                DROP TABLE IF EXISTS CustomGroups;
                                DROP TABLE IF EXISTS CustomEnrolments;""")
            
            print("Declaring tables")
            cur.executescript("""CREATE TABLE Students(ID INTEGER PRIMARY KEY AUTOINCREMENT, password TEXT, name TEXT);

                                CREATE TABLE Archived(ID INTEGER PRIMARY KEY AUTOINCREMENT, content TEXT, datestamp TEXT,
                                authorID INT, recipientID INT, groupID TEXT, customGroup INT, FOREIGN KEY(authorID)
                                REFERENCES Students(ID), FOREIGN KEY (recipientID) REFERENCES Students(ID));
                                
                                CREATE TABLE Messages(ID INTEGER PRIMARY KEY AUTOINCREMENT, content TEXT, datestamp TEXT,
                                authorID INT, recipientID INT, groupID TEXT, customGroup INT, FOREIGN KEY(authorID)
                                REFERENCES Students(ID), FOREIGN KEY (recipientID) REFERENCES Students(ID));

                                CREATE TABLE Blocks(blockID INTEGER PRIMARY KEY AUTOINCREMENT, blockerID INT, blockedID INT,
                                FOREIGN KEY (blockerID) REFERENCES Students(ID), FOREIGN KEY (blockedID) REFERENCES Students(ID));

                                CREATE TABLE Classes(ID TEXT, PRIMARY KEY(ID));

                                CREATE TABLE Enrolments(ID INTEGER PRIMARY KEY AUTOINCREMENT, studentID INT, classID TEXT, FOREIGN KEY (classID)
                                REFERENCES Classes(ID), FOREIGN KEY (studentID) REFERENCES Students(ID));

                                CREATE TABLE CustomGroups(ID INTEGER PRIMARY KEY AUTOINCREMENT, creatorID INT, FOREIGN KEY (creatorID) REFERENCES Students(ID));

                                CREATE TABLE CustomEnrolments(ID INTEGER PRIMARY KEY AUTOINCREMENT, studentID INT, classID INT,
                                FOREIGN KEY (studentID) REFERENCES Students(ID), FOREIGN KEY (classID) REFERENCES CustomGroups(ID));

                                CREATE TABLE GroupStatusMessages(ID INTEGER PRIMARY KEY AUTOINCREMENT, recipientID INT, content TEXT, datestamp TEXT,
                                groupID INT, FOREIGN KEY (recipientID) REFERENCES Students(ID), FOREIGN KEY (groupID) REFERENCES CustomGroups(ID));""")

            print("Tables declared. Committing")

            con.commit()

                                
        
    except sqlite3.Error:
        print("SQL error occurred creating database")
        if con:
            print("Rolling back DB")
            con.rollback()


if __name__ == "__main__":
    Create(input("File name: "))

