import os

for file in os.listdir('.'):
  if file.endswith(".py"):
    os.chmod(file, 0o755)   
    print("Changed permissions for", file)