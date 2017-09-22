import sqlite3
import datetime
#import pytz

db = "../test.db"

def createCustomGroup(creatorID,name,members):
    rowid = None
    try:
        con = sqlite3.connect(db)
        cur = con.cursor()

        #DB accessing
        cur.execute("INSERT INTO CustomGroups(creatorID) VALUES(?)",(creatorID,))
        cur.execute("SELECT last_insert_rowid();")

        rowid = cur.fetchone()[0]

        for member in members:
            if member != creatorID:
                cur.execute("INSERT INTO CustomEnrolments(studentID,classID) VALUES(?,?);",(member,rowid))
        cur.execute("INSERT INTO CustomEnrolments(studentID,classID) VALUES(?,?);",(creatorID,rowid))

        con.commit()
        
    except sqlite3.Error:
        
        if con:
            con.rollback()
            con.close()

        return "500 Internal Server Error"
    finally:
        if con:
            con.close()

    return rowid

def validate(user,password):
    data = None

    try:
        con = sqlite3.connect(db)
        cur = con.cursor()

        #DB accessing
        t = (user,password)

        cur.execute("SELECT * FROM Students WHERE ID = ? AND password = ?;",t)

        data = cur.fetchall()

        
    except sqlite3.Error:
        print("500 Internal Server Error")
        if con:
            con.rollback()
            con.close()
        print("error in validate")
        exit()
    finally:
        if con:
            con.close()
    
    if data:
        return True
    else:
        return False

def toJSON(data):
    dic = {}
    for message in data:
        dic[message[0]] = message[1:]
    return dic

def toMultiLine(data):
    string = ""
    for message in data:
        string=string+str(message)+"\n"
    return string

def studentsExist(students):
    try:
        con = sqlite3.connect(db)
        cur = con.cursor()

        for student in students:
            data = None
            cur.execute("SELECT ID,name FROM Students WHERE ID=?;",(student,))
            data = cur.fetchone()
            if not data:
                return False
    except sqlite3.Error:
        print("ERROR IN STUDENTSEXIST")
        if con:
            con.rollback()
    finally:
        if con:
            con.close()
    return True

def groupExists(classID):
    data = None
    
    try:
        con = sqlite3.connect(db)
        cur = con.cursor()

        #DB accessing
        t = (classID,)

        cur.execute("SELECT * FROM CustomGroups WHERE ID = ?;",t)

        data = cur.fetchall()

        
    except sqlite3.Error:
        print("500 Internal Server Error")
        if con:
            con.rollback()
            con.close()
        exit()
    finally:
        if con:
            con.close()
    
    if data:
        return True
    else:
        return False

def userIsInGroup(user, group):
    return (user,) in getMembersOfGroup(group)

def getMembersOfGroup(group):
    data = None
    try:
        con = sqlite3.connect(db)
        cur = con.cursor()

        #DB accessing
        t = (group,)

        cur.execute("SELECT (studentID) FROM CustomEnrolments WHERE classID=?",t)
        data = cur.fetchall()
        
    except sqlite3.Error:
        
        if con:
            con.rollback()
            con.close()
        return "500 Internal Server Error"
        
    finally:
        if con:
            con.close()

    return data

def datestampIsValid(stamp):
    # yyyy-mm-dd hh:mm:ss
    try:
        dt_obj = datetime.datetime.strptime(stamp, '%Y-%m-%d %H:%M:%S')
        return True
    except:
        return False

def pushGroupMessage(inp):
    recipients = getMembersOfGroup(inp["group"])
    if len(recipients)==0:
        return "602 No Group"

    for recipient in recipients:
        newinp = {}
        newinp["username"] = inp["username"]
        newinp["password"] = inp["password"]
        newinp["content"] = inp["content"]
        newinp["recipient"] = recipient[0]
        newinp["datestamp"] = inp["datestamp"]
        newinp["groupID"] = inp["group"]
        newinp["customGroup"] = 1

        pushMessage(newinp)

    return "100 Continue"

