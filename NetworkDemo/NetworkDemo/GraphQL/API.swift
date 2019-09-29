//  This file was automatically generated and should not be edited.

import Apollo

public struct ExamRecordInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(exam: Swift.Optional<GraphQLID?> = nil, answer: Swift.Optional<String?> = nil) {
    graphQLMap = ["exam": exam, "answer": answer]
  }

  public var exam: Swift.Optional<GraphQLID?> {
    get {
      return graphQLMap["exam"] as? Swift.Optional<GraphQLID?> ?? Swift.Optional<GraphQLID?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "exam")
    }
  }

  public var answer: Swift.Optional<String?> {
    get {
      return graphQLMap["answer"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "answer")
    }
  }
}

public struct QuestionRecordInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(question: GraphQLID, part: Swift.Optional<GraphQLID?> = nil, answer: Swift.Optional<String?> = nil, score: Swift.Optional<Int?> = nil, textComment: Swift.Optional<String?> = nil) {
    graphQLMap = ["question": question, "part": part, "answer": answer, "score": score, "text_comment": textComment]
  }

  public var question: GraphQLID {
    get {
      return graphQLMap["question"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "question")
    }
  }

  public var part: Swift.Optional<GraphQLID?> {
    get {
      return graphQLMap["part"] as? Swift.Optional<GraphQLID?> ?? Swift.Optional<GraphQLID?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "part")
    }
  }

  public var answer: Swift.Optional<String?> {
    get {
      return graphQLMap["answer"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "answer")
    }
  }

  public var score: Swift.Optional<Int?> {
    get {
      return graphQLMap["score"] as? Swift.Optional<Int?> ?? Swift.Optional<Int?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "score")
    }
  }

  public var textComment: Swift.Optional<String?> {
    get {
      return graphQLMap["text_comment"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "text_comment")
    }
  }
}

public final class UserLoginQuery: GraphQLQuery {
  /// query userLogin($email: String!, $passWord: String!, $userType: Int!) {
  ///   userLogin(email: $email, password: $passWord, userType: $userType) {
  ///     __typename
  ///     token
  ///     userId
  ///     userType
  ///     userName
  ///   }
  /// }
  public let operationDefinition =
    "query userLogin($email: String!, $passWord: String!, $userType: Int!) { userLogin(email: $email, password: $passWord, userType: $userType) { __typename token userId userType userName } }"

  public let operationName = "userLogin"

  public var email: String
  public var passWord: String
  public var userType: Int

  public init(email: String, passWord: String, userType: Int) {
    self.email = email
    self.passWord = passWord
    self.userType = userType
  }

