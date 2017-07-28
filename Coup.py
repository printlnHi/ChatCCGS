T = int(input())
for i in range(T):
  N = int(input())
  grid = [input(),input()]
  acc = 0
  down = 0
  for a,b in zip(grid[0],grid[1]):
    if (a=="*"and b == "*"):
      down = 1
    if (a=="*" or b == "*"):
      acc+=1
  count = down + max(0,acc-1)
  print(count)
