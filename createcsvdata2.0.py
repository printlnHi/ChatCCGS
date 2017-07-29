'''
    createcsvdata2.0.py
    
    A program to create some test data for the ChatCCGS server.
    This is a basic level of data, with 200 students and 2 classes, each with 100 students.
    No student is in more than one class.
    
    Sections to be updated in later versions are commented.
    
    By N. Patrikeos on 28 Jul 17
    
    '''

from random import randint
import csv

f_in = open('names.txt').readlines()

class Student(object):
    # Base object model for a student
    
    def __init__(self, ID, name, classes):
        self.ID = ID
        self.name = name
        self.classes = classes

class Class(object):
    # Base object model for a class
    
    def __init__(self, code, students):
        self.code = code
        self.students = students

def createStudents():
    # Creates the array of students based off the names in names.txt
    ##### TO BE UPDATED
    
    counter = 0
    c_class = '10ENE1'
    
    students = []
    studentIDs = []
    
    for line in f_in:
        
        if counter > 100:
            c_class = '10EN2'
        
        studentID = None
        while studentID in studentIDs and studentID is None:
            studentID = randint(100, 400)
        
        studentIDs.append(studentID)
        students.append(Student(studentID, line.strip(), [c_class]))
        
        counter += 1
    
    return students


def convertDictValsToStr(d):
    # Helper function to assist with the writing of a dictionary to the .csv files
    
    for k in d:
        if not isinstance(d[k], str):
            d[k] = repr(d[k])
    return d

def createClasses(students):
    # Creates the array of classes
    # TO BE UPDATED
    
    en1Students = []
    en2Students = []
    
    for student in students:
        if student.classes[0] == '10ENE1':
            en1Students.append(student.ID)
        else:
            en2Students.append(student.ID)

return [Class('10ENE1', en1Students), Class('10EN2', en2Students)]


def writeToCSV(students, classes):
    # Writes the data of students and classes to seperate csv files
    #### To be updated as the classes and students table may end up being seperate
    
    studentWriter = csv.DictWriter(open('studentData.csv', 'w'), fieldnames=["ID", "name", "classes"])
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
    writeToCSV(students, classes)
