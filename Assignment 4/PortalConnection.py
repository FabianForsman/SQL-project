import psycopg2
import get_json

class PortalConnection:
    def __init__(self):
        self.conn = psycopg2.connect(
            host="localhost",
            user="postgres",
            password="postgres")
        self.conn.autocommit = True

    def getInfo(self, student):
      with self.conn.cursor() as cur:
        return get_json.getInfo(student)

    def register(self, student, courseCode):
        with self.conn.cursor() as cur:
            sql = f"INSERT INTO Registrations VALUES('{student}', '{courseCode}')"
            try:
                cur.execute(sql)
                return '{"success":true}'
            except psycopg2.Error as e:
                message = getError(e)
                return '{"success":false, "error": "'+message+'"}'

    def unregister(self, student, courseCode):
        with self.conn.cursor() as cur:
            sql = "DELETE FROM Registrations WHERE student ='"+student+"' AND course ='"+courseCode+"'"
            if_exists = "SELECT student FROM Registrations WHERE student = '%s' AND course = '%s'" % (student, courseCode)
            cur.execute(if_exists)
            if cur.fetchone():
                try:
                    cur.execute(sql)
                    return '{"success":true}'
                except psycopg2.Error as e:
                    message = getError(e)
                    return '{"success":false, "error": "' + message + '"}'
            else:
                return '{"success":false, "error": "Student is not registered in the course"}'

def getError(e):
    message = repr(e)
    message = message.replace("\\n"," ")
    message = message.replace("\"","\\\"")
    return message

