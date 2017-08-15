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

from random import randint, choice
import csv

f_in = open('names.txt').readlines()

class Student(object):
    # Base object model for a student
    
    def __init__(self, ID, name, password, classes):
        self.ID = ID
        self.name = name
        self.classes = classes
        self.password = password

class Class(object):
    # Base object model for a class
    ### to be updated to have class subject as well...
    
    def __init__(self, code, students):
        self.code = code
        self.students = students


def createStudents():
    # Creates the array of students
    
    counter1 = 0
    counter2 = 0
    class_bases = [["10EN1", "10EN2", "10EN3", "10EN4"], ["10MS1", "10MS2", "10MS3", "10MS4"],
                   ["10GY1", "10CE2", "10HY3", "10GP1"], ["10CH1", "10BY2", "10PH3", "10APH4"]]

    students = []
    studentIDs = []
    
    for line in f_in:
        
        studentID = None
        studentClasses = class_bases[counter1]
        
        while studentID in studentIDs or studentID is None:
            studentID = randint(100, 400)
        
        studentIDs.append(studentID)

        students.append(Student(studentID, line.strip(), 'password123', studentClasses))
        
        counter2 += 1
        
        if counter2 == 50:
            counter1 += 1
            counter2 = 0

    return students


def convertDictValsToStr(d):
    # Helper function to assist with the writing of a dictionary to the .csv files
    
    for k in d:
        if not isinstance(d[k], str):
            d[k] = repr(d[k])
    return d

def createClasses(students):
    classes = []

    for student in students:
        for c in student.classes:
            i = isinClasses(c, classes)
            if i is not None:
                classes[i].students.append(student.ID)
            else:
                classes.append(Class(c, [student.ID]))

    return classes

def isinClasses(c, classes):
    # Checks if a given class code is existing in a given classes, if so returns the index
    
    i = 0
    
    for cl in classes:
        if cl.code == c:
            return i
        i += 1

    return None



def writeToCSV(students, classes):
    # Writes the data of students and classes to seperate csv files
    #### To be updated as the classes and students table may end up being seperate
    
    studentWriter = csv.DictWriter(open('studentData.csv', 'w'), fieldnames=["ID", "name", "password", "classes"])
    studentWriter.writeheader()
    
    for student in students:
        studentWriter.writerow(convertDictValsToStr(student.__dict__))

    classWriter = csv.DictWriter(open('classData.csv', 'w'), fieldnames=["code", "students"])
    classWriter.writeheader()

    for c in classes:
        classWriter.writerow(convertDictValsToStr(c.__dict__))

if __name__ == '__main__':

    students = createStudents()
    classes = createClasses(students)
    print(students)
    print(classes)
    writeToCSV(students, classes)
