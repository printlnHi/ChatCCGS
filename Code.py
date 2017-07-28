#Assuming we are using input and print not files
d1 = {1:2,2:3,3:1}
d2 = {2:1,3:2,1:3}
c1  = 0
c2 = 0
for i in range(int(input())):
    a,b = map(int,input().split())
    if d1[a]==b:
        c1+=1
    if d2[a]==b:
        c2+=1

print(max(c1,c2))
