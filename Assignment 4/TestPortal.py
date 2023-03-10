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


    #Register the same student for the same course again,
    #and check that you get an error response.
    print("Test 4:")
    print(c.register("6666666666", "CCC555")) #FALSE
    print(c.getInfo("6666666666"))
    pause()

    #Unregister the student from the course, and then unregister
    # im/her again from the same course. Check that the student
    # s no longer registered and that the second unregistration
    # ives an error response.
    print("Test 5:")
    print(c.unregister("6666666666", "CCC555")) #TRUE
    print(c.getInfo("6666666666"))
    print(c.unregister("6666666666", "CCC555")) #FALSE
    pause()

    #Register the student for a course that he/she does not have
    # the prerequisites for, and check that an error is generated.
    print("Test 6:")
    print(c.register("2222222222", "CCC333")) #FALSE
    print(c.getInfo("2222222222"))
    pause()

    #Unregister a student from a restricted course that he/she is
    # registered to, and which has at least two students in the queue.
    # Register the student again to the same course and check that the
    # student gets the correct (last) position in the waiting list.
    print("Test 7:")
    print(c.getInfo("1111111111"))
    print(c.unregister("1111111111", "CCC222")) # True
    print(c.register("1111111111", "CCC222")) # True
    print(c.getInfo("1111111111"))
    pause()

    #Unregister and re-register the same student for the same restricted
    # course, and check that the student is first removed and then ends up
    # in the same position as before (last).
    print("Test 8:")
    print(c.getInfo("1111111111"))
    print(c.unregister("1111111111", "CCC222")) #TRUE
    print(c.register("1111111111", "CCC222")) #TRUE
    print(c.getInfo("1111111111"))
    pause()


    #Unregister with the SQL injection you introduced, causing all
    # (or almost all?) registrations to disappear.
    print("Test 9:")

    print(c.getInfo("6666666666"))
    print(c.unregister("6666666666","x' OR 'a' = 'a"))
    print(c.getInfo("6666666666"))