def pushMessage(inp):
    if not studentExists(inp["recipient"]):
        return "601 Recipient Not Found"

    if inp["recipient"] == inp["username"]:
        return "600 Sender is Recipient"

    #main bulk

    try:
        con = sqlite3.connect(db)
        cur = con.cursor()

        #DB accessing
        if inp["groupID"] == None or inp["customGroup"] == None:
            t = (inp["content"],inp["datestamp"],inp["username"],inp["recipient"])

            cur.execute("INSERT INTO Messages(content,datestamp,authorID,recipientID,groupID,customGroup) VALUES(?,?,?,?,NULL,NULL);",t)
        else:
            t = (inp["content"],inp["datestamp"],inp["username"],inp["recipient"],inp["groupID"],inp["customGroup"])

            cur.execute("INSERT INTO Messages(content,datestamp,authorID,recipientID,groupID,customGroup) VALUES(?,?,?,?,?,?);",t)
        
        con.commit()
        
    except sqlite3.Error:
        
        if con:
            con.rollback()
            con.close()
        return "500 Internal Server Error"
        
    finally:
        if con:
            con.close()

    #status code

    return "100 Continue"

def studentExists(studentID):
    data = None
    
    try:
        con = sqlite3.connect(db)
        cur = con.cursor()

        #DB accessing
        t = (studentID,)

        cur.execute("SELECT * FROM Students WHERE ID = ?;",t)

        data = cur.fetchall()

        
    except sqlite3.Error:
        print("500 Internal Server Error")
        if con:
            con.rollback()
            con.close()
        exit()
    finally:
        if con:
            con.close()
    
    if data:
        return True
    else:
        return False

def addToCustomGroup(group, members):
    try:
        con = sqlite3.connect(db)
        cur = con.cursor()

        for member in members:
            cur.execute("INSERT INTO CustomEnrolments(studentID,classID) VALUES(?,?);",(member,group))

        con.commit()
        
    except sqlite3.Error:
        
        if con:
            con.rollback()
            con.close()

        return "500 Internal Server Error"
    finally:
        if con:
            con.close()

    return "100 Continue"

def getGroupsForMember(user):
    data = None
    try:
        con = sqlite3.connect(db)
        cur = con.cursor()

        #DB accessing
        t = (user,)

        cur.execute("SELECT (classID) FROM CustomEnrolments WHERE studentID=?",t)
        data = cur.fetchall()
        
    except sqlite3.Error:
        
        if con:
            con.rollback()
            con.close()
        return "500 Internal Server Error"
        
    finally:
        if con:
            con.close()

    return data

def disbandGroup(groupID):
    try:
        con = sqlite3.connect(db)
        cur = con.cursor()

        cur.execute("DELETE FROM CustomGroups WHERE ID=?;",(groupID,))
        cur.execute("DELETE FROM CustomEnrolments WHERE classID=?;",(groupID,))
        
        con.commit()
        
    except sqlite3.Error:
        
        if con:
            con.rollback()
            con.close()

        return "500 Internal Server Error"
    finally:
        if con:
            con.close()

    return "100 Continue"

def removeMemberFromGroup(memberID,groupID):
    try:
        con = sqlite3.connect(db)
        cur = con.cursor()

        cur.execute("DELETE FROM CustomEnrolments WHERE studentID=? AND classID=?;",(memberID,groupID))
        
        con.commit()
        
    except sqlite3.Error:
        
        if con:
            con.rollback()
            con.close()

        return "500 Internal Server Error"
    finally:
        if con:
            con.close()

    return "100 Continue"

def removeDuplicates(data):
    seen = set([])
    keep = []
    #If content, author, datestamp, groupID and customGroup are the same, only the first found will be kept
    for dataset in data:
        new = (dataset[1],dataset[2],dataset[3],dataset[5],dataset[6])
        if new not in seen:
            keep.append(dataset)
            seen.add(new)
    return keep

def addStatusMessage(recipient, groupID, message):
    #adds with datestamp of current time
    #tz = pytz.timezone("Australia/Perth")
    #stamp = datetime.datetime.now(tz).strftime('%Y-%m-%d %H:%M:%S')
    stamp = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')

    try:
        
        con = sqlite3.connect(db)
        cur = con.cursor()

        t = (recipient, message, stamp, groupID)
        cur.execute("INSERT INTO GroupStatusMessages(recipientID,content,datestamp,groupID) VALUES(?,?,?,?);",t)
        con.commit()
    except sqlite3.Error:
        print("sql error occurred in CGServerTools/addStatusMessage() PLEASE REPORT")
        if con:
            con.rollback()
    finally:
        if con:
            con.close()
