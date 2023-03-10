import PortalConnection

def pause():
  input("Press Enter to continue...")
  print("")

if __name__ == "__main__":        
    c = PortalConnection.PortalConnection()
    
    # Write your tests here. Add/remove calls to pause() as desired. 

    #List info for a student.
    print("Test 1:")
    print(c.getInfo("2222222222"))
    pause()

    # Unregister a student from an overfull course, i.e. one with more
    # students registered than there are places on the course (you need
    # to set this situation up in the database directly). Check that no
    # student was moved from the queue to being registered as a result.
    print("Test 2:")
    print(c.getInfo("5555555555"))
    print(c.getInfo("3333333333"))
    print(c.unregister("5555555555", "CCC222"))
    print(c.getInfo("5555555555"))
    print(c.getInfo("3333333333"))
    pause()

    #Register a student for an unrestricted course,
    #and check that he/she ends up registered (print info again).
    print("Test 3:")
    print(c.register("6666666666", "CCC555")) #TRUE
    print(c.getInfo("6666666666"))
    pause()
    
    