  public var variables: GraphQLMap? {
    return ["email": email, "passWord": passWord, "userType": userType]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("userLogin", arguments: ["email": GraphQLVariable("email"), "password": GraphQLVariable("passWord"), "userType": GraphQLVariable("userType")], type: .nonNull(.object(UserLogin.selections))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(userLogin: UserLogin) {
      self.init(unsafeResultMap: ["__typename": "Query", "userLogin": userLogin.resultMap])
    }

    public var userLogin: UserLogin {
      get {
        return UserLogin(unsafeResultMap: resultMap["userLogin"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "userLogin")
      }
    }

    public struct UserLogin: GraphQLSelectionSet {
      public static let possibleTypes = ["UserAuthData"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("token", type: .scalar(String.self)),
        GraphQLField("userId", type: .scalar(String.self)),
        GraphQLField("userType", type: .scalar(Int.self)),
        GraphQLField("userName", type: .scalar(String.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(token: String? = nil, userId: String? = nil, userType: Int? = nil, userName: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "UserAuthData", "token": token, "userId": userId, "userType": userType, "userName": userName])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var token: String? {
        get {
          return resultMap["token"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "token")
        }
      }

      public var userId: String? {
        get {
          return resultMap["userId"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "userId")
        }
      }

      public var userType: Int? {
        get {
          return resultMap["userType"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "userType")
        }
      }

      public var userName: String? {
        get {
          return resultMap["userName"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "userName")
        }
      }
    }
  }
}

public final class GetClassroomsQuery: GraphQLQuery {
  /// query getClassrooms($userid: ID!) {
  ///   student(id: $userid) {
  ///     __typename
  ///     _id
  ///     name
  ///     classrooms {
  ///       __typename
  ///       _id
  ///       name
  ///     }
  ///   }
  /// }
  public let operationDefinition =
    "query getClassrooms($userid: ID!) { student(id: $userid) { __typename _id name classrooms { __typename _id name } } }"

  public let operationName = "getClassrooms"

  public var userid: GraphQLID

  public init(userid: GraphQLID) {
    self.userid = userid
  }

  public var variables: GraphQLMap? {
    return ["userid": userid]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("student", arguments: ["id": GraphQLVariable("userid")], type: .object(Student.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(student: Student? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "student": student.flatMap { (value: Student) -> ResultMap in value.resultMap }])
    }

    public var student: Student? {
      get {
        return (resultMap["student"] as? ResultMap).flatMap { Student(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "student")
      }
    }

    public struct Student: GraphQLSelectionSet {
      public static let possibleTypes = ["Student"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("_id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("classrooms", type: .list(.object(Classroom.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID, name: String, classrooms: [Classroom?]? = nil) {
        self.init(unsafeResultMap: ["__typename": "Student", "_id": id, "name": name, "classrooms": classrooms.flatMap { (value: [Classroom?]) -> [ResultMap?] in value.map { (value: Classroom?) -> ResultMap? in value.flatMap { (value: Classroom) -> ResultMap in value.resultMap } } }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return resultMap["_id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "_id")
        }
      }

      public var name: String {
        get {
          return resultMap["name"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "name")
        }
      }

      public var classrooms: [Classroom?]? {
        get {
          return (resultMap["classrooms"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Classroom?] in value.map { (value: ResultMap?) -> Classroom? in value.flatMap { (value: ResultMap) -> Classroom in Classroom(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Classroom?]) -> [ResultMap?] in value.map { (value: Classroom?) -> ResultMap? in value.flatMap { (value: Classroom) -> ResultMap in value.resultMap } } }, forKey: "classrooms")
        }
      }

      public struct Classroom: GraphQLSelectionSet {
        public static let possibleTypes = ["Classroom"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("_id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: GraphQLID, name: String) {
          self.init(unsafeResultMap: ["__typename": "Classroom", "_id": id, "name": name])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return resultMap["_id"]! as! GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "_id")
          }
        }

        public var name: String {
          get {
            return resultMap["name"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "name")
          }
        }
      }
    }
  }
}

public final class GetStudentClassroomsQuery: GraphQLQuery {
  /// query getStudentClassrooms {
  ///   studentClassrooms {
  ///     __typename
  ///     courseGroups
  ///     classrooms {
  ///       __typename
  ///       _id
  ///       name
  ///       start_time
  ///       progress
  ///       status
  ///       schedules {
  ///         __typename
  ///         _id
  ///       }
  ///       course_version {
  ///         __typename
  ///         course {
  ///           __typename
  ///           course_group {
  ///             __typename
  ///             name
  ///           }
  ///           image {
  ///             __typename
  ///             url
  ///           }
  ///         }
  ///       }
  ///     }
  ///   }
  /// }
  public let operationDefinition =
    "query getStudentClassrooms { studentClassrooms { __typename courseGroups classrooms { __typename _id name start_time progress status schedules { __typename _id } course_version { __typename course { __typename course_group { __typename name } image { __typename url } } } } } }"

  public let operationName = "getStudentClassrooms"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("studentClassrooms", type: .object(StudentClassroom.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(studentClassrooms: StudentClassroom? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "studentClassrooms": studentClassrooms.flatMap { (value: StudentClassroom) -> ResultMap in value.resultMap }])
    }

    public var studentClassrooms: StudentClassroom? {
      get {
        return (resultMap["studentClassrooms"] as? ResultMap).flatMap { StudentClassroom(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "studentClassrooms")
      }
    }

    public struct StudentClassroom: GraphQLSelectionSet {
      public static let possibleTypes = ["StudentClassrooms"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("courseGroups", type: .list(.scalar(String.self))),
        GraphQLField("classrooms", type: .list(.object(Classroom.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(courseGroups: [String?]? = nil, classrooms: [Classroom?]? = nil) {
        self.init(unsafeResultMap: ["__typename": "StudentClassrooms", "courseGroups": courseGroups, "classrooms": classrooms.flatMap { (value: [Classroom?]) -> [ResultMap?] in value.map { (value: Classroom?) -> ResultMap? in value.flatMap { (value: Classroom) -> ResultMap in value.resultMap } } }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var courseGroups: [String?]? {
        get {
          return resultMap["courseGroups"] as? [String?]
        }
        set {
          resultMap.updateValue(newValue, forKey: "courseGroups")
        }
      }

      public var classrooms: [Classroom?]? {
        get {
          return (resultMap["classrooms"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Classroom?] in value.map { (value: ResultMap?) -> Classroom? in value.flatMap { (value: ResultMap) -> Classroom in Classroom(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Classroom?]) -> [ResultMap?] in value.map { (value: Classroom?) -> ResultMap? in value.flatMap { (value: Classroom) -> ResultMap in value.resultMap } } }, forKey: "classrooms")
        }
      }

      public struct Classroom: GraphQLSelectionSet {
        public static let possibleTypes = ["Classroom"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("_id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("start_time", type: .nonNull(.scalar(String.self))),
          GraphQLField("progress", type: .nonNull(.scalar(Int.self))),
          GraphQLField("status", type: .nonNull(.scalar(Int.self))),
          GraphQLField("schedules", type: .nonNull(.list(.object(Schedule.selections)))),
          GraphQLField("course_version", type: .object(CourseVersion.selections)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: GraphQLID, name: String, startTime: String, progress: Int, status: Int, schedules: [Schedule?], courseVersion: CourseVersion? = nil) {
          self.init(unsafeResultMap: ["__typename": "Classroom", "_id": id, "name": name, "start_time": startTime, "progress": progress, "status": status, "schedules": schedules.map { (value: Schedule?) -> ResultMap? in value.flatMap { (value: Schedule) -> ResultMap in value.resultMap } }, "course_version": courseVersion.flatMap { (value: CourseVersion) -> ResultMap in value.resultMap }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return resultMap["_id"]! as! GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "_id")
          }
        }

        public var name: String {
          get {
            return resultMap["name"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "name")
          }
        }

        public var startTime: String {
          get {
            return resultMap["start_time"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "start_time")
          }
        }

        public var progress: Int {
          get {
            return resultMap["progress"]! as! Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "progress")
          }
        }

        public var status: Int {
          get {
            return resultMap["status"]! as! Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "status")
          }
        }

        public var schedules: [Schedule?] {
          get {
            return (resultMap["schedules"] as! [ResultMap?]).map { (value: ResultMap?) -> Schedule? in value.flatMap { (value: ResultMap) -> Schedule in Schedule(unsafeResultMap: value) } }
          }
          set {
            resultMap.updateValue(newValue.map { (value: Schedule?) -> ResultMap? in value.flatMap { (value: Schedule) -> ResultMap in value.resultMap } }, forKey: "schedules")
          }
        }

        public var courseVersion: CourseVersion? {
          get {
            return (resultMap["course_version"] as? ResultMap).flatMap { CourseVersion(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "course_version")
          }
        }

        public struct Schedule: GraphQLSelectionSet {
          public static let possibleTypes = ["Schedule"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("_id", type: .nonNull(.scalar(GraphQLID.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(id: GraphQLID) {
            self.init(unsafeResultMap: ["__typename": "Schedule", "_id": id])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var id: GraphQLID {
            get {
              return resultMap["_id"]! as! GraphQLID
            }
            set {
              resultMap.updateValue(newValue, forKey: "_id")
            }
          }
        }

        public struct CourseVersion: GraphQLSelectionSet {
          public static let possibleTypes = ["CourseVersion"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("course", type: .object(Course.selections)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(course: Course? = nil) {
            self.init(unsafeResultMap: ["__typename": "CourseVersion", "course": course.flatMap { (value: Course) -> ResultMap in value.resultMap }])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var course: Course? {
            get {
              return (resultMap["course"] as? ResultMap).flatMap { Course(unsafeResultMap: $0) }
            }
            set {
              resultMap.updateValue(newValue?.resultMap, forKey: "course")
            }
          }

          public struct Course: GraphQLSelectionSet {
            public static let possibleTypes = ["Course"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("course_group", type: .object(CourseGroup.selections)),
              GraphQLField("image", type: .object(Image.selections)),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(courseGroup: CourseGroup? = nil, image: Image? = nil) {
              self.init(unsafeResultMap: ["__typename": "Course", "course_group": courseGroup.flatMap { (value: CourseGroup) -> ResultMap in value.resultMap }, "image": image.flatMap { (value: Image) -> ResultMap in value.resultMap }])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var courseGroup: CourseGroup? {
              get {
                return (resultMap["course_group"] as? ResultMap).flatMap { CourseGroup(unsafeResultMap: $0) }
              }
              set {
                resultMap.updateValue(newValue?.resultMap, forKey: "course_group")
              }
            }

            public var image: Image? {
              get {
                return (resultMap["image"] as? ResultMap).flatMap { Image(unsafeResultMap: $0) }
              }
              set {
                resultMap.updateValue(newValue?.resultMap, forKey: "image")
              }
            }

            public struct CourseGroup: GraphQLSelectionSet {
              public static let possibleTypes = ["CourseGroup"]

              public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("name", type: .nonNull(.scalar(String.self))),
              ]

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(name: String) {
                self.init(unsafeResultMap: ["__typename": "CourseGroup", "name": name])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var name: String {
                get {
                  return resultMap["name"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "name")
                }
              }
            }

            public struct Image: GraphQLSelectionSet {
              public static let possibleTypes = ["Media"]

              public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("url", type: .scalar(String.self)),
              ]

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(url: String? = nil) {
                self.init(unsafeResultMap: ["__typename": "Media", "url": url])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var url: String? {
                get {
                  return resultMap["url"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "url")
                }
              }
            }
          }
        }
      }
    }
  }
}

public final class GetStudentClassroomQuery: GraphQLQuery {
  /// query getStudentClassroom($classroomId: ID!) {
  ///   studentClassroom(classroomId: $classroomId) {
  ///     __typename
  ///     _id
  ///     name
  ///     progress
  ///     message
  ///     status
  ///     start_time
  ///     nextSchedule {
  ///       __typename
  ///       _id
  ///       start_time
  ///       status
  ///     }
  ///     teacher {
  ///       __typename
  ///       name
  ///     }
  ///     schedules {
  ///       __typename
  ///       _id
  ///       start_time
  ///       status
  ///       lesson {
  ///         __typename
  ///         _id
  ///         intro
  ///         points
  ///         contents
  ///       }
  ///     }
  ///     course_version {
  ///       __typename
  ///       course {
  ///         __typename
  ///         image {
  ///           __typename
  ///           url
  ///         }
  ///       }
  ///     }
  ///   }
  /// }
  public let operationDefinition =
    "query getStudentClassroom($classroomId: ID!) { studentClassroom(classroomId: $classroomId) { __typename _id name progress message status start_time nextSchedule { __typename _id start_time status } teacher { __typename name } schedules { __typename _id start_time status lesson { __typename _id intro points contents } } course_version { __typename course { __typename image { __typename url } } } } }"

  public let operationName = "getStudentClassroom"

  public var classroomId: GraphQLID

  public init(classroomId: GraphQLID) {
    self.classroomId = classroomId
  }

  public var variables: GraphQLMap? {
    return ["classroomId": classroomId]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("studentClassroom", arguments: ["classroomId": GraphQLVariable("classroomId")], type: .object(StudentClassroom.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(studentClassroom: StudentClassroom? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "studentClassroom": studentClassroom.flatMap { (value: StudentClassroom) -> ResultMap in value.resultMap }])
    }

    public var studentClassroom: StudentClassroom? {
      get {
        return (resultMap["studentClassroom"] as? ResultMap).flatMap { StudentClassroom(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "studentClassroom")
      }
    }

    public struct StudentClassroom: GraphQLSelectionSet {
      public static let possibleTypes = ["Classroom"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("_id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("progress", type: .nonNull(.scalar(Int.self))),
        GraphQLField("message", type: .scalar(String.self)),
        GraphQLField("status", type: .nonNull(.scalar(Int.self))),
        GraphQLField("start_time", type: .nonNull(.scalar(String.self))),
        GraphQLField("nextSchedule", type: .object(NextSchedule.selections)),
        GraphQLField("teacher", type: .nonNull(.object(Teacher.selections))),
        GraphQLField("schedules", type: .nonNull(.list(.object(Schedule.selections)))),
        GraphQLField("course_version", type: .object(CourseVersion.selections)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID, name: String, progress: Int, message: String? = nil, status: Int, startTime: String, nextSchedule: NextSchedule? = nil, teacher: Teacher, schedules: [Schedule?], courseVersion: CourseVersion? = nil) {
        self.init(unsafeResultMap: ["__typename": "Classroom", "_id": id, "name": name, "progress": progress, "message": message, "status": status, "start_time": startTime, "nextSchedule": nextSchedule.flatMap { (value: NextSchedule) -> ResultMap in value.resultMap }, "teacher": teacher.resultMap, "schedules": schedules.map { (value: Schedule?) -> ResultMap? in value.flatMap { (value: Schedule) -> ResultMap in value.resultMap } }, "course_version": courseVersion.flatMap { (value: CourseVersion) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return resultMap["_id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "_id")
        }
      }

      public var name: String {
        get {
          return resultMap["name"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "name")
        }
      }

      public var progress: Int {
        get {
          return resultMap["progress"]! as! Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "progress")
        }
      }

      public var message: String? {
        get {
          return resultMap["message"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "message")
        }
      }

      public var status: Int {
        get {
          return resultMap["status"]! as! Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "status")
        }
      }

      public var startTime: String {
        get {
          return resultMap["start_time"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "start_time")
        }
      }

      public var nextSchedule: NextSchedule? {
        get {
          return (resultMap["nextSchedule"] as? ResultMap).flatMap { NextSchedule(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "nextSchedule")
        }
      }

      public var teacher: Teacher {
        get {
          return Teacher(unsafeResultMap: resultMap["teacher"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "teacher")
        }
      }

      public var schedules: [Schedule?] {
        get {
          return (resultMap["schedules"] as! [ResultMap?]).map { (value: ResultMap?) -> Schedule? in value.flatMap { (value: ResultMap) -> Schedule in Schedule(unsafeResultMap: value) } }
        }
        set {
          resultMap.updateValue(newValue.map { (value: Schedule?) -> ResultMap? in value.flatMap { (value: Schedule) -> ResultMap in value.resultMap } }, forKey: "schedules")
        }
      }

      public var courseVersion: CourseVersion? {
        get {
          return (resultMap["course_version"] as? ResultMap).flatMap { CourseVersion(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "course_version")
        }
      }

      public struct NextSchedule: GraphQLSelectionSet {
        public static let possibleTypes = ["Schedule"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("_id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("start_time", type: .scalar(String.self)),
          GraphQLField("status", type: .scalar(Int.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: GraphQLID, startTime: String? = nil, status: Int? = nil) {
          self.init(unsafeResultMap: ["__typename": "Schedule", "_id": id, "start_time": startTime, "status": status])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return resultMap["_id"]! as! GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "_id")
          }
        }

        public var startTime: String? {
          get {
            return resultMap["start_time"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "start_time")
          }
        }

        public var status: Int? {
          get {
            return resultMap["status"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "status")
          }
        }
      }

      public struct Teacher: GraphQLSelectionSet {
        public static let possibleTypes = ["Teacher"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(name: String) {
          self.init(unsafeResultMap: ["__typename": "Teacher", "name": name])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var name: String {
          get {
            return resultMap["name"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "name")
          }
        }
      }

      public struct Schedule: GraphQLSelectionSet {
        public static let possibleTypes = ["Schedule"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("_id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("start_time", type: .scalar(String.self)),
          GraphQLField("status", type: .scalar(Int.self)),
          GraphQLField("lesson", type: .object(Lesson.selections)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: GraphQLID, startTime: String? = nil, status: Int? = nil, lesson: Lesson? = nil) {
          self.init(unsafeResultMap: ["__typename": "Schedule", "_id": id, "start_time": startTime, "status": status, "lesson": lesson.flatMap { (value: Lesson) -> ResultMap in value.resultMap }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return resultMap["_id"]! as! GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "_id")
          }
        }

        public var startTime: String? {
          get {
            return resultMap["start_time"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "start_time")
          }
        }

        public var status: Int? {
          get {
            return resultMap["status"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "status")
          }
        }

        public var lesson: Lesson? {
          get {
            return (resultMap["lesson"] as? ResultMap).flatMap { Lesson(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "lesson")
          }
        }

        public struct Lesson: GraphQLSelectionSet {
          public static let possibleTypes = ["Lesson"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("_id", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("intro", type: .scalar(String.self)),
            GraphQLField("points", type: .scalar(String.self)),
            GraphQLField("contents", type: .scalar(String.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(id: GraphQLID, intro: String? = nil, points: String? = nil, contents: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "Lesson", "_id": id, "intro": intro, "points": points, "contents": contents])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var id: GraphQLID {
            get {
              return resultMap["_id"]! as! GraphQLID
            }
            set {
              resultMap.updateValue(newValue, forKey: "_id")
            }
          }

          public var intro: String? {
            get {
              return resultMap["intro"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "intro")
            }
          }

          public var points: String? {
            get {
              return resultMap["points"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "points")
            }
          }

          public var contents: String? {
            get {
              return resultMap["contents"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "contents")
            }
          }
        }
      }

      public struct CourseVersion: GraphQLSelectionSet {
        public static let possibleTypes = ["CourseVersion"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("course", type: .object(Course.selections)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(course: Course? = nil) {
          self.init(unsafeResultMap: ["__typename": "CourseVersion", "course": course.flatMap { (value: Course) -> ResultMap in value.resultMap }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var course: Course? {
          get {
            return (resultMap["course"] as? ResultMap).flatMap { Course(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "course")
          }
        }

        public struct Course: GraphQLSelectionSet {
          public static let possibleTypes = ["Course"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("image", type: .object(Image.selections)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(image: Image? = nil) {
            self.init(unsafeResultMap: ["__typename": "Course", "image": image.flatMap { (value: Image) -> ResultMap in value.resultMap }])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var image: Image? {
            get {
              return (resultMap["image"] as? ResultMap).flatMap { Image(unsafeResultMap: $0) }
            }
            set {
              resultMap.updateValue(newValue?.resultMap, forKey: "image")
            }
          }

          public struct Image: GraphQLSelectionSet {
            public static let possibleTypes = ["Media"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("url", type: .scalar(String.self)),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(url: String? = nil) {
              self.init(unsafeResultMap: ["__typename": "Media", "url": url])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var url: String? {
              get {
                return resultMap["url"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "url")
              }
            }
          }
        }
      }
    }
  }
}

public final class GetStudentSchedulesQuery: GraphQLQuery {
  /// query getStudentSchedules($classroomId: ID!) {
  ///   studentSchedules(classroomId: $classroomId) {
  ///     __typename
  ///     _id
  ///     status {
  ///       __typename
  ///       round
  ///       online
  ///       homework
  ///     }
  ///     schedule {
  ///       __typename
  ///       _id
  ///       status
  ///       status_homework
  ///     }
  ///   }
  /// }
  public let operationDefinition =
    "query getStudentSchedules($classroomId: ID!) { studentSchedules(classroomId: $classroomId) { __typename _id status { __typename round online homework } schedule { __typename _id status status_homework } } }"

  public let operationName = "getStudentSchedules"

  public var classroomId: GraphQLID

  public init(classroomId: GraphQLID) {
    self.classroomId = classroomId
  }

  public var variables: GraphQLMap? {
    return ["classroomId": classroomId]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("studentSchedules", arguments: ["classroomId": GraphQLVariable("classroomId")], type: .list(.object(StudentSchedule.selections))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(studentSchedules: [StudentSchedule?]? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "studentSchedules": studentSchedules.flatMap { (value: [StudentSchedule?]) -> [ResultMap?] in value.map { (value: StudentSchedule?) -> ResultMap? in value.flatMap { (value: StudentSchedule) -> ResultMap in value.resultMap } } }])
    }

    public var studentSchedules: [StudentSchedule?]? {
      get {
        return (resultMap["studentSchedules"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [StudentSchedule?] in value.map { (value: ResultMap?) -> StudentSchedule? in value.flatMap { (value: ResultMap) -> StudentSchedule in StudentSchedule(unsafeResultMap: value) } } }
      }
      set {
        resultMap.updateValue(newValue.flatMap { (value: [StudentSchedule?]) -> [ResultMap?] in value.map { (value: StudentSchedule?) -> ResultMap? in value.flatMap { (value: StudentSchedule) -> ResultMap in value.resultMap } } }, forKey: "studentSchedules")
      }
    }

    public struct StudentSchedule: GraphQLSelectionSet {
      public static let possibleTypes = ["StudentSchedule"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("_id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("status", type: .object(Status.selections)),
        GraphQLField("schedule", type: .object(Schedule.selections)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID, status: Status? = nil, schedule: Schedule? = nil) {
        self.init(unsafeResultMap: ["__typename": "StudentSchedule", "_id": id, "status": status.flatMap { (value: Status) -> ResultMap in value.resultMap }, "schedule": schedule.flatMap { (value: Schedule) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return resultMap["_id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "_id")
        }
      }

      public var status: Status? {
        get {
          return (resultMap["status"] as? ResultMap).flatMap { Status(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "status")
        }
      }

      public var schedule: Schedule? {
        get {
          return (resultMap["schedule"] as? ResultMap).flatMap { Schedule(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "schedule")
        }
      }

      public struct Status: GraphQLSelectionSet {
        public static let possibleTypes = ["ScheduleStatus"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("round", type: .scalar(Int.self)),
          GraphQLField("online", type: .scalar(Int.self)),
          GraphQLField("homework", type: .scalar(Int.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(round: Int? = nil, online: Int? = nil, homework: Int? = nil) {
          self.init(unsafeResultMap: ["__typename": "ScheduleStatus", "round": round, "online": online, "homework": homework])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var round: Int? {
          get {
            return resultMap["round"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "round")
          }
        }

        public var online: Int? {
          get {
            return resultMap["online"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "online")
          }
        }

        public var homework: Int? {
          get {
            return resultMap["homework"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "homework")
          }
        }
      }

      public struct Schedule: GraphQLSelectionSet {
        public static let possibleTypes = ["Schedule"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("_id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("status", type: .scalar(Int.self)),
          GraphQLField("status_homework", type: .scalar(Int.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: GraphQLID, status: Int? = nil, statusHomework: Int? = nil) {
          self.init(unsafeResultMap: ["__typename": "Schedule", "_id": id, "status": status, "status_homework": statusHomework])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return resultMap["_id"]! as! GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "_id")
          }
        }

        public var status: Int? {
          get {
            return resultMap["status"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "status")
          }
        }

        public var statusHomework: Int? {
          get {
            return resultMap["status_homework"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "status_homework")
          }
        }
      }
    }
  }
}

public final class GetStudentScheduleQuery: GraphQLQuery {
  /// query getStudentSchedule($studentScheduleId: ID!) {
  ///   studentSchedule(studentScheduleId: $studentScheduleId) {
  ///     __typename
  ///     _id
  ///     scheduleNo
  ///     classroom {
  ///       __typename
  ///       teacher {
  ///         __typename
  ///         name
  ///       }
  ///     }
  ///     schedule {
  ///       __typename
  ///       _id
  ///       record_video {
  ///         __typename
  ///         filename
  ///         url
  ///       }
  ///       lesson {
  ///         __typename
  ///         intro
  ///         contents
  ///         points
  ///         online {
  ///           __typename
  ///           _id
  ///           ppt {
  ///             __typename
  ///             filename
  ///             url
  ///             taskUUID
  ///             totalPageSize
  ///           }
  ///           pdfs {
  ///             __typename
  ///             filename
  ///             url
  ///           }
  ///           audios {
  ///             __typename
  ///             filename
  ///             url
  ///           }
  ///           videos {
  ///             __typename
  ///             filename
  ///             url
  ///           }
  ///           exams {
  ///             __typename
  ///             _id
  ///             category
  ///             title
  ///             q_score
  ///             answer
  ///             note
  ///             options
  ///           }
  ///         }
  ///       }
  ///     }
  ///   }
  /// }
  public let operationDefinition =
    "query getStudentSchedule($studentScheduleId: ID!) { studentSchedule(studentScheduleId: $studentScheduleId) { __typename _id scheduleNo classroom { __typename teacher { __typename name } } schedule { __typename _id record_video { __typename filename url } lesson { __typename intro contents points online { __typename _id ppt { __typename filename url taskUUID totalPageSize } pdfs { __typename filename url } audios { __typename filename url } videos { __typename filename url } exams { __typename _id category title q_score answer note options } } } } } }"

  public let operationName = "getStudentSchedule"

  public var studentScheduleId: GraphQLID

  public init(studentScheduleId: GraphQLID) {
    self.studentScheduleId = studentScheduleId
  }

  public var variables: GraphQLMap? {
    return ["studentScheduleId": studentScheduleId]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("studentSchedule", arguments: ["studentScheduleId": GraphQLVariable("studentScheduleId")], type: .object(StudentSchedule.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(studentSchedule: StudentSchedule? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "studentSchedule": studentSchedule.flatMap { (value: StudentSchedule) -> ResultMap in value.resultMap }])
    }

    public var studentSchedule: StudentSchedule? {
      get {
        return (resultMap["studentSchedule"] as? ResultMap).flatMap { StudentSchedule(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "studentSchedule")
      }
    }

    public struct StudentSchedule: GraphQLSelectionSet {
      public static let possibleTypes = ["StudentSchedule"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("_id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("scheduleNo", type: .scalar(Int.self)),
        GraphQLField("classroom", type: .object(Classroom.selections)),
        GraphQLField("schedule", type: .object(Schedule.selections)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID, scheduleNo: Int? = nil, classroom: Classroom? = nil, schedule: Schedule? = nil) {
        self.init(unsafeResultMap: ["__typename": "StudentSchedule", "_id": id, "scheduleNo": scheduleNo, "classroom": classroom.flatMap { (value: Classroom) -> ResultMap in value.resultMap }, "schedule": schedule.flatMap { (value: Schedule) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return resultMap["_id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "_id")
        }
      }

      public var scheduleNo: Int? {
        get {
          return resultMap["scheduleNo"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "scheduleNo")
        }
      }

      public var classroom: Classroom? {
        get {
          return (resultMap["classroom"] as? ResultMap).flatMap { Classroom(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "classroom")
        }
      }

      public var schedule: Schedule? {
        get {
          return (resultMap["schedule"] as? ResultMap).flatMap { Schedule(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "schedule")
        }
      }

      public struct Classroom: GraphQLSelectionSet {
        public static let possibleTypes = ["Classroom"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("teacher", type: .nonNull(.object(Teacher.selections))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(teacher: Teacher) {
          self.init(unsafeResultMap: ["__typename": "Classroom", "teacher": teacher.resultMap])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var teacher: Teacher {
          get {
            return Teacher(unsafeResultMap: resultMap["teacher"]! as! ResultMap)
          }
          set {
            resultMap.updateValue(newValue.resultMap, forKey: "teacher")
          }
        }

        public struct Teacher: GraphQLSelectionSet {
          public static let possibleTypes = ["Teacher"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("name", type: .nonNull(.scalar(String.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(name: String) {
            self.init(unsafeResultMap: ["__typename": "Teacher", "name": name])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var name: String {
            get {
              return resultMap["name"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "name")
            }
          }
        }
      }

      public struct Schedule: GraphQLSelectionSet {
        public static let possibleTypes = ["Schedule"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("_id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("record_video", type: .object(RecordVideo.selections)),
          GraphQLField("lesson", type: .object(Lesson.selections)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: GraphQLID, recordVideo: RecordVideo? = nil, lesson: Lesson? = nil) {
          self.init(unsafeResultMap: ["__typename": "Schedule", "_id": id, "record_video": recordVideo.flatMap { (value: RecordVideo) -> ResultMap in value.resultMap }, "lesson": lesson.flatMap { (value: Lesson) -> ResultMap in value.resultMap }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return resultMap["_id"]! as! GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "_id")
          }
        }

        public var recordVideo: RecordVideo? {
          get {
            return (resultMap["record_video"] as? ResultMap).flatMap { RecordVideo(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "record_video")
          }
        }

        public var lesson: Lesson? {
          get {
            return (resultMap["lesson"] as? ResultMap).flatMap { Lesson(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "lesson")
          }
        }

        public struct RecordVideo: GraphQLSelectionSet {
          public static let possibleTypes = ["Media"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("filename", type: .scalar(String.self)),
            GraphQLField("url", type: .scalar(String.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(filename: String? = nil, url: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "Media", "filename": filename, "url": url])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var filename: String? {
            get {
              return resultMap["filename"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "filename")
            }
          }

          public var url: String? {
            get {
              return resultMap["url"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "url")
            }
          }
        }

        public struct Lesson: GraphQLSelectionSet {
          public static let possibleTypes = ["Lesson"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("intro", type: .scalar(String.self)),
            GraphQLField("contents", type: .scalar(String.self)),
            GraphQLField("points", type: .scalar(String.self)),
            GraphQLField("online", type: .object(Online.selections)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(intro: String? = nil, contents: String? = nil, points: String? = nil, online: Online? = nil) {
            self.init(unsafeResultMap: ["__typename": "Lesson", "intro": intro, "contents": contents, "points": points, "online": online.flatMap { (value: Online) -> ResultMap in value.resultMap }])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var intro: String? {
            get {
              return resultMap["intro"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "intro")
            }
          }

          public var contents: String? {
            get {
              return resultMap["contents"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "contents")
            }
          }

          public var points: String? {
            get {
              return resultMap["points"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "points")
            }
          }

          public var online: Online? {
            get {
              return (resultMap["online"] as? ResultMap).flatMap { Online(unsafeResultMap: $0) }
            }
            set {
              resultMap.updateValue(newValue?.resultMap, forKey: "online")
            }
          }

          public struct Online: GraphQLSelectionSet {
            public static let possibleTypes = ["Online"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("_id", type: .nonNull(.scalar(GraphQLID.self))),
              GraphQLField("ppt", type: .object(Ppt.selections)),
              GraphQLField("pdfs", type: .list(.object(Pdf.selections))),
              GraphQLField("audios", type: .list(.object(Audio.selections))),
              GraphQLField("videos", type: .list(.object(Video.selections))),
              GraphQLField("exams", type: .list(.object(Exam.selections))),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(id: GraphQLID, ppt: Ppt? = nil, pdfs: [Pdf?]? = nil, audios: [Audio?]? = nil, videos: [Video?]? = nil, exams: [Exam?]? = nil) {
              self.init(unsafeResultMap: ["__typename": "Online", "_id": id, "ppt": ppt.flatMap { (value: Ppt) -> ResultMap in value.resultMap }, "pdfs": pdfs.flatMap { (value: [Pdf?]) -> [ResultMap?] in value.map { (value: Pdf?) -> ResultMap? in value.flatMap { (value: Pdf) -> ResultMap in value.resultMap } } }, "audios": audios.flatMap { (value: [Audio?]) -> [ResultMap?] in value.map { (value: Audio?) -> ResultMap? in value.flatMap { (value: Audio) -> ResultMap in value.resultMap } } }, "videos": videos.flatMap { (value: [Video?]) -> [ResultMap?] in value.map { (value: Video?) -> ResultMap? in value.flatMap { (value: Video) -> ResultMap in value.resultMap } } }, "exams": exams.flatMap { (value: [Exam?]) -> [ResultMap?] in value.map { (value: Exam?) -> ResultMap? in value.flatMap { (value: Exam) -> ResultMap in value.resultMap } } }])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var id: GraphQLID {
              get {
                return resultMap["_id"]! as! GraphQLID
              }
              set {
                resultMap.updateValue(newValue, forKey: "_id")
              }
            }

            public var ppt: Ppt? {
              get {
                return (resultMap["ppt"] as? ResultMap).flatMap { Ppt(unsafeResultMap: $0) }
              }
              set {
                resultMap.updateValue(newValue?.resultMap, forKey: "ppt")
              }
            }

            public var pdfs: [Pdf?]? {
              get {
                return (resultMap["pdfs"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Pdf?] in value.map { (value: ResultMap?) -> Pdf? in value.flatMap { (value: ResultMap) -> Pdf in Pdf(unsafeResultMap: value) } } }
              }
              set {
                resultMap.updateValue(newValue.flatMap { (value: [Pdf?]) -> [ResultMap?] in value.map { (value: Pdf?) -> ResultMap? in value.flatMap { (value: Pdf) -> ResultMap in value.resultMap } } }, forKey: "pdfs")
              }
            }

            public var audios: [Audio?]? {
              get {
                return (resultMap["audios"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Audio?] in value.map { (value: ResultMap?) -> Audio? in value.flatMap { (value: ResultMap) -> Audio in Audio(unsafeResultMap: value) } } }
              }
              set {
                resultMap.updateValue(newValue.flatMap { (value: [Audio?]) -> [ResultMap?] in value.map { (value: Audio?) -> ResultMap? in value.flatMap { (value: Audio) -> ResultMap in value.resultMap } } }, forKey: "audios")
              }
            }

            public var videos: [Video?]? {
              get {
                return (resultMap["videos"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Video?] in value.map { (value: ResultMap?) -> Video? in value.flatMap { (value: ResultMap) -> Video in Video(unsafeResultMap: value) } } }
              }
              set {
                resultMap.updateValue(newValue.flatMap { (value: [Video?]) -> [ResultMap?] in value.map { (value: Video?) -> ResultMap? in value.flatMap { (value: Video) -> ResultMap in value.resultMap } } }, forKey: "videos")
              }
            }

            public var exams: [Exam?]? {
              get {
                return (resultMap["exams"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Exam?] in value.map { (value: ResultMap?) -> Exam? in value.flatMap { (value: ResultMap) -> Exam in Exam(unsafeResultMap: value) } } }
              }
              set {
                resultMap.updateValue(newValue.flatMap { (value: [Exam?]) -> [ResultMap?] in value.map { (value: Exam?) -> ResultMap? in value.flatMap { (value: Exam) -> ResultMap in value.resultMap } } }, forKey: "exams")
              }
            }

            public struct Ppt: GraphQLSelectionSet {
              public static let possibleTypes = ["Ppt"]

              public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("filename", type: .scalar(String.self)),
                GraphQLField("url", type: .scalar(String.self)),
                GraphQLField("taskUUID", type: .scalar(String.self)),
                GraphQLField("totalPageSize", type: .scalar(Int.self)),
              ]

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(filename: String? = nil, url: String? = nil, taskUuid: String? = nil, totalPageSize: Int? = nil) {
                self.init(unsafeResultMap: ["__typename": "Ppt", "filename": filename, "url": url, "taskUUID": taskUuid, "totalPageSize": totalPageSize])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var filename: String? {
                get {
                  return resultMap["filename"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "filename")
                }
              }

              public var url: String? {
                get {
                  return resultMap["url"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "url")
                }
              }

              public var taskUuid: String? {
                get {
                  return resultMap["taskUUID"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "taskUUID")
                }
              }

              public var totalPageSize: Int? {
                get {
                  return resultMap["totalPageSize"] as? Int
                }
                set {
                  resultMap.updateValue(newValue, forKey: "totalPageSize")
                }
              }
            }

            public struct Pdf: GraphQLSelectionSet {
              public static let possibleTypes = ["Media"]

              public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("filename", type: .scalar(String.self)),
                GraphQLField("url", type: .scalar(String.self)),
              ]

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(filename: String? = nil, url: String? = nil) {
                self.init(unsafeResultMap: ["__typename": "Media", "filename": filename, "url": url])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var filename: String? {
                get {
                  return resultMap["filename"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "filename")
                }
              }

              public var url: String? {
                get {
                  return resultMap["url"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "url")
                }
              }
            }

            public struct Audio: GraphQLSelectionSet {
              public static let possibleTypes = ["Media"]

              public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("filename", type: .scalar(String.self)),
                GraphQLField("url", type: .scalar(String.self)),
              ]

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(filename: String? = nil, url: String? = nil) {
                self.init(unsafeResultMap: ["__typename": "Media", "filename": filename, "url": url])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var filename: String? {
                get {
                  return resultMap["filename"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "filename")
                }
              }

              public var url: String? {
                get {
                  return resultMap["url"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "url")
                }
              }
            }

            public struct Video: GraphQLSelectionSet {
              public static let possibleTypes = ["Media"]

              public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("filename", type: .scalar(String.self)),
                GraphQLField("url", type: .scalar(String.self)),
              ]

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(filename: String? = nil, url: String? = nil) {
                self.init(unsafeResultMap: ["__typename": "Media", "filename": filename, "url": url])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var filename: String? {
                get {
                  return resultMap["filename"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "filename")
                }
              }

              public var url: String? {
                get {
                  return resultMap["url"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "url")
                }
              }
            }

            public struct Exam: GraphQLSelectionSet {
              public static let possibleTypes = ["Exam"]

              public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("_id", type: .nonNull(.scalar(GraphQLID.self))),
                GraphQLField("category", type: .scalar(String.self)),
                GraphQLField("title", type: .scalar(String.self)),
                GraphQLField("q_score", type: .scalar(Int.self)),
                GraphQLField("answer", type: .scalar(String.self)),
                GraphQLField("note", type: .scalar(String.self)),
                GraphQLField("options", type: .list(.scalar(String.self))),
              ]

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(id: GraphQLID, category: String? = nil, title: String? = nil, qScore: Int? = nil, answer: String? = nil, note: String? = nil, options: [String?]? = nil) {
                self.init(unsafeResultMap: ["__typename": "Exam", "_id": id, "category": category, "title": title, "q_score": qScore, "answer": answer, "note": note, "options": options])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var id: GraphQLID {
                get {
                  return resultMap["_id"]! as! GraphQLID
                }
                set {
                  resultMap.updateValue(newValue, forKey: "_id")
                }
              }

              public var category: String? {
                get {
                  return resultMap["category"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "category")
                }
              }

              public var title: String? {
                get {
                  return resultMap["title"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "title")
                }
              }

              public var qScore: Int? {
                get {
                  return resultMap["q_score"] as? Int
                }
                set {
                  resultMap.updateValue(newValue, forKey: "q_score")
                }
              }

              public var answer: String? {
                get {
                  return resultMap["answer"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "answer")
                }
              }

              public var note: String? {
                get {
                  return resultMap["note"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "note")
                }
              }

              public var options: [String?]? {
                get {
                  return resultMap["options"] as? [String?]
                }
                set {
                  resultMap.updateValue(newValue, forKey: "options")
                }
              }
            }
          }
        }
      }
    }
  }
}

public final class GetRoundsQuery: GraphQLQuery {
  /// query getRounds($lessonId: ID!) {
  ///   rounds(lessonId: $lessonId) {
  ///     __typename
  ///     _id
  ///     name
  ///     pdfs {
  ///       __typename
  ///       filename
  ///       url
  ///     }
  ///     videos {
  ///       __typename
  ///       filename
  ///       url
  ///     }
  ///   }
  ///   lesson(id: $lessonId) {
  ///     __typename
  ///     intro
  ///     course_version {
  ///       __typename
  ///       course {
  ///         __typename
  ///         image {
  ///           __typename
  ///           filename
  ///           url
  ///         }
  ///         name
  ///       }
  ///     }
  ///   }
  /// }
  public let operationDefinition =
    "query getRounds($lessonId: ID!) { rounds(lessonId: $lessonId) { __typename _id name pdfs { __typename filename url } videos { __typename filename url } } lesson(id: $lessonId) { __typename intro course_version { __typename course { __typename image { __typename filename url } name } } } }"

  public let operationName = "getRounds"

  public var lessonId: GraphQLID

  public init(lessonId: GraphQLID) {
    self.lessonId = lessonId
  }

  public var variables: GraphQLMap? {
    return ["lessonId": lessonId]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("rounds", arguments: ["lessonId": GraphQLVariable("lessonId")], type: .list(.object(Round.selections))),
      GraphQLField("lesson", arguments: ["id": GraphQLVariable("lessonId")], type: .object(Lesson.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(rounds: [Round?]? = nil, lesson: Lesson? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "rounds": rounds.flatMap { (value: [Round?]) -> [ResultMap?] in value.map { (value: Round?) -> ResultMap? in value.flatMap { (value: Round) -> ResultMap in value.resultMap } } }, "lesson": lesson.flatMap { (value: Lesson) -> ResultMap in value.resultMap }])
    }

    public var rounds: [Round?]? {
      get {
        return (resultMap["rounds"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Round?] in value.map { (value: ResultMap?) -> Round? in value.flatMap { (value: ResultMap) -> Round in Round(unsafeResultMap: value) } } }
      }
      set {
        resultMap.updateValue(newValue.flatMap { (value: [Round?]) -> [ResultMap?] in value.map { (value: Round?) -> ResultMap? in value.flatMap { (value: Round) -> ResultMap in value.resultMap } } }, forKey: "rounds")
      }
    }

    public var lesson: Lesson? {
      get {
        return (resultMap["lesson"] as? ResultMap).flatMap { Lesson(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "lesson")
      }
    }

    public struct Round: GraphQLSelectionSet {
      public static let possibleTypes = ["Round"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("_id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("name", type: .scalar(String.self)),
        GraphQLField("pdfs", type: .list(.object(Pdf.selections))),
        GraphQLField("videos", type: .list(.object(Video.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID, name: String? = nil, pdfs: [Pdf?]? = nil, videos: [Video?]? = nil) {
        self.init(unsafeResultMap: ["__typename": "Round", "_id": id, "name": name, "pdfs": pdfs.flatMap { (value: [Pdf?]) -> [ResultMap?] in value.map { (value: Pdf?) -> ResultMap? in value.flatMap { (value: Pdf) -> ResultMap in value.resultMap } } }, "videos": videos.flatMap { (value: [Video?]) -> [ResultMap?] in value.map { (value: Video?) -> ResultMap? in value.flatMap { (value: Video) -> ResultMap in value.resultMap } } }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return resultMap["_id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "_id")
        }
      }

      public var name: String? {
        get {
          return resultMap["name"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "name")
        }
      }

      public var pdfs: [Pdf?]? {
        get {
          return (resultMap["pdfs"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Pdf?] in value.map { (value: ResultMap?) -> Pdf? in value.flatMap { (value: ResultMap) -> Pdf in Pdf(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Pdf?]) -> [ResultMap?] in value.map { (value: Pdf?) -> ResultMap? in value.flatMap { (value: Pdf) -> ResultMap in value.resultMap } } }, forKey: "pdfs")
        }
      }

      public var videos: [Video?]? {
        get {
          return (resultMap["videos"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Video?] in value.map { (value: ResultMap?) -> Video? in value.flatMap { (value: ResultMap) -> Video in Video(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Video?]) -> [ResultMap?] in value.map { (value: Video?) -> ResultMap? in value.flatMap { (value: Video) -> ResultMap in value.resultMap } } }, forKey: "videos")
        }
      }

      public struct Pdf: GraphQLSelectionSet {
        public static let possibleTypes = ["Media"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("filename", type: .scalar(String.self)),
          GraphQLField("url", type: .scalar(String.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(filename: String? = nil, url: String? = nil) {
          self.init(unsafeResultMap: ["__typename": "Media", "filename": filename, "url": url])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var filename: String? {
          get {
            return resultMap["filename"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "filename")
          }
        }

        public var url: String? {
          get {
            return resultMap["url"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "url")
          }
        }
      }

      public struct Video: GraphQLSelectionSet {
        public static let possibleTypes = ["Media"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("filename", type: .scalar(String.self)),
          GraphQLField("url", type: .scalar(String.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(filename: String? = nil, url: String? = nil) {
          self.init(unsafeResultMap: ["__typename": "Media", "filename": filename, "url": url])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var filename: String? {
          get {
            return resultMap["filename"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "filename")
          }
        }

        public var url: String? {
          get {
            return resultMap["url"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "url")
          }
        }
      }
    }

    public struct Lesson: GraphQLSelectionSet {
      public static let possibleTypes = ["Lesson"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("intro", type: .scalar(String.self)),
        GraphQLField("course_version", type: .object(CourseVersion.selections)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(intro: String? = nil, courseVersion: CourseVersion? = nil) {
        self.init(unsafeResultMap: ["__typename": "Lesson", "intro": intro, "course_version": courseVersion.flatMap { (value: CourseVersion) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var intro: String? {
        get {
          return resultMap["intro"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "intro")
        }
      }

      public var courseVersion: CourseVersion? {
        get {
          return (resultMap["course_version"] as? ResultMap).flatMap { CourseVersion(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "course_version")
        }
      }

      public struct CourseVersion: GraphQLSelectionSet {
        public static let possibleTypes = ["CourseVersion"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("course", type: .object(Course.selections)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(course: Course? = nil) {
          self.init(unsafeResultMap: ["__typename": "CourseVersion", "course": course.flatMap { (value: Course) -> ResultMap in value.resultMap }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var course: Course? {
          get {
            return (resultMap["course"] as? ResultMap).flatMap { Course(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "course")
          }
        }

        public struct Course: GraphQLSelectionSet {
          public static let possibleTypes = ["Course"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("image", type: .object(Image.selections)),
            GraphQLField("name", type: .nonNull(.scalar(String.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(image: Image? = nil, name: String) {
            self.init(unsafeResultMap: ["__typename": "Course", "image": image.flatMap { (value: Image) -> ResultMap in value.resultMap }, "name": name])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var image: Image? {
            get {
              return (resultMap["image"] as? ResultMap).flatMap { Image(unsafeResultMap: $0) }
            }
            set {
              resultMap.updateValue(newValue?.resultMap, forKey: "image")
            }
          }

          public var name: String {
            get {
              return resultMap["name"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "name")
            }
          }

          public struct Image: GraphQLSelectionSet {
            public static let possibleTypes = ["Media"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("filename", type: .scalar(String.self)),
              GraphQLField("url", type: .scalar(String.self)),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(filename: String? = nil, url: String? = nil) {
              self.init(unsafeResultMap: ["__typename": "Media", "filename": filename, "url": url])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var filename: String? {
              get {
                return resultMap["filename"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "filename")
              }
            }

            public var url: String? {
              get {
                return resultMap["url"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "url")
              }
            }
          }
        }
      }
    }
  }
}

public final class QuestAddStudentExamMutation: GraphQLMutation {
  /// mutation questAddStudentExam($studentId: ID!, $scheduleId: ID!, $examRecord: [ExamRecordInput], $rightExam: Int!) {
  ///   addStudentExam(input: {student: $studentId, schedule: $scheduleId, exam_record: $examRecord, right_exam: $rightExam}) {
  ///     __typename
  ///     _id
  ///   }
  /// }
  public let operationDefinition =
    "mutation questAddStudentExam($studentId: ID!, $scheduleId: ID!, $examRecord: [ExamRecordInput], $rightExam: Int!) { addStudentExam(input: {student: $studentId, schedule: $scheduleId, exam_record: $examRecord, right_exam: $rightExam}) { __typename _id } }"

  public let operationName = "questAddStudentExam"

  public var studentId: GraphQLID
  public var scheduleId: GraphQLID
  public var examRecord: [ExamRecordInput?]?
  public var rightExam: Int

  public init(studentId: GraphQLID, scheduleId: GraphQLID, examRecord: [ExamRecordInput?]? = nil, rightExam: Int) {
    self.studentId = studentId
    self.scheduleId = scheduleId
    self.examRecord = examRecord
    self.rightExam = rightExam
  }

  public var variables: GraphQLMap? {
    return ["studentId": studentId, "scheduleId": scheduleId, "examRecord": examRecord, "rightExam": rightExam]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("addStudentExam", arguments: ["input": ["student": GraphQLVariable("studentId"), "schedule": GraphQLVariable("scheduleId"), "exam_record": GraphQLVariable("examRecord"), "right_exam": GraphQLVariable("rightExam")]], type: .object(AddStudentExam.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(addStudentExam: AddStudentExam? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "addStudentExam": addStudentExam.flatMap { (value: AddStudentExam) -> ResultMap in value.resultMap }])
    }

    public var addStudentExam: AddStudentExam? {
      get {
        return (resultMap["addStudentExam"] as? ResultMap).flatMap { AddStudentExam(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "addStudentExam")
      }
    }

    public struct AddStudentExam: GraphQLSelectionSet {
      public static let possibleTypes = ["StudentExam"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("_id", type: .nonNull(.scalar(GraphQLID.self))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID) {
        self.init(unsafeResultMap: ["__typename": "StudentExam", "_id": id])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return resultMap["_id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "_id")
        }
      }
    }
  }
}

public final class GetScheduleExamQuery: GraphQLQuery {
  /// query getScheduleExam($scheduleId: ID!, $studentId: ID!) {
  ///   scheduleExam(schedule: $scheduleId, student: $studentId) {
  ///     __typename
  ///     _id
  ///     exam_record {
  ///       __typename
  ///       _id
  ///       exam {
  ///         __typename
  ///         _id
  ///         category
  ///         title
  ///         q_score
  ///         answer
  ///         note
  ///         options
  ///       }
  ///       right_count
  ///       answer
  ///     }
  ///     submit_num
  ///   }
  /// }
  public let operationDefinition =
    "query getScheduleExam($scheduleId: ID!, $studentId: ID!) { scheduleExam(schedule: $scheduleId, student: $studentId) { __typename _id exam_record { __typename _id exam { __typename _id category title q_score answer note options } right_count answer } submit_num } }"

  public let operationName = "getScheduleExam"

  public var scheduleId: GraphQLID
  public var studentId: GraphQLID

  public init(scheduleId: GraphQLID, studentId: GraphQLID) {
    self.scheduleId = scheduleId
    self.studentId = studentId
  }

  public var variables: GraphQLMap? {
    return ["scheduleId": scheduleId, "studentId": studentId]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("scheduleExam", arguments: ["schedule": GraphQLVariable("scheduleId"), "student": GraphQLVariable("studentId")], type: .object(ScheduleExam.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(scheduleExam: ScheduleExam? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "scheduleExam": scheduleExam.flatMap { (value: ScheduleExam) -> ResultMap in value.resultMap }])
    }

    public var scheduleExam: ScheduleExam? {
      get {
        return (resultMap["scheduleExam"] as? ResultMap).flatMap { ScheduleExam(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "scheduleExam")
      }
    }

    public struct ScheduleExam: GraphQLSelectionSet {
      public static let possibleTypes = ["ScheduleExam"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("_id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("exam_record", type: .list(.object(ExamRecord.selections))),
        GraphQLField("submit_num", type: .scalar(Int.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID, examRecord: [ExamRecord?]? = nil, submitNum: Int? = nil) {
        self.init(unsafeResultMap: ["__typename": "ScheduleExam", "_id": id, "exam_record": examRecord.flatMap { (value: [ExamRecord?]) -> [ResultMap?] in value.map { (value: ExamRecord?) -> ResultMap? in value.flatMap { (value: ExamRecord) -> ResultMap in value.resultMap } } }, "submit_num": submitNum])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return resultMap["_id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "_id")
        }
      }

      public var examRecord: [ExamRecord?]? {
        get {
          return (resultMap["exam_record"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [ExamRecord?] in value.map { (value: ResultMap?) -> ExamRecord? in value.flatMap { (value: ResultMap) -> ExamRecord in ExamRecord(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [ExamRecord?]) -> [ResultMap?] in value.map { (value: ExamRecord?) -> ResultMap? in value.flatMap { (value: ExamRecord) -> ResultMap in value.resultMap } } }, forKey: "exam_record")
        }
      }

      public var submitNum: Int? {
        get {
          return resultMap["submit_num"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "submit_num")
        }
      }

      public struct ExamRecord: GraphQLSelectionSet {
        public static let possibleTypes = ["ExamRecord"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("_id", type: .scalar(GraphQLID.self)),
          GraphQLField("exam", type: .object(Exam.selections)),
          GraphQLField("right_count", type: .scalar(Int.self)),
          GraphQLField("answer", type: .scalar(String.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: GraphQLID? = nil, exam: Exam? = nil, rightCount: Int? = nil, answer: String? = nil) {
          self.init(unsafeResultMap: ["__typename": "ExamRecord", "_id": id, "exam": exam.flatMap { (value: Exam) -> ResultMap in value.resultMap }, "right_count": rightCount, "answer": answer])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID? {
          get {
            return resultMap["_id"] as? GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "_id")
          }
        }

        public var exam: Exam? {
          get {
            return (resultMap["exam"] as? ResultMap).flatMap { Exam(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "exam")
          }
        }

        public var rightCount: Int? {
          get {
            return resultMap["right_count"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "right_count")
          }
        }

        public var answer: String? {
          get {
            return resultMap["answer"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "answer")
          }
        }

        public struct Exam: GraphQLSelectionSet {
          public static let possibleTypes = ["Exam"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("_id", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("category", type: .scalar(String.self)),
            GraphQLField("title", type: .scalar(String.self)),
            GraphQLField("q_score", type: .scalar(Int.self)),
            GraphQLField("answer", type: .scalar(String.self)),
            GraphQLField("note", type: .scalar(String.self)),
            GraphQLField("options", type: .list(.scalar(String.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(id: GraphQLID, category: String? = nil, title: String? = nil, qScore: Int? = nil, answer: String? = nil, note: String? = nil, options: [String?]? = nil) {
            self.init(unsafeResultMap: ["__typename": "Exam", "_id": id, "category": category, "title": title, "q_score": qScore, "answer": answer, "note": note, "options": options])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var id: GraphQLID {
            get {
              return resultMap["_id"]! as! GraphQLID
            }
            set {
              resultMap.updateValue(newValue, forKey: "_id")
            }
          }

          public var category: String? {
            get {
              return resultMap["category"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "category")
            }
          }

          public var title: String? {
            get {
              return resultMap["title"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "title")
            }
          }

          public var qScore: Int? {
            get {
              return resultMap["q_score"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "q_score")
            }
          }

          public var answer: String? {
            get {
              return resultMap["answer"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "answer")
            }
          }

          public var note: String? {
            get {
              return resultMap["note"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "note")
            }
          }

          public var options: [String?]? {
            get {
              return resultMap["options"] as? [String?]
            }
            set {
              resultMap.updateValue(newValue, forKey: "options")
            }
          }
        }
      }
    }
  }
}

public final class GetStudentHomeworksQuery: GraphQLQuery {
  /// query getStudentHomeworks($scheduleId: ID!, $studentId: ID!) {
  ///   studentHomeworks(filter: {student: $studentId, schedule: $scheduleId}) {
  ///     __typename
  ///     _id
  ///     schedule_homework {
  ///       __typename
  ///       _id
  ///       full_score
  ///       questions_count
  ///       question_path {
  ///         __typename
  ///         _id
  ///         name
  ///         sections {
  ///           __typename
  ///           _id
  ///           name
  ///           parts {
  ///             __typename
  ///             _id
  ///             name
  ///           }
  ///         }
  ///       }
  ///     }
  ///     score {
  ///       __typename
  ///       keguan
  ///       zhuguan
  ///       total
  ///     }
  ///     is_submit
  ///     is_pass
  ///     is_new
  ///     is_revised
  ///   }
  /// }
  public let operationDefinition =
    "query getStudentHomeworks($scheduleId: ID!, $studentId: ID!) { studentHomeworks(filter: {student: $studentId, schedule: $scheduleId}) { __typename _id schedule_homework { __typename _id full_score questions_count question_path { __typename _id name sections { __typename _id name parts { __typename _id name } } } } score { __typename keguan zhuguan total } is_submit is_pass is_new is_revised } }"

  public let operationName = "getStudentHomeworks"

  public var scheduleId: GraphQLID
  public var studentId: GraphQLID

  public init(scheduleId: GraphQLID, studentId: GraphQLID) {
    self.scheduleId = scheduleId
    self.studentId = studentId
  }

  public var variables: GraphQLMap? {
    return ["scheduleId": scheduleId, "studentId": studentId]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("studentHomeworks", arguments: ["filter": ["student": GraphQLVariable("studentId"), "schedule": GraphQLVariable("scheduleId")]], type: .list(.object(StudentHomework.selections))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(studentHomeworks: [StudentHomework?]? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "studentHomeworks": studentHomeworks.flatMap { (value: [StudentHomework?]) -> [ResultMap?] in value.map { (value: StudentHomework?) -> ResultMap? in value.flatMap { (value: StudentHomework) -> ResultMap in value.resultMap } } }])
    }

    public var studentHomeworks: [StudentHomework?]? {
      get {
        return (resultMap["studentHomeworks"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [StudentHomework?] in value.map { (value: ResultMap?) -> StudentHomework? in value.flatMap { (value: ResultMap) -> StudentHomework in StudentHomework(unsafeResultMap: value) } } }
      }
      set {
        resultMap.updateValue(newValue.flatMap { (value: [StudentHomework?]) -> [ResultMap?] in value.map { (value: StudentHomework?) -> ResultMap? in value.flatMap { (value: StudentHomework) -> ResultMap in value.resultMap } } }, forKey: "studentHomeworks")
      }
    }

    public struct StudentHomework: GraphQLSelectionSet {
      public static let possibleTypes = ["StudentHomework"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("_id", type: .scalar(GraphQLID.self)),
        GraphQLField("schedule_homework", type: .object(ScheduleHomework.selections)),
        GraphQLField("score", type: .object(Score.selections)),
        GraphQLField("is_submit", type: .scalar(Bool.self)),
        GraphQLField("is_pass", type: .scalar(Bool.self)),
        GraphQLField("is_new", type: .scalar(Bool.self)),
        GraphQLField("is_revised", type: .scalar(Bool.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID? = nil, scheduleHomework: ScheduleHomework? = nil, score: Score? = nil, isSubmit: Bool? = nil, isPass: Bool? = nil, isNew: Bool? = nil, isRevised: Bool? = nil) {
        self.init(unsafeResultMap: ["__typename": "StudentHomework", "_id": id, "schedule_homework": scheduleHomework.flatMap { (value: ScheduleHomework) -> ResultMap in value.resultMap }, "score": score.flatMap { (value: Score) -> ResultMap in value.resultMap }, "is_submit": isSubmit, "is_pass": isPass, "is_new": isNew, "is_revised": isRevised])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID? {
        get {
          return resultMap["_id"] as? GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "_id")
        }
      }

      public var scheduleHomework: ScheduleHomework? {
        get {
          return (resultMap["schedule_homework"] as? ResultMap).flatMap { ScheduleHomework(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "schedule_homework")
        }
      }

      public var score: Score? {
        get {
          return (resultMap["score"] as? ResultMap).flatMap { Score(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "score")
        }
      }

      /// 学生是否已提交
      public var isSubmit: Bool? {
        get {
          return resultMap["is_submit"] as? Bool
        }
        set {
          resultMap.updateValue(newValue, forKey: "is_submit")
        }
      }

      public var isPass: Bool? {
        get {
          return resultMap["is_pass"] as? Bool
        }
        set {
          resultMap.updateValue(newValue, forKey: "is_pass")
        }
      }

      /// 学生已查看
      public var isNew: Bool? {
        get {
          return resultMap["is_new"] as? Bool
        }
        set {
          resultMap.updateValue(newValue, forKey: "is_new")
        }
      }

      /// 是否已审阅
      public var isRevised: Bool? {
        get {
          return resultMap["is_revised"] as? Bool
        }
        set {
          resultMap.updateValue(newValue, forKey: "is_revised")
        }
      }

      public struct ScheduleHomework: GraphQLSelectionSet {
        public static let possibleTypes = ["ScheduleHomework"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("_id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("full_score", type: .scalar(Int.self)),
          GraphQLField("questions_count", type: .scalar(Int.self)),
          GraphQLField("question_path", type: .object(QuestionPath.selections)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: GraphQLID, fullScore: Int? = nil, questionsCount: Int? = nil, questionPath: QuestionPath? = nil) {
          self.init(unsafeResultMap: ["__typename": "ScheduleHomework", "_id": id, "full_score": fullScore, "questions_count": questionsCount, "question_path": questionPath.flatMap { (value: QuestionPath) -> ResultMap in value.resultMap }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return resultMap["_id"]! as! GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "_id")
          }
        }

        public var fullScore: Int? {
          get {
            return resultMap["full_score"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "full_score")
          }
        }

        public var questionsCount: Int? {
          get {
            return resultMap["questions_count"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "questions_count")
          }
        }

        public var questionPath: QuestionPath? {
          get {
            return (resultMap["question_path"] as? ResultMap).flatMap { QuestionPath(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "question_path")
          }
        }

        public struct QuestionPath: GraphQLSelectionSet {
          public static let possibleTypes = ["Series"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("_id", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("name", type: .scalar(String.self)),
            GraphQLField("sections", type: .list(.object(Section.selections))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(id: GraphQLID, name: String? = nil, sections: [Section?]? = nil) {
            self.init(unsafeResultMap: ["__typename": "Series", "_id": id, "name": name, "sections": sections.flatMap { (value: [Section?]) -> [ResultMap?] in value.map { (value: Section?) -> ResultMap? in value.flatMap { (value: Section) -> ResultMap in value.resultMap } } }])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var id: GraphQLID {
            get {
              return resultMap["_id"]! as! GraphQLID
            }
            set {
              resultMap.updateValue(newValue, forKey: "_id")
            }
          }

          public var name: String? {
            get {
              return resultMap["name"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "name")
            }
          }

          public var sections: [Section?]? {
            get {
              return (resultMap["sections"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Section?] in value.map { (value: ResultMap?) -> Section? in value.flatMap { (value: ResultMap) -> Section in Section(unsafeResultMap: value) } } }
            }
            set {
              resultMap.updateValue(newValue.flatMap { (value: [Section?]) -> [ResultMap?] in value.map { (value: Section?) -> ResultMap? in value.flatMap { (value: Section) -> ResultMap in value.resultMap } } }, forKey: "sections")
            }
          }

          public struct Section: GraphQLSelectionSet {
            public static let possibleTypes = ["Section"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("_id", type: .nonNull(.scalar(GraphQLID.self))),
              GraphQLField("name", type: .scalar(String.self)),
              GraphQLField("parts", type: .list(.object(Part.selections))),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(id: GraphQLID, name: String? = nil, parts: [Part?]? = nil) {
              self.init(unsafeResultMap: ["__typename": "Section", "_id": id, "name": name, "parts": parts.flatMap { (value: [Part?]) -> [ResultMap?] in value.map { (value: Part?) -> ResultMap? in value.flatMap { (value: Part) -> ResultMap in value.resultMap } } }])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var id: GraphQLID {
              get {
                return resultMap["_id"]! as! GraphQLID
              }
              set {
                resultMap.updateValue(newValue, forKey: "_id")
              }
            }

            public var name: String? {
              get {
                return resultMap["name"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "name")
              }
            }

            public var parts: [Part?]? {
              get {
                return (resultMap["parts"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Part?] in value.map { (value: ResultMap?) -> Part? in value.flatMap { (value: ResultMap) -> Part in Part(unsafeResultMap: value) } } }
              }
              set {
                resultMap.updateValue(newValue.flatMap { (value: [Part?]) -> [ResultMap?] in value.map { (value: Part?) -> ResultMap? in value.flatMap { (value: Part) -> ResultMap in value.resultMap } } }, forKey: "parts")
              }
            }

            public struct Part: GraphQLSelectionSet {
              public static let possibleTypes = ["Part"]

              public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("_id", type: .nonNull(.scalar(GraphQLID.self))),
                GraphQLField("name", type: .scalar(String.self)),
              ]

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(id: GraphQLID, name: String? = nil) {
                self.init(unsafeResultMap: ["__typename": "Part", "_id": id, "name": name])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var id: GraphQLID {
                get {
                  return resultMap["_id"]! as! GraphQLID
                }
                set {
                  resultMap.updateValue(newValue, forKey: "_id")
                }
              }

              public var name: String? {
                get {
                  return resultMap["name"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "name")
                }
              }
            }
          }
        }
      }

      public struct Score: GraphQLSelectionSet {
        public static let possibleTypes = ["StudentHomeworkScore"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("keguan", type: .scalar(Int.self)),
          GraphQLField("zhuguan", type: .scalar(Int.self)),
          GraphQLField("total", type: .scalar(Int.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(keguan: Int? = nil, zhuguan: Int? = nil, total: Int? = nil) {
          self.init(unsafeResultMap: ["__typename": "StudentHomeworkScore", "keguan": keguan, "zhuguan": zhuguan, "total": total])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var keguan: Int? {
          get {
            return resultMap["keguan"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "keguan")
          }
        }

        public var zhuguan: Int? {
          get {
            return resultMap["zhuguan"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "zhuguan")
          }
        }

        public var total: Int? {
          get {
            return resultMap["total"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "total")
          }
        }
      }
    }
  }
}

public final class GetStudentHomeworkQuery: GraphQLQuery {
  /// query getStudentHomework($id: ID!, $byStudent: Boolean) {
  ///   studentHomework(id: $id, byStudent: $byStudent) {
  ///     __typename
  ///     _id
  ///     part_record {
  ///       __typename
  ///       part
  ///       score
  ///       total
  ///       right
  ///       is_submit
  ///     }
  ///     question_record {
  ///       __typename
  ///       question
  ///       part
  ///       answer
  ///       score
  ///       text_comment
  ///       voice_comment
  ///     }
  ///     schedule_homework {
  ///       __typename
  ///       _id
  ///       questions_count
  ///       full_score
  ///       question_path {
  ///         __typename
  ///         _id
  ///         name
  ///         sections {
  ///           __typename
  ///           _id
  ///           name
  ///           parts {
  ///             __typename
  ///             _id
  ///             name
  ///             questions_count
  ///           }
  ///         }
  ///       }
  ///     }
  ///     score {
  ///       __typename
  ///       keguan
  ///       zhuguan
  ///       total
  ///     }
  ///     is_submit
  ///     is_pass
  ///     is_new
  ///     is_revised
  ///   }
  /// }
  public let operationDefinition =
    "query getStudentHomework($id: ID!, $byStudent: Boolean) { studentHomework(id: $id, byStudent: $byStudent) { __typename _id part_record { __typename part score total right is_submit } question_record { __typename question part answer score text_comment voice_comment } schedule_homework { __typename _id questions_count full_score question_path { __typename _id name sections { __typename _id name parts { __typename _id name questions_count } } } } score { __typename keguan zhuguan total } is_submit is_pass is_new is_revised } }"

  public let operationName = "getStudentHomework"

  public var id: GraphQLID
  public var byStudent: Bool?

  public init(id: GraphQLID, byStudent: Bool? = nil) {
    self.id = id
    self.byStudent = byStudent
  }

  public var variables: GraphQLMap? {
    return ["id": id, "byStudent": byStudent]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("studentHomework", arguments: ["id": GraphQLVariable("id"), "byStudent": GraphQLVariable("byStudent")], type: .object(StudentHomework.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(studentHomework: StudentHomework? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "studentHomework": studentHomework.flatMap { (value: StudentHomework) -> ResultMap in value.resultMap }])
    }

    public var studentHomework: StudentHomework? {
      get {
        return (resultMap["studentHomework"] as? ResultMap).flatMap { StudentHomework(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "studentHomework")
      }
    }

    public struct StudentHomework: GraphQLSelectionSet {
      public static let possibleTypes = ["StudentHomework"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("_id", type: .scalar(GraphQLID.self)),
        GraphQLField("part_record", type: .list(.object(PartRecord.selections))),
        GraphQLField("question_record", type: .list(.object(QuestionRecord.selections))),
        GraphQLField("schedule_homework", type: .object(ScheduleHomework.selections)),
        GraphQLField("score", type: .object(Score.selections)),
        GraphQLField("is_submit", type: .scalar(Bool.self)),
        GraphQLField("is_pass", type: .scalar(Bool.self)),
        GraphQLField("is_new", type: .scalar(Bool.self)),
        GraphQLField("is_revised", type: .scalar(Bool.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID? = nil, partRecord: [PartRecord?]? = nil, questionRecord: [QuestionRecord?]? = nil, scheduleHomework: ScheduleHomework? = nil, score: Score? = nil, isSubmit: Bool? = nil, isPass: Bool? = nil, isNew: Bool? = nil, isRevised: Bool? = nil) {
        self.init(unsafeResultMap: ["__typename": "StudentHomework", "_id": id, "part_record": partRecord.flatMap { (value: [PartRecord?]) -> [ResultMap?] in value.map { (value: PartRecord?) -> ResultMap? in value.flatMap { (value: PartRecord) -> ResultMap in value.resultMap } } }, "question_record": questionRecord.flatMap { (value: [QuestionRecord?]) -> [ResultMap?] in value.map { (value: QuestionRecord?) -> ResultMap? in value.flatMap { (value: QuestionRecord) -> ResultMap in value.resultMap } } }, "schedule_homework": scheduleHomework.flatMap { (value: ScheduleHomework) -> ResultMap in value.resultMap }, "score": score.flatMap { (value: Score) -> ResultMap in value.resultMap }, "is_submit": isSubmit, "is_pass": isPass, "is_new": isNew, "is_revised": isRevised])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID? {
        get {
          return resultMap["_id"] as? GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "_id")
        }
      }

      /// part答题统计
      public var partRecord: [PartRecord?]? {
        get {
          return (resultMap["part_record"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [PartRecord?] in value.map { (value: ResultMap?) -> PartRecord? in value.flatMap { (value: ResultMap) -> PartRecord in PartRecord(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [PartRecord?]) -> [ResultMap?] in value.map { (value: PartRecord?) -> ResultMap? in value.flatMap { (value: PartRecord) -> ResultMap in value.resultMap } } }, forKey: "part_record")
        }
      }

      public var questionRecord: [QuestionRecord?]? {
        get {
          return (resultMap["question_record"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [QuestionRecord?] in value.map { (value: ResultMap?) -> QuestionRecord? in value.flatMap { (value: ResultMap) -> QuestionRecord in QuestionRecord(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [QuestionRecord?]) -> [ResultMap?] in value.map { (value: QuestionRecord?) -> ResultMap? in value.flatMap { (value: QuestionRecord) -> ResultMap in value.resultMap } } }, forKey: "question_record")
        }
      }

      public var scheduleHomework: ScheduleHomework? {
        get {
          return (resultMap["schedule_homework"] as? ResultMap).flatMap { ScheduleHomework(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "schedule_homework")
        }
      }

      public var score: Score? {
        get {
          return (resultMap["score"] as? ResultMap).flatMap { Score(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "score")
        }
      }

      /// 学生是否已提交
      public var isSubmit: Bool? {
        get {
          return resultMap["is_submit"] as? Bool
        }
        set {
          resultMap.updateValue(newValue, forKey: "is_submit")
        }
      }

      public var isPass: Bool? {
        get {
          return resultMap["is_pass"] as? Bool
        }
        set {
          resultMap.updateValue(newValue, forKey: "is_pass")
        }
      }

      /// 学生已查看
      public var isNew: Bool? {
        get {
          return resultMap["is_new"] as? Bool
        }
        set {
          resultMap.updateValue(newValue, forKey: "is_new")
        }
      }

      /// 是否已审阅
      public var isRevised: Bool? {
        get {
          return resultMap["is_revised"] as? Bool
        }
        set {
          resultMap.updateValue(newValue, forKey: "is_revised")
        }
      }

      public struct PartRecord: GraphQLSelectionSet {
        public static let possibleTypes = ["PartRecord"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("part", type: .scalar(GraphQLID.self)),
          GraphQLField("score", type: .scalar(Int.self)),
          GraphQLField("total", type: .scalar(Int.self)),
          GraphQLField("right", type: .scalar(Int.self)),
          GraphQLField("is_submit", type: .scalar(Bool.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(part: GraphQLID? = nil, score: Int? = nil, total: Int? = nil, `right`: Int? = nil, isSubmit: Bool? = nil) {
          self.init(unsafeResultMap: ["__typename": "PartRecord", "part": part, "score": score, "total": total, "right": `right`, "is_submit": isSubmit])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var part: GraphQLID? {
          get {
            return resultMap["part"] as? GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "part")
          }
        }

        /// 学生得分总计
        public var score: Int? {
          get {
            return resultMap["score"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "score")
          }
        }

        /// 学生已答题总数
        public var total: Int? {
          get {
            return resultMap["total"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "total")
          }
        }

        /// 学生答对题数
        public var `right`: Int? {
          get {
            return resultMap["right"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "right")
          }
        }

        /// 是否已提交
        public var isSubmit: Bool? {
          get {
            return resultMap["is_submit"] as? Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "is_submit")
          }
        }
      }

      public struct QuestionRecord: GraphQLSelectionSet {
        public static let possibleTypes = ["QuestionRecord"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("question", type: .scalar(GraphQLID.self)),
          GraphQLField("part", type: .scalar(GraphQLID.self)),
          GraphQLField("answer", type: .scalar(String.self)),
          GraphQLField("score", type: .scalar(Int.self)),
          GraphQLField("text_comment", type: .scalar(String.self)),
          GraphQLField("voice_comment", type: .scalar(String.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(question: GraphQLID? = nil, part: GraphQLID? = nil, answer: String? = nil, score: Int? = nil, textComment: String? = nil, voiceComment: String? = nil) {
          self.init(unsafeResultMap: ["__typename": "QuestionRecord", "question": question, "part": part, "answer": answer, "score": score, "text_comment": textComment, "voice_comment": voiceComment])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var question: GraphQLID? {
          get {
            return resultMap["question"] as? GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "question")
          }
        }

        public var part: GraphQLID? {
          get {
            return resultMap["part"] as? GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "part")
          }
        }

        public var answer: String? {
          get {
            return resultMap["answer"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "answer")
          }
        }

        public var score: Int? {
          get {
            return resultMap["score"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "score")
          }
        }

        public var textComment: String? {
          get {
            return resultMap["text_comment"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "text_comment")
          }
        }

        public var voiceComment: String? {
          get {
            return resultMap["voice_comment"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "voice_comment")
          }
        }
      }

      public struct ScheduleHomework: GraphQLSelectionSet {
        public static let possibleTypes = ["ScheduleHomework"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("_id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("questions_count", type: .scalar(Int.self)),
          GraphQLField("full_score", type: .scalar(Int.self)),
          GraphQLField("question_path", type: .object(QuestionPath.selections)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: GraphQLID, questionsCount: Int? = nil, fullScore: Int? = nil, questionPath: QuestionPath? = nil) {
          self.init(unsafeResultMap: ["__typename": "ScheduleHomework", "_id": id, "questions_count": questionsCount, "full_score": fullScore, "question_path": questionPath.flatMap { (value: QuestionPath) -> ResultMap in value.resultMap }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return resultMap["_id"]! as! GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "_id")
          }
        }

        public var questionsCount: Int? {
          get {
            return resultMap["questions_count"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "questions_count")
          }
        }

        public var fullScore: Int? {
          get {
            return resultMap["full_score"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "full_score")
          }
        }

        public var questionPath: QuestionPath? {
          get {
            return (resultMap["question_path"] as? ResultMap).flatMap { QuestionPath(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "question_path")
          }
        }

        public struct QuestionPath: GraphQLSelectionSet {
          public static let possibleTypes = ["Series"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("_id", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("name", type: .scalar(String.self)),
            GraphQLField("sections", type: .list(.object(Section.selections))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(id: GraphQLID, name: String? = nil, sections: [Section?]? = nil) {
            self.init(unsafeResultMap: ["__typename": "Series", "_id": id, "name": name, "sections": sections.flatMap { (value: [Section?]) -> [ResultMap?] in value.map { (value: Section?) -> ResultMap? in value.flatMap { (value: Section) -> ResultMap in value.resultMap } } }])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var id: GraphQLID {
            get {
              return resultMap["_id"]! as! GraphQLID
            }
            set {
              resultMap.updateValue(newValue, forKey: "_id")
            }
          }

          public var name: String? {
            get {
              return resultMap["name"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "name")
            }
          }

          public var sections: [Section?]? {
            get {
              return (resultMap["sections"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Section?] in value.map { (value: ResultMap?) -> Section? in value.flatMap { (value: ResultMap) -> Section in Section(unsafeResultMap: value) } } }
            }
            set {
              resultMap.updateValue(newValue.flatMap { (value: [Section?]) -> [ResultMap?] in value.map { (value: Section?) -> ResultMap? in value.flatMap { (value: Section) -> ResultMap in value.resultMap } } }, forKey: "sections")
            }
          }

          public struct Section: GraphQLSelectionSet {
            public static let possibleTypes = ["Section"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("_id", type: .nonNull(.scalar(GraphQLID.self))),
              GraphQLField("name", type: .scalar(String.self)),
              GraphQLField("parts", type: .list(.object(Part.selections))),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(id: GraphQLID, name: String? = nil, parts: [Part?]? = nil) {
              self.init(unsafeResultMap: ["__typename": "Section", "_id": id, "name": name, "parts": parts.flatMap { (value: [Part?]) -> [ResultMap?] in value.map { (value: Part?) -> ResultMap? in value.flatMap { (value: Part) -> ResultMap in value.resultMap } } }])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var id: GraphQLID {
              get {
                return resultMap["_id"]! as! GraphQLID
              }
              set {
                resultMap.updateValue(newValue, forKey: "_id")
              }
            }

            public var name: String? {
              get {
                return resultMap["name"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "name")
              }
            }

            public var parts: [Part?]? {
              get {
                return (resultMap["parts"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Part?] in value.map { (value: ResultMap?) -> Part? in value.flatMap { (value: ResultMap) -> Part in Part(unsafeResultMap: value) } } }
              }
              set {
                resultMap.updateValue(newValue.flatMap { (value: [Part?]) -> [ResultMap?] in value.map { (value: Part?) -> ResultMap? in value.flatMap { (value: Part) -> ResultMap in value.resultMap } } }, forKey: "parts")
              }
            }

            public struct Part: GraphQLSelectionSet {
              public static let possibleTypes = ["Part"]

              public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("_id", type: .nonNull(.scalar(GraphQLID.self))),
                GraphQLField("name", type: .scalar(String.self)),
                GraphQLField("questions_count", type: .scalar(Int.self)),
              ]

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(id: GraphQLID, name: String? = nil, questionsCount: Int? = nil) {
                self.init(unsafeResultMap: ["__typename": "Part", "_id": id, "name": name, "questions_count": questionsCount])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var id: GraphQLID {
                get {
                  return resultMap["_id"]! as! GraphQLID
                }
                set {
                  resultMap.updateValue(newValue, forKey: "_id")
                }
              }

              public var name: String? {
                get {
                  return resultMap["name"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "name")
                }
              }

              public var questionsCount: Int? {
                get {
                  return resultMap["questions_count"] as? Int
                }
                set {
                  resultMap.updateValue(newValue, forKey: "questions_count")
                }
              }
            }
          }
        }
      }

      public struct Score: GraphQLSelectionSet {
        public static let possibleTypes = ["StudentHomeworkScore"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("keguan", type: .scalar(Int.self)),
          GraphQLField("zhuguan", type: .scalar(Int.self)),
          GraphQLField("total", type: .scalar(Int.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(keguan: Int? = nil, zhuguan: Int? = nil, total: Int? = nil) {
          self.init(unsafeResultMap: ["__typename": "StudentHomeworkScore", "keguan": keguan, "zhuguan": zhuguan, "total": total])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var keguan: Int? {
          get {
            return resultMap["keguan"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "keguan")
          }
        }

        public var zhuguan: Int? {
          get {
            return resultMap["zhuguan"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "zhuguan")
          }
        }

        public var total: Int? {
          get {
            return resultMap["total"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "total")
          }
        }
      }
    }
  }
}

public final class GetQuestionsQuery: GraphQLQuery {
  /// query getQuestions($studentHomeworkId: ID!, $partId: ID!) {
  ///   questions(partId: $partId) {
  ///     __typename
  ///     _id
  ///     category
  ///     title
  ///     q_score
  ///     answer
  ///     note
  ///     options
  ///     pre_title
  ///     group
  ///   }
  ///   questionRecords(id: $studentHomeworkId, partId: $partId) {
  ///     __typename
  ///     question
  ///     answer
  ///     score
  ///   }
  /// }
  public let operationDefinition =
    "query getQuestions($studentHomeworkId: ID!, $partId: ID!) { questions(partId: $partId) { __typename _id category title q_score answer note options pre_title group } questionRecords(id: $studentHomeworkId, partId: $partId) { __typename question answer score } }"

  public let operationName = "getQuestions"

  public var studentHomeworkId: GraphQLID
  public var partId: GraphQLID

  public init(studentHomeworkId: GraphQLID, partId: GraphQLID) {
    self.studentHomeworkId = studentHomeworkId
    self.partId = partId
  }

  public var variables: GraphQLMap? {
    return ["studentHomeworkId": studentHomeworkId, "partId": partId]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("questions", arguments: ["partId": GraphQLVariable("partId")], type: .list(.object(Question.selections))),
      GraphQLField("questionRecords", arguments: ["id": GraphQLVariable("studentHomeworkId"), "partId": GraphQLVariable("partId")], type: .list(.object(QuestionRecord.selections))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(questions: [Question?]? = nil, questionRecords: [QuestionRecord?]? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "questions": questions.flatMap { (value: [Question?]) -> [ResultMap?] in value.map { (value: Question?) -> ResultMap? in value.flatMap { (value: Question) -> ResultMap in value.resultMap } } }, "questionRecords": questionRecords.flatMap { (value: [QuestionRecord?]) -> [ResultMap?] in value.map { (value: QuestionRecord?) -> ResultMap? in value.flatMap { (value: QuestionRecord) -> ResultMap in value.resultMap } } }])
    }

    public var questions: [Question?]? {
      get {
        return (resultMap["questions"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Question?] in value.map { (value: ResultMap?) -> Question? in value.flatMap { (value: ResultMap) -> Question in Question(unsafeResultMap: value) } } }
      }
      set {
        resultMap.updateValue(newValue.flatMap { (value: [Question?]) -> [ResultMap?] in value.map { (value: Question?) -> ResultMap? in value.flatMap { (value: Question) -> ResultMap in value.resultMap } } }, forKey: "questions")
      }
    }

    public var questionRecords: [QuestionRecord?]? {
      get {
        return (resultMap["questionRecords"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [QuestionRecord?] in value.map { (value: ResultMap?) -> QuestionRecord? in value.flatMap { (value: ResultMap) -> QuestionRecord in QuestionRecord(unsafeResultMap: value) } } }
      }
      set {
        resultMap.updateValue(newValue.flatMap { (value: [QuestionRecord?]) -> [ResultMap?] in value.map { (value: QuestionRecord?) -> ResultMap? in value.flatMap { (value: QuestionRecord) -> ResultMap in value.resultMap } } }, forKey: "questionRecords")
      }
    }

    public struct Question: GraphQLSelectionSet {
      public static let possibleTypes = ["Question"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("_id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("category", type: .scalar(String.self)),
        GraphQLField("title", type: .scalar(String.self)),
        GraphQLField("q_score", type: .scalar(Int.self)),
        GraphQLField("answer", type: .scalar(String.self)),
        GraphQLField("note", type: .scalar(String.self)),
        GraphQLField("options", type: .list(.scalar(String.self))),
        GraphQLField("pre_title", type: .scalar(String.self)),
        GraphQLField("group", type: .scalar(GraphQLID.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID, category: String? = nil, title: String? = nil, qScore: Int? = nil, answer: String? = nil, note: String? = nil, options: [String?]? = nil, preTitle: String? = nil, group: GraphQLID? = nil) {
        self.init(unsafeResultMap: ["__typename": "Question", "_id": id, "category": category, "title": title, "q_score": qScore, "answer": answer, "note": note, "options": options, "pre_title": preTitle, "group": group])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return resultMap["_id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "_id")
        }
      }

      public var category: String? {
        get {
          return resultMap["category"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "category")
        }
      }

      public var title: String? {
        get {
          return resultMap["title"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "title")
        }
      }

      public var qScore: Int? {
        get {
          return resultMap["q_score"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "q_score")
        }
      }

      public var answer: String? {
        get {
          return resultMap["answer"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "answer")
        }
      }

      public var note: String? {
        get {
          return resultMap["note"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "note")
        }
      }

      public var options: [String?]? {
        get {
          return resultMap["options"] as? [String?]
        }
        set {
          resultMap.updateValue(newValue, forKey: "options")
        }
      }

      public var preTitle: String? {
        get {
          return resultMap["pre_title"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "pre_title")
        }
      }

      public var group: GraphQLID? {
        get {
          return resultMap["group"] as? GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "group")
        }
      }
    }

    public struct QuestionRecord: GraphQLSelectionSet {
      public static let possibleTypes = ["QuestionRecord"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("question", type: .scalar(GraphQLID.self)),
        GraphQLField("answer", type: .scalar(String.self)),
        GraphQLField("score", type: .scalar(Int.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(question: GraphQLID? = nil, answer: String? = nil, score: Int? = nil) {
        self.init(unsafeResultMap: ["__typename": "QuestionRecord", "question": question, "answer": answer, "score": score])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var question: GraphQLID? {
        get {
          return resultMap["question"] as? GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "question")
        }
      }

      public var answer: String? {
        get {
          return resultMap["answer"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "answer")
        }
      }

      public var score: Int? {
        get {
          return resultMap["score"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "score")
        }
      }
    }
  }
}

public final class QuestSubmitStudentHomeworkMutation: GraphQLMutation {
  /// mutation questSubmitStudentHomework($id: ID!, $partId: ID!, $questionRecord: [QuestionRecordInput], $isSubmit: Boolean!, $isSubmitPart: Boolean!) {
  ///   submitStudentHomework(id: $id, input: {partId: $partId, questionRecord: $questionRecord, isSubmit: $isSubmit, isSubmitPart: $isSubmitPart}) {
  ///     __typename
  ///     _id
  ///   }
  /// }
  public let operationDefinition =
    "mutation questSubmitStudentHomework($id: ID!, $partId: ID!, $questionRecord: [QuestionRecordInput], $isSubmit: Boolean!, $isSubmitPart: Boolean!) { submitStudentHomework(id: $id, input: {partId: $partId, questionRecord: $questionRecord, isSubmit: $isSubmit, isSubmitPart: $isSubmitPart}) { __typename _id } }"

  public let operationName = "questSubmitStudentHomework"

  public var id: GraphQLID
  public var partId: GraphQLID
  public var questionRecord: [QuestionRecordInput?]?
  public var isSubmit: Bool
  public var isSubmitPart: Bool

  public init(id: GraphQLID, partId: GraphQLID, questionRecord: [QuestionRecordInput?]? = nil, isSubmit: Bool, isSubmitPart: Bool) {
    self.id = id
    self.partId = partId
    self.questionRecord = questionRecord
    self.isSubmit = isSubmit
    self.isSubmitPart = isSubmitPart
  }

  public var variables: GraphQLMap? {
    return ["id": id, "partId": partId, "questionRecord": questionRecord, "isSubmit": isSubmit, "isSubmitPart": isSubmitPart]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("submitStudentHomework", arguments: ["id": GraphQLVariable("id"), "input": ["partId": GraphQLVariable("partId"), "questionRecord": GraphQLVariable("questionRecord"), "isSubmit": GraphQLVariable("isSubmit"), "isSubmitPart": GraphQLVariable("isSubmitPart")]], type: .object(SubmitStudentHomework.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(submitStudentHomework: SubmitStudentHomework? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "submitStudentHomework": submitStudentHomework.flatMap { (value: SubmitStudentHomework) -> ResultMap in value.resultMap }])
    }

    public var submitStudentHomework: SubmitStudentHomework? {
      get {
        return (resultMap["submitStudentHomework"] as? ResultMap).flatMap { SubmitStudentHomework(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "submitStudentHomework")
      }
    }

    public struct SubmitStudentHomework: GraphQLSelectionSet {
      public static let possibleTypes = ["StudentHomework"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("_id", type: .scalar(GraphQLID.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID? = nil) {
        self.init(unsafeResultMap: ["__typename": "StudentHomework", "_id": id])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID? {
        get {
          return resultMap["_id"] as? GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "_id")
        }
      }
    }
  }
}

public final class GetReportDataQuery: GraphQLQuery {
  /// query getReportData($classroomId: ID!, $studentId: ID!) {
  ///   classroomRank(classroomId: $classroomId) {
  ///     __typename
  ///     _id
  ///     items {
  ///       __typename
  ///       total
  ///       score
  ///       right_exam
  ///       student {
  ///         __typename
  ///         _id
  ///         name
  ///       }
  ///     }
  ///   }
  ///   classroomStudentStat(classroomId: $classroomId, studentId: $studentId) {
  ///     __typename
  ///     _id
  ///     homework_rate
  ///     round_rate
  ///     online_rate
  ///     schedule_stats {
  ///       __typename
  ///       name
  ///       exam_score
  ///       homework_score
  ///       status_round
  ///       status_homework
  ///       status_online
  ///     }
  ///   }
  /// }
  public let operationDefinition =
    "query getReportData($classroomId: ID!, $studentId: ID!) { classroomRank(classroomId: $classroomId) { __typename _id items { __typename total score right_exam student { __typename _id name } } } classroomStudentStat(classroomId: $classroomId, studentId: $studentId) { __typename _id homework_rate round_rate online_rate schedule_stats { __typename name exam_score homework_score status_round status_homework status_online } } }"

  public let operationName = "getReportData"

  public var classroomId: GraphQLID
  public var studentId: GraphQLID

  public init(classroomId: GraphQLID, studentId: GraphQLID) {
    self.classroomId = classroomId
    self.studentId = studentId
  }

  public var variables: GraphQLMap? {
    return ["classroomId": classroomId, "studentId": studentId]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("classroomRank", arguments: ["classroomId": GraphQLVariable("classroomId")], type: .nonNull(.object(ClassroomRank.selections))),
      GraphQLField("classroomStudentStat", arguments: ["classroomId": GraphQLVariable("classroomId"), "studentId": GraphQLVariable("studentId")], type: .object(ClassroomStudentStat.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(classroomRank: ClassroomRank, classroomStudentStat: ClassroomStudentStat? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "classroomRank": classroomRank.resultMap, "classroomStudentStat": classroomStudentStat.flatMap { (value: ClassroomStudentStat) -> ResultMap in value.resultMap }])
    }

    public var classroomRank: ClassroomRank {
      get {
        return ClassroomRank(unsafeResultMap: resultMap["classroomRank"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "classroomRank")
      }
    }

    public var classroomStudentStat: ClassroomStudentStat? {
      get {
        return (resultMap["classroomStudentStat"] as? ResultMap).flatMap { ClassroomStudentStat(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "classroomStudentStat")
      }
    }

    public struct ClassroomRank: GraphQLSelectionSet {
      public static let possibleTypes = ["ClassroomRank"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("_id", type: .scalar(GraphQLID.self)),
        GraphQLField("items", type: .list(.object(Item.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID? = nil, items: [Item?]? = nil) {
        self.init(unsafeResultMap: ["__typename": "ClassroomRank", "_id": id, "items": items.flatMap { (value: [Item?]) -> [ResultMap?] in value.map { (value: Item?) -> ResultMap? in value.flatMap { (value: Item) -> ResultMap in value.resultMap } } }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID? {
        get {
          return resultMap["_id"] as? GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "_id")
        }
      }

      public var items: [Item?]? {
        get {
          return (resultMap["items"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Item?] in value.map { (value: ResultMap?) -> Item? in value.flatMap { (value: ResultMap) -> Item in Item(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Item?]) -> [ResultMap?] in value.map { (value: Item?) -> ResultMap? in value.flatMap { (value: Item) -> ResultMap in value.resultMap } } }, forKey: "items")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["ClassroomRankItem"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("total", type: .scalar(Int.self)),
          GraphQLField("score", type: .scalar(Int.self)),
          GraphQLField("right_exam", type: .scalar(Int.self)),
          GraphQLField("student", type: .object(Student.selections)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(total: Int? = nil, score: Int? = nil, rightExam: Int? = nil, student: Student? = nil) {
          self.init(unsafeResultMap: ["__typename": "ClassroomRankItem", "total": total, "score": score, "right_exam": rightExam, "student": student.flatMap { (value: Student) -> ResultMap in value.resultMap }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var total: Int? {
          get {
            return resultMap["total"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "total")
          }
        }

        public var score: Int? {
          get {
            return resultMap["score"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "score")
          }
        }

        public var rightExam: Int? {
          get {
            return resultMap["right_exam"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "right_exam")
          }
        }

        public var student: Student? {
          get {
            return (resultMap["student"] as? ResultMap).flatMap { Student(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "student")
          }
        }

        public struct Student: GraphQLSelectionSet {
          public static let possibleTypes = ["Student"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("_id", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("name", type: .nonNull(.scalar(String.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(id: GraphQLID, name: String) {
            self.init(unsafeResultMap: ["__typename": "Student", "_id": id, "name": name])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var id: GraphQLID {
            get {
              return resultMap["_id"]! as! GraphQLID
            }
            set {
              resultMap.updateValue(newValue, forKey: "_id")
            }
          }

          public var name: String {
            get {
              return resultMap["name"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "name")
            }
          }
        }
      }
    }

    public struct ClassroomStudentStat: GraphQLSelectionSet {
      public static let possibleTypes = ["StudentStat"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("_id", type: .scalar(GraphQLID.self)),
        GraphQLField("homework_rate", type: .scalar(Double.self)),
        GraphQLField("round_rate", type: .scalar(Double.self)),
        GraphQLField("online_rate", type: .scalar(Double.self)),
        GraphQLField("schedule_stats", type: .list(.object(ScheduleStat.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID? = nil, homeworkRate: Double? = nil, roundRate: Double? = nil, onlineRate: Double? = nil, scheduleStats: [ScheduleStat?]? = nil) {
        self.init(unsafeResultMap: ["__typename": "StudentStat", "_id": id, "homework_rate": homeworkRate, "round_rate": roundRate, "online_rate": onlineRate, "schedule_stats": scheduleStats.flatMap { (value: [ScheduleStat?]) -> [ResultMap?] in value.map { (value: ScheduleStat?) -> ResultMap? in value.flatMap { (value: ScheduleStat) -> ResultMap in value.resultMap } } }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID? {
        get {
          return resultMap["_id"] as? GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "_id")
        }
      }

      public var homeworkRate: Double? {
        get {
          return resultMap["homework_rate"] as? Double
        }
        set {
          resultMap.updateValue(newValue, forKey: "homework_rate")
        }
      }

      public var roundRate: Double? {
        get {
          return resultMap["round_rate"] as? Double
        }
        set {
          resultMap.updateValue(newValue, forKey: "round_rate")
        }
      }

      public var onlineRate: Double? {
        get {
          return resultMap["online_rate"] as? Double
        }
        set {
          resultMap.updateValue(newValue, forKey: "online_rate")
        }
      }

      public var scheduleStats: [ScheduleStat?]? {
        get {
          return (resultMap["schedule_stats"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [ScheduleStat?] in value.map { (value: ResultMap?) -> ScheduleStat? in value.flatMap { (value: ResultMap) -> ScheduleStat in ScheduleStat(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [ScheduleStat?]) -> [ResultMap?] in value.map { (value: ScheduleStat?) -> ResultMap? in value.flatMap { (value: ScheduleStat) -> ResultMap in value.resultMap } } }, forKey: "schedule_stats")
        }
      }

      public struct ScheduleStat: GraphQLSelectionSet {
        public static let possibleTypes = ["ScheduleStat"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .scalar(String.self)),
          GraphQLField("exam_score", type: .scalar(Double.self)),
          GraphQLField("homework_score", type: .scalar(Double.self)),
          GraphQLField("status_round", type: .scalar(Int.self)),
          GraphQLField("status_homework", type: .scalar(Int.self)),
          GraphQLField("status_online", type: .scalar(Int.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(name: String? = nil, examScore: Double? = nil, homeworkScore: Double? = nil, statusRound: Int? = nil, statusHomework: Int? = nil, statusOnline: Int? = nil) {
          self.init(unsafeResultMap: ["__typename": "ScheduleStat", "name": name, "exam_score": examScore, "homework_score": homeworkScore, "status_round": statusRound, "status_homework": statusHomework, "status_online": statusOnline])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var name: String? {
          get {
            return resultMap["name"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "name")
          }
        }

        public var examScore: Double? {
          get {
            return resultMap["exam_score"] as? Double
          }
          set {
            resultMap.updateValue(newValue, forKey: "exam_score")
          }
        }

        public var homeworkScore: Double? {
          get {
            return resultMap["homework_score"] as? Double
          }
          set {
            resultMap.updateValue(newValue, forKey: "homework_score")
          }
        }

        public var statusRound: Int? {
          get {
            return resultMap["status_round"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "status_round")
          }
        }

        public var statusHomework: Int? {
          get {
            return resultMap["status_homework"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "status_homework")
          }
        }

        public var statusOnline: Int? {
          get {
            return resultMap["status_online"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "status_online")
          }
        }
      }
    }
  }
}
