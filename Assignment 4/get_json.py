import json
import psycopg2


def getInfoJSON(student):
    with psycopg2.connect(
            host="localhost",
            user="postgres",
            password="postgres") as conn:
        conn.autocommit = True

        with conn.cursor() as cur:
            basic_info_query = """SELECT basic.idnr AS student, basic.name, basic.login, basic.program, basic.branch
                                  FROM BasicInformation AS basic WHERE basic.idnr = %s;"""
            dictionary = create_subdict(basic_info_query, cur, student)[0]

            finished_query = """SELECT Courses.Name AS course, course AS code, f.credits, grade
                                FROM FinishedCourses AS f
                                LEFT JOIN Courses ON f.course = Courses.code WHERE f.student = %s;"""
            dictionary['finished'] = create_subdict(finished_query, cur, student)
            
            registration_query = """SELECT Courses.Name AS course, r.course AS code, r.status, q.place AS position 
                                    FROM Registrations AS r
                                    Left JOIN CourseQueuePositions AS q ON r.student = q.student AND r.course = q.course
                                    LEFT JOIN Courses ON r.course = Courses.code WHERE r.student = %s; """
            dictionary['registered'] = create_subdict(registration_query, cur, student)
            
            seminar_query = """SELECT seminarcourses
                                FROM PathToGraduation WHERE student = %s;"""
            dictionary['seminarCourses'] = create_subdict(seminar_query, cur, student)[0]['seminarcourses']

            math_query = """SELECT mathcredits
                            FROM PathToGraduation WHERE student = %s;"""
            dictionary['mathCredits'] = create_subdict(math_query, cur, student)[0]['mathcredits']

            researchCredits_query = """SELECT researchcredits
                            FROM PathToGraduation WHERE student = %s;"""
            dictionary['researchCredits'] = create_subdict(researchCredits_query, cur, student)[0]['researchcredits']

            totalcredits_query = """SELECT totalcredits
                            FROM PathToGraduation WHERE student = %s;"""
            dictionary['totalCredits'] = create_subdict(totalcredits_query, cur, student)[0]['totalcredits']

            graduate_query = """SELECT qualified
                            FROM PathToGraduation WHERE student = %s;"""
            dictionary['canGraduate'] = create_subdict(graduate_query, cur, student)[0]['qualified']

            return str(json.dumps(dictionary))

            
def create_subdict(query, cur, arg):
    cur.execute(query, (arg,))
    res = cur.fetchall()
    if len(res) == 0:
        return []
    else:
        desc = cur.description
        column_names = [col[0] for col in desc]
        data = [dict(zip(column_names, row))  
                for row in res]
        return data


basic_info_query = """SELECT basic.idnr AS student, basic.name, basic.login, basic.program, basic.branch
                                  FROM BasicInformation AS basic WHERE basic.idnr = %s;"""
with psycopg2.connect(
            host="localhost",
            user="postgres",
            password="postgres") as conn:
        conn.autocommit = True
        print(create_subdict(basic_info_query, conn.cursor(), "2222222222")[0])



