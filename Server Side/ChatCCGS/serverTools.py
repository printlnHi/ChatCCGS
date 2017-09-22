import sqlite3
import datetime

db = "test.db"

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

def classExists(classID):
    data = None
    
    try:
        con = sqlite3.connect(db)
        cur = con.cursor()

        #DB accessing
        t = (classID,)

        cur.execute("SELECT * FROM Classes WHERE ID = ?;",t)

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

def datestampIsValid(stamp):
    # yyyy-mm-dd hh:mm:ss
    try:
        dt_obj = datetime.datetime.strptime(stamp, '%Y-%m-%d %H:%M:%S')
        return True
    except:
        return False

#For non custom groups only
def getMembersOfGroup(group):
    data = None
    try:
        con = sqlite3.connect(db)
        cur = con.cursor()

        #DB accessing
        t = (group,)

        cur.execute("SELECT (studentID) FROM Enrolments WHERE classID=?",t)
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

#For non custom groups only
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
        newinp["customGroup"] = 0

        pushMessage(newinp)

    return "100 Continue"

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

def userIsInClass(user, group):
    return (user,) in getMembersOfGroup(group)


