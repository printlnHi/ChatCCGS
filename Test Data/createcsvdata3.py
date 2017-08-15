'''
    createcsvdata2.0.py
    
    A program to create some test data for the ChatCCGS server.
    This is a basic level of data, with 200 students and 2 classes, each with 100 students.
    No student is in more than one class.
    
    This program is an update to 1.0, and now assigns students to 4 classes.
    Each class has 50 students and there are 16 different classes.
    
    Sections to be updated in later versions are commented.
    
    By N. Patrikeos on 29 Jul 17
    
    '''

from createcsvdata2 import *

students = createStudents()
classes = createClasses(students)

class Enrolment(object):
    def __init__(self, studentID, classID, ID):
        self.ID = ID
        self.studentID = studentID
        self.classID = classID

def createEnrolments(students):
    enrolments = []
    idcount = 0

    for student in students:
        for c in student.classes:
            enrolments.append(Enrolment(student.ID, c, idcount))
            idcount += 1
    return enrolments
            
def writeToCSV2(students, classes, enrolments):
    
    fstudents = []
    fclasses = []
    
    for student in students:
        fstudents.append({'ID':str(student.ID), 'name':student.name, 'password':student.password})
    
    for c in classes:
        fclasses.append({'ID':c.code})
        
    studentWriter = csv.DictWriter(open('studentData.csv', 'w'), fieldnames=["ID", "name", "password"])
    studentWriter.writeheader()

    for student in fstudents:
        studentWriter.writerow(student)

    classWriter = csv.DictWriter(open('classData.csv', 'w'), fieldnames=["ID"])
    classWriter.writeheader()

    for c in fclasses:
        classWriter.writerow(c)
    
    enrolmentWriter = csv.DictWriter(open('enrolmentData.csv', 'w'), fieldnames=["ID", "studentID", "classID"])
    enrolmentWriter.writeheader()
    
    for e in enrolments:
        enrolmentWriter.writerow(convertDictValsToStr(e.__dict__))
        
if __name__ == '__main__':

    students = createStudents()
    classes = createClasses(students)
    enrolments = createEnrolments(students)
    writeToCSV2(students, classes, enrolments)
