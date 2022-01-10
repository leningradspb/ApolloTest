// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

public final class CustomerLoginOneStepWayMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation CustomerLoginOneStepWay($provider: String!, $secret: String!) {
      oneStepTokenSign(provider: $provider, token: $secret) {
        __typename
        token
      }
    }
    """

  public let operationName: String = "CustomerLoginOneStepWay"

  public var provider: String
  public var secret: String

  public init(provider: String, secret: String) {
    self.provider = provider
    self.secret = secret
  }

  public var variables: GraphQLMap? {
    return ["provider": provider, "secret": secret]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["RootMutationType"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("oneStepTokenSign", arguments: ["provider": GraphQLVariable("provider"), "token": GraphQLVariable("secret")], type: .object(OneStepTokenSign.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(oneStepTokenSign: OneStepTokenSign? = nil) {
      self.init(unsafeResultMap: ["__typename": "RootMutationType", "oneStepTokenSign": oneStepTokenSign.flatMap { (value: OneStepTokenSign) -> ResultMap in value.resultMap }])
    }

    public var oneStepTokenSign: OneStepTokenSign? {
      get {
        return (resultMap["oneStepTokenSign"] as? ResultMap).flatMap { OneStepTokenSign(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "oneStepTokenSign")
      }
    }

    public struct OneStepTokenSign: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["CustomerAndToken"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("token", type: .scalar(String.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(token: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "CustomerAndToken", "token": token])
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
    }
  }
}

public final class ActivityGetQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query ActivityGet($id: ID!) {
      activity(id: $id) {
        __typename
        id
        state
        customer {
          __typename
          id
        }
        operator {
          __typename
          id
        }
        duration
        channelType
        messages {
          __typename
          id
          activityId
          body
          customerId
          operatorId
          insertedAt
          isRead
          sender
          receiver
          attachment {
            __typename
            ext
            original
            preview
            size
            title
            type
          }
        }
        insertedAt
      }
    }
    """

  public let operationName: String = "ActivityGet"

  public var id: GraphQLID

  public init(id: GraphQLID) {
    self.id = id
  }

  public var variables: GraphQLMap? {
    return ["id": id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["RootQueryType"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("activity", arguments: ["id": GraphQLVariable("id")], type: .object(Activity.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(activity: Activity? = nil) {
      self.init(unsafeResultMap: ["__typename": "RootQueryType", "activity": activity.flatMap { (value: Activity) -> ResultMap in value.resultMap }])
    }

    /// Return activity
    public var activity: Activity? {
      get {
        return (resultMap["activity"] as? ResultMap).flatMap { Activity(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "activity")
      }
    }

    public struct Activity: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Activity"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .scalar(GraphQLID.self)),
        GraphQLField("state", type: .scalar(String.self)),
        GraphQLField("customer", type: .object(Customer.selections)),
        GraphQLField("operator", type: .object(Operator.selections)),
        GraphQLField("duration", type: .scalar(Int.self)),
        GraphQLField("channelType", type: .scalar(String.self)),
        GraphQLField("messages", type: .list(.object(Message.selections))),
        GraphQLField("insertedAt", type: .scalar(String.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID? = nil, state: String? = nil, customer: Customer? = nil, `operator`: Operator? = nil, duration: Int? = nil, channelType: String? = nil, messages: [Message?]? = nil, insertedAt: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "Activity", "id": id, "state": state, "customer": customer.flatMap { (value: Customer) -> ResultMap in value.resultMap }, "operator": `operator`.flatMap { (value: Operator) -> ResultMap in value.resultMap }, "duration": duration, "channelType": channelType, "messages": messages.flatMap { (value: [Message?]) -> [ResultMap?] in value.map { (value: Message?) -> ResultMap? in value.flatMap { (value: Message) -> ResultMap in value.resultMap } } }, "insertedAt": insertedAt])
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
          return resultMap["id"] as? GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      public var state: String? {
        get {
          return resultMap["state"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "state")
        }
      }

      public var customer: Customer? {
        get {
          return (resultMap["customer"] as? ResultMap).flatMap { Customer(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "customer")
        }
      }

      public var `operator`: Operator? {
        get {
          return (resultMap["operator"] as? ResultMap).flatMap { Operator(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "operator")
        }
      }

      public var duration: Int? {
        get {
          return resultMap["duration"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "duration")
        }
      }

      public var channelType: String? {
        get {
          return resultMap["channelType"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "channelType")
        }
      }

      public var messages: [Message?]? {
        get {
          return (resultMap["messages"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Message?] in value.map { (value: ResultMap?) -> Message? in value.flatMap { (value: ResultMap) -> Message in Message(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Message?]) -> [ResultMap?] in value.map { (value: Message?) -> ResultMap? in value.flatMap { (value: Message) -> ResultMap in value.resultMap } } }, forKey: "messages")
        }
      }

      public var insertedAt: String? {
        get {
          return resultMap["insertedAt"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "insertedAt")
        }
      }

      public struct Customer: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Customer"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: GraphQLID) {
          self.init(unsafeResultMap: ["__typename": "Customer", "id": id])
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
            return resultMap["id"]! as! GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "id")
          }
        }
      }

      public struct Operator: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["User"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .scalar(GraphQLID.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: GraphQLID? = nil) {
          self.init(unsafeResultMap: ["__typename": "User", "id": id])
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
            return resultMap["id"] as? GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "id")
          }
        }
      }

      public struct Message: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Message"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .scalar(GraphQLID.self)),
          GraphQLField("activityId", type: .scalar(GraphQLID.self)),
          GraphQLField("body", type: .scalar(String.self)),
          GraphQLField("customerId", type: .scalar(GraphQLID.self)),
          GraphQLField("operatorId", type: .scalar(GraphQLID.self)),
          GraphQLField("insertedAt", type: .scalar(String.self)),
          GraphQLField("isRead", type: .scalar(Bool.self)),
          GraphQLField("sender", type: .scalar(String.self)),
          GraphQLField("receiver", type: .scalar(String.self)),
          GraphQLField("attachment", type: .object(Attachment.selections)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: GraphQLID? = nil, activityId: GraphQLID? = nil, body: String? = nil, customerId: GraphQLID? = nil, operatorId: GraphQLID? = nil, insertedAt: String? = nil, isRead: Bool? = nil, sender: String? = nil, receiver: String? = nil, attachment: Attachment? = nil) {
          self.init(unsafeResultMap: ["__typename": "Message", "id": id, "activityId": activityId, "body": body, "customerId": customerId, "operatorId": operatorId, "insertedAt": insertedAt, "isRead": isRead, "sender": sender, "receiver": receiver, "attachment": attachment.flatMap { (value: Attachment) -> ResultMap in value.resultMap }])
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
            return resultMap["id"] as? GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "id")
          }
        }

        public var activityId: GraphQLID? {
          get {
            return resultMap["activityId"] as? GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "activityId")
          }
        }

        public var body: String? {
          get {
            return resultMap["body"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "body")
          }
        }

        public var customerId: GraphQLID? {
          get {
            return resultMap["customerId"] as? GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "customerId")
          }
        }

        public var operatorId: GraphQLID? {
          get {
            return resultMap["operatorId"] as? GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "operatorId")
          }
        }

        public var insertedAt: String? {
          get {
            return resultMap["insertedAt"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "insertedAt")
          }
        }

        public var isRead: Bool? {
          get {
            return resultMap["isRead"] as? Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "isRead")
          }
        }

        public var sender: String? {
          get {
            return resultMap["sender"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "sender")
          }
        }

        public var receiver: String? {
          get {
            return resultMap["receiver"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "receiver")
          }
        }

        public var attachment: Attachment? {
          get {
            return (resultMap["attachment"] as? ResultMap).flatMap { Attachment(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "attachment")
          }
        }

        public struct Attachment: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Attachment"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("ext", type: .scalar(String.self)),
            GraphQLField("original", type: .scalar(String.self)),
            GraphQLField("preview", type: .scalar(String.self)),
            GraphQLField("size", type: .scalar(Int.self)),
            GraphQLField("title", type: .scalar(String.self)),
            GraphQLField("type", type: .scalar(String.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(ext: String? = nil, original: String? = nil, preview: String? = nil, size: Int? = nil, title: String? = nil, type: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "Attachment", "ext": ext, "original": original, "preview": preview, "size": size, "title": title, "type": type])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var ext: String? {
            get {
              return resultMap["ext"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "ext")
            }
          }

          public var original: String? {
            get {
              return resultMap["original"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "original")
            }
          }

          public var preview: String? {
            get {
              return resultMap["preview"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "preview")
            }
          }

          public var size: Int? {
            get {
              return resultMap["size"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "size")
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

          public var type: String? {
            get {
              return resultMap["type"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "type")
            }
          }
        }
      }
    }
  }
}

public final class ActivityCreateByFirstMessageMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation ActivityCreateByFirstMessage($channelIdentifier: String!, $message: String!) {
      activityByFirstMessage(channelIdentifier: $channelIdentifier, text: $message) {
        __typename
        id
        state
        customer {
          __typename
          id
        }
        operator {
          __typename
          id
        }
        duration
        channelType
        messages {
          __typename
          id
          activityId
          body
          customerId
          operatorId
          insertedAt
          isRead
          sender
          receiver
          attachment {
            __typename
            ext
            original
            preview
            size
            title
            type
          }
        }
        insertedAt
      }
    }
    """

  public let operationName: String = "ActivityCreateByFirstMessage"

  public var channelIdentifier: String
  public var message: String

  public init(channelIdentifier: String, message: String) {
    self.channelIdentifier = channelIdentifier
    self.message = message
  }

  public var variables: GraphQLMap? {
    return ["channelIdentifier": channelIdentifier, "message": message]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["RootMutationType"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("activityByFirstMessage", arguments: ["channelIdentifier": GraphQLVariable("channelIdentifier"), "text": GraphQLVariable("message")], type: .object(ActivityByFirstMessage.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(activityByFirstMessage: ActivityByFirstMessage? = nil) {
      self.init(unsafeResultMap: ["__typename": "RootMutationType", "activityByFirstMessage": activityByFirstMessage.flatMap { (value: ActivityByFirstMessage) -> ResultMap in value.resultMap }])
    }

    /// Create an activity by message
    public var activityByFirstMessage: ActivityByFirstMessage? {
      get {
        return (resultMap["activityByFirstMessage"] as? ResultMap).flatMap { ActivityByFirstMessage(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "activityByFirstMessage")
      }
    }

    public struct ActivityByFirstMessage: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Activity"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .scalar(GraphQLID.self)),
        GraphQLField("state", type: .scalar(String.self)),
        GraphQLField("customer", type: .object(Customer.selections)),
        GraphQLField("operator", type: .object(Operator.selections)),
        GraphQLField("duration", type: .scalar(Int.self)),
        GraphQLField("channelType", type: .scalar(String.self)),
        GraphQLField("messages", type: .list(.object(Message.selections))),
        GraphQLField("insertedAt", type: .scalar(String.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID? = nil, state: String? = nil, customer: Customer? = nil, `operator`: Operator? = nil, duration: Int? = nil, channelType: String? = nil, messages: [Message?]? = nil, insertedAt: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "Activity", "id": id, "state": state, "customer": customer.flatMap { (value: Customer) -> ResultMap in value.resultMap }, "operator": `operator`.flatMap { (value: Operator) -> ResultMap in value.resultMap }, "duration": duration, "channelType": channelType, "messages": messages.flatMap { (value: [Message?]) -> [ResultMap?] in value.map { (value: Message?) -> ResultMap? in value.flatMap { (value: Message) -> ResultMap in value.resultMap } } }, "insertedAt": insertedAt])
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
          return resultMap["id"] as? GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      public var state: String? {
        get {
          return resultMap["state"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "state")
        }
      }

      public var customer: Customer? {
        get {
          return (resultMap["customer"] as? ResultMap).flatMap { Customer(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "customer")
        }
      }

      public var `operator`: Operator? {
        get {
          return (resultMap["operator"] as? ResultMap).flatMap { Operator(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "operator")
        }
      }

      public var duration: Int? {
        get {
          return resultMap["duration"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "duration")
        }
      }

      public var channelType: String? {
        get {
          return resultMap["channelType"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "channelType")
        }
      }

      public var messages: [Message?]? {
        get {
          return (resultMap["messages"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Message?] in value.map { (value: ResultMap?) -> Message? in value.flatMap { (value: ResultMap) -> Message in Message(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Message?]) -> [ResultMap?] in value.map { (value: Message?) -> ResultMap? in value.flatMap { (value: Message) -> ResultMap in value.resultMap } } }, forKey: "messages")
        }
      }

      public var insertedAt: String? {
        get {
          return resultMap["insertedAt"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "insertedAt")
        }
      }

      public struct Customer: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Customer"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: GraphQLID) {
          self.init(unsafeResultMap: ["__typename": "Customer", "id": id])
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
            return resultMap["id"]! as! GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "id")
          }
        }
      }

      public struct Operator: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["User"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .scalar(GraphQLID.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: GraphQLID? = nil) {
          self.init(unsafeResultMap: ["__typename": "User", "id": id])
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
            return resultMap["id"] as? GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "id")
          }
        }
      }

      public struct Message: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Message"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .scalar(GraphQLID.self)),
          GraphQLField("activityId", type: .scalar(GraphQLID.self)),
          GraphQLField("body", type: .scalar(String.self)),
          GraphQLField("customerId", type: .scalar(GraphQLID.self)),
          GraphQLField("operatorId", type: .scalar(GraphQLID.self)),
          GraphQLField("insertedAt", type: .scalar(String.self)),
          GraphQLField("isRead", type: .scalar(Bool.self)),
          GraphQLField("sender", type: .scalar(String.self)),
          GraphQLField("receiver", type: .scalar(String.self)),
          GraphQLField("attachment", type: .object(Attachment.selections)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: GraphQLID? = nil, activityId: GraphQLID? = nil, body: String? = nil, customerId: GraphQLID? = nil, operatorId: GraphQLID? = nil, insertedAt: String? = nil, isRead: Bool? = nil, sender: String? = nil, receiver: String? = nil, attachment: Attachment? = nil) {
          self.init(unsafeResultMap: ["__typename": "Message", "id": id, "activityId": activityId, "body": body, "customerId": customerId, "operatorId": operatorId, "insertedAt": insertedAt, "isRead": isRead, "sender": sender, "receiver": receiver, "attachment": attachment.flatMap { (value: Attachment) -> ResultMap in value.resultMap }])
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
            return resultMap["id"] as? GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "id")
          }
        }

        public var activityId: GraphQLID? {
          get {
            return resultMap["activityId"] as? GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "activityId")
          }
        }

        public var body: String? {
          get {
            return resultMap["body"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "body")
          }
        }

        public var customerId: GraphQLID? {
          get {
            return resultMap["customerId"] as? GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "customerId")
          }
        }

        public var operatorId: GraphQLID? {
          get {
            return resultMap["operatorId"] as? GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "operatorId")
          }
        }

        public var insertedAt: String? {
          get {
            return resultMap["insertedAt"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "insertedAt")
          }
        }

        public var isRead: Bool? {
          get {
            return resultMap["isRead"] as? Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "isRead")
          }
        }

        public var sender: String? {
          get {
            return resultMap["sender"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "sender")
          }
        }

        public var receiver: String? {
          get {
            return resultMap["receiver"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "receiver")
          }
        }

        public var attachment: Attachment? {
          get {
            return (resultMap["attachment"] as? ResultMap).flatMap { Attachment(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "attachment")
          }
        }

        public struct Attachment: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Attachment"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("ext", type: .scalar(String.self)),
            GraphQLField("original", type: .scalar(String.self)),
            GraphQLField("preview", type: .scalar(String.self)),
            GraphQLField("size", type: .scalar(Int.self)),
            GraphQLField("title", type: .scalar(String.self)),
            GraphQLField("type", type: .scalar(String.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(ext: String? = nil, original: String? = nil, preview: String? = nil, size: Int? = nil, title: String? = nil, type: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "Attachment", "ext": ext, "original": original, "preview": preview, "size": size, "title": title, "type": type])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var ext: String? {
            get {
              return resultMap["ext"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "ext")
            }
          }

          public var original: String? {
            get {
              return resultMap["original"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "original")
            }
          }

          public var preview: String? {
            get {
              return resultMap["preview"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "preview")
            }
          }

          public var size: Int? {
            get {
              return resultMap["size"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "size")
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

          public var type: String? {
            get {
              return resultMap["type"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "type")
            }
          }
        }
      }
    }
  }
}

public final class MessagesFeedQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query MessagesFeed($cursor: ID, $limit: Int) {
      messagesFeed(cursor: $cursor, limit: $limit) {
        __typename
        messages {
          __typename
          id
          activityId
          body
          customerId
          operatorId
          insertedAt
          isRead
          sender
          receiver
          attachment {
            __typename
            ext
            original
            preview
            size
            title
            type
          }
        }
        pageInfo {
          __typename
          cursor
          hasNextPage
        }
      }
    }
    """

  public let operationName: String = "MessagesFeed"

  public var cursor: GraphQLID?
  public var limit: Int?

  public init(cursor: GraphQLID? = nil, limit: Int? = nil) {
    self.cursor = cursor
    self.limit = limit
  }

  public var variables: GraphQLMap? {
    return ["cursor": cursor, "limit": limit]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["RootQueryType"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("messagesFeed", arguments: ["cursor": GraphQLVariable("cursor"), "limit": GraphQLVariable("limit")], type: .object(MessagesFeed.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(messagesFeed: MessagesFeed? = nil) {
      self.init(unsafeResultMap: ["__typename": "RootQueryType", "messagesFeed": messagesFeed.flatMap { (value: MessagesFeed) -> ResultMap in value.resultMap }])
    }

    /// Messages feed for customer
    public var messagesFeed: MessagesFeed? {
      get {
        return (resultMap["messagesFeed"] as? ResultMap).flatMap { MessagesFeed(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "messagesFeed")
      }
    }

    public struct MessagesFeed: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["MessageFeed"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("messages", type: .list(.object(Message.selections))),
        GraphQLField("pageInfo", type: .object(PageInfo.selections)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(messages: [Message?]? = nil, pageInfo: PageInfo? = nil) {
        self.init(unsafeResultMap: ["__typename": "MessageFeed", "messages": messages.flatMap { (value: [Message?]) -> [ResultMap?] in value.map { (value: Message?) -> ResultMap? in value.flatMap { (value: Message) -> ResultMap in value.resultMap } } }, "pageInfo": pageInfo.flatMap { (value: PageInfo) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var messages: [Message?]? {
        get {
          return (resultMap["messages"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Message?] in value.map { (value: ResultMap?) -> Message? in value.flatMap { (value: ResultMap) -> Message in Message(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Message?]) -> [ResultMap?] in value.map { (value: Message?) -> ResultMap? in value.flatMap { (value: Message) -> ResultMap in value.resultMap } } }, forKey: "messages")
        }
      }

      public var pageInfo: PageInfo? {
        get {
          return (resultMap["pageInfo"] as? ResultMap).flatMap { PageInfo(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "pageInfo")
        }
      }

      public struct Message: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Message"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .scalar(GraphQLID.self)),
          GraphQLField("activityId", type: .scalar(GraphQLID.self)),
          GraphQLField("body", type: .scalar(String.self)),
          GraphQLField("customerId", type: .scalar(GraphQLID.self)),
          GraphQLField("operatorId", type: .scalar(GraphQLID.self)),
          GraphQLField("insertedAt", type: .scalar(String.self)),
          GraphQLField("isRead", type: .scalar(Bool.self)),
          GraphQLField("sender", type: .scalar(String.self)),
          GraphQLField("receiver", type: .scalar(String.self)),
          GraphQLField("attachment", type: .object(Attachment.selections)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: GraphQLID? = nil, activityId: GraphQLID? = nil, body: String? = nil, customerId: GraphQLID? = nil, operatorId: GraphQLID? = nil, insertedAt: String? = nil, isRead: Bool? = nil, sender: String? = nil, receiver: String? = nil, attachment: Attachment? = nil) {
          self.init(unsafeResultMap: ["__typename": "Message", "id": id, "activityId": activityId, "body": body, "customerId": customerId, "operatorId": operatorId, "insertedAt": insertedAt, "isRead": isRead, "sender": sender, "receiver": receiver, "attachment": attachment.flatMap { (value: Attachment) -> ResultMap in value.resultMap }])
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
            return resultMap["id"] as? GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "id")
          }
        }

        public var activityId: GraphQLID? {
          get {
            return resultMap["activityId"] as? GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "activityId")
          }
        }

        public var body: String? {
          get {
            return resultMap["body"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "body")
          }
        }

        public var customerId: GraphQLID? {
          get {
            return resultMap["customerId"] as? GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "customerId")
          }
        }

        public var operatorId: GraphQLID? {
          get {
            return resultMap["operatorId"] as? GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "operatorId")
          }
        }

        public var insertedAt: String? {
          get {
            return resultMap["insertedAt"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "insertedAt")
          }
        }

        public var isRead: Bool? {
          get {
            return resultMap["isRead"] as? Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "isRead")
          }
        }

        public var sender: String? {
          get {
            return resultMap["sender"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "sender")
          }
        }

        public var receiver: String? {
          get {
            return resultMap["receiver"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "receiver")
          }
        }

        public var attachment: Attachment? {
          get {
            return (resultMap["attachment"] as? ResultMap).flatMap { Attachment(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "attachment")
          }
        }

        public struct Attachment: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Attachment"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("ext", type: .scalar(String.self)),
            GraphQLField("original", type: .scalar(String.self)),
            GraphQLField("preview", type: .scalar(String.self)),
            GraphQLField("size", type: .scalar(Int.self)),
            GraphQLField("title", type: .scalar(String.self)),
            GraphQLField("type", type: .scalar(String.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(ext: String? = nil, original: String? = nil, preview: String? = nil, size: Int? = nil, title: String? = nil, type: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "Attachment", "ext": ext, "original": original, "preview": preview, "size": size, "title": title, "type": type])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var ext: String? {
            get {
              return resultMap["ext"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "ext")
            }
          }

          public var original: String? {
            get {
              return resultMap["original"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "original")
            }
          }

          public var preview: String? {
            get {
              return resultMap["preview"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "preview")
            }
          }

          public var size: Int? {
            get {
              return resultMap["size"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "size")
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

          public var type: String? {
            get {
              return resultMap["type"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "type")
            }
          }
        }
      }

      public struct PageInfo: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["PageInfo"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("cursor", type: .scalar(String.self)),
          GraphQLField("hasNextPage", type: .scalar(Bool.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(cursor: String? = nil, hasNextPage: Bool? = nil) {
          self.init(unsafeResultMap: ["__typename": "PageInfo", "cursor": cursor, "hasNextPage": hasNextPage])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var cursor: String? {
          get {
            return resultMap["cursor"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "cursor")
          }
        }

        public var hasNextPage: Bool? {
          get {
            return resultMap["hasNextPage"] as? Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "hasNextPage")
          }
        }
      }
    }
  }
}

public final class FirstMessagesFeedQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query FirstMessagesFeed($limit: Int) {
      messagesFeed(limit: $limit) {
        __typename
        messages {
          __typename
          id
          activityId
          body
          customerId
          operatorId
          insertedAt
          isRead
          sender
          receiver
          attachment {
            __typename
            ext
            original
            preview
            size
            title
            type
          }
        }
        pageInfo {
          __typename
          cursor
          hasNextPage
        }
      }
    }
    """

  public let operationName: String = "FirstMessagesFeed"

  public var limit: Int?

  public init(limit: Int? = nil) {
    self.limit = limit
  }

  public var variables: GraphQLMap? {
    return ["limit": limit]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["RootQueryType"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("messagesFeed", arguments: ["limit": GraphQLVariable("limit")], type: .object(MessagesFeed.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(messagesFeed: MessagesFeed? = nil) {
      self.init(unsafeResultMap: ["__typename": "RootQueryType", "messagesFeed": messagesFeed.flatMap { (value: MessagesFeed) -> ResultMap in value.resultMap }])
    }

    /// Messages feed for customer
    public var messagesFeed: MessagesFeed? {
      get {
        return (resultMap["messagesFeed"] as? ResultMap).flatMap { MessagesFeed(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "messagesFeed")
      }
    }

    public struct MessagesFeed: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["MessageFeed"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("messages", type: .list(.object(Message.selections))),
        GraphQLField("pageInfo", type: .object(PageInfo.selections)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(messages: [Message?]? = nil, pageInfo: PageInfo? = nil) {
        self.init(unsafeResultMap: ["__typename": "MessageFeed", "messages": messages.flatMap { (value: [Message?]) -> [ResultMap?] in value.map { (value: Message?) -> ResultMap? in value.flatMap { (value: Message) -> ResultMap in value.resultMap } } }, "pageInfo": pageInfo.flatMap { (value: PageInfo) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var messages: [Message?]? {
        get {
          return (resultMap["messages"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Message?] in value.map { (value: ResultMap?) -> Message? in value.flatMap { (value: ResultMap) -> Message in Message(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Message?]) -> [ResultMap?] in value.map { (value: Message?) -> ResultMap? in value.flatMap { (value: Message) -> ResultMap in value.resultMap } } }, forKey: "messages")
        }
      }

      public var pageInfo: PageInfo? {
        get {
          return (resultMap["pageInfo"] as? ResultMap).flatMap { PageInfo(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "pageInfo")
        }
      }

      public struct Message: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Message"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .scalar(GraphQLID.self)),
          GraphQLField("activityId", type: .scalar(GraphQLID.self)),
          GraphQLField("body", type: .scalar(String.self)),
          GraphQLField("customerId", type: .scalar(GraphQLID.self)),
          GraphQLField("operatorId", type: .scalar(GraphQLID.self)),
          GraphQLField("insertedAt", type: .scalar(String.self)),
          GraphQLField("isRead", type: .scalar(Bool.self)),
          GraphQLField("sender", type: .scalar(String.self)),
          GraphQLField("receiver", type: .scalar(String.self)),
          GraphQLField("attachment", type: .object(Attachment.selections)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: GraphQLID? = nil, activityId: GraphQLID? = nil, body: String? = nil, customerId: GraphQLID? = nil, operatorId: GraphQLID? = nil, insertedAt: String? = nil, isRead: Bool? = nil, sender: String? = nil, receiver: String? = nil, attachment: Attachment? = nil) {
          self.init(unsafeResultMap: ["__typename": "Message", "id": id, "activityId": activityId, "body": body, "customerId": customerId, "operatorId": operatorId, "insertedAt": insertedAt, "isRead": isRead, "sender": sender, "receiver": receiver, "attachment": attachment.flatMap { (value: Attachment) -> ResultMap in value.resultMap }])
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
            return resultMap["id"] as? GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "id")
          }
        }

        public var activityId: GraphQLID? {
          get {
            return resultMap["activityId"] as? GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "activityId")
          }
        }

        public var body: String? {
          get {
            return resultMap["body"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "body")
          }
        }

        public var customerId: GraphQLID? {
          get {
            return resultMap["customerId"] as? GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "customerId")
          }
        }

        public var operatorId: GraphQLID? {
          get {
            return resultMap["operatorId"] as? GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "operatorId")
          }
        }

        public var insertedAt: String? {
          get {
            return resultMap["insertedAt"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "insertedAt")
          }
        }

        public var isRead: Bool? {
          get {
            return resultMap["isRead"] as? Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "isRead")
          }
        }

        public var sender: String? {
          get {
            return resultMap["sender"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "sender")
          }
        }

        public var receiver: String? {
          get {
            return resultMap["receiver"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "receiver")
          }
        }

        public var attachment: Attachment? {
          get {
            return (resultMap["attachment"] as? ResultMap).flatMap { Attachment(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "attachment")
          }
        }

        public struct Attachment: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Attachment"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("ext", type: .scalar(String.self)),
            GraphQLField("original", type: .scalar(String.self)),
            GraphQLField("preview", type: .scalar(String.self)),
            GraphQLField("size", type: .scalar(Int.self)),
            GraphQLField("title", type: .scalar(String.self)),
            GraphQLField("type", type: .scalar(String.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(ext: String? = nil, original: String? = nil, preview: String? = nil, size: Int? = nil, title: String? = nil, type: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "Attachment", "ext": ext, "original": original, "preview": preview, "size": size, "title": title, "type": type])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var ext: String? {
            get {
              return resultMap["ext"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "ext")
            }
          }

          public var original: String? {
            get {
              return resultMap["original"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "original")
            }
          }

          public var preview: String? {
            get {
              return resultMap["preview"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "preview")
            }
          }

          public var size: Int? {
            get {
              return resultMap["size"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "size")
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

          public var type: String? {
            get {
              return resultMap["type"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "type")
            }
          }
        }
      }

      public struct PageInfo: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["PageInfo"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("cursor", type: .scalar(String.self)),
          GraphQLField("hasNextPage", type: .scalar(Bool.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(cursor: String? = nil, hasNextPage: Bool? = nil) {
          self.init(unsafeResultMap: ["__typename": "PageInfo", "cursor": cursor, "hasNextPage": hasNextPage])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var cursor: String? {
          get {
            return resultMap["cursor"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "cursor")
          }
        }

        public var hasNextPage: Bool? {
          get {
            return resultMap["hasNextPage"] as? Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "hasNextPage")
          }
        }
      }
    }
  }
}
