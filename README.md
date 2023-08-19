# Generic URLSession Request

### 1. Defining Network Tasks

In the URLSession Framework, you define your network tasks by conforming to the **`NetworkTask`** protocol. This protocol defines properties that encapsulate essential details about the network request you want to make.

- **`baseURL`**: Specify the base URL of the API you're interacting with. It provides the foundation for constructing the complete URL for the request.
- **`path`**: Define the specific path or endpoint that you want to access on top of the base URL. This helps create the complete URL for your request.
- **`method`**: Choose the HTTP method you want to use for the request, such as **GET**, **POST**, **PUT**, etc.
- **`params`**: Provide any parameters that you need to include in the request. This could be query parameters, request body parameters, or any other necessary data.
- **`encoding`**: Specify the encoding method to use for the parameters. You can choose between **queryString** for URL encoding or **body** for sending data in the request body.
- **`headers`**: Include any custom headers you want to attach to the request. This is useful for sending authorization tokens, content types, or other headers required by the API.

```swift
enum MyNetworkTask: NetworkTask {
    case getItems
    case postItem(parameters: [String: Any])

    var baseURL: NetworkBaseURL {
        switch self {
            case .getItems, .postItem:
                return .url(URL(string: "https://api.example.com")!)
        }
    }

    var path: String {
        switch self {
            case .getItems:
                return "/items"
            case .postItem:
                return "/create"
        }
    }

    var method: NetworkMethod {
        switch self {
            case .getItems:
                return .get
            case .postItem:
                return .post
        }
    }

    var params: [String: Any] {
        switch self {
            case .getItems:
                return [:]
            case .postItem(let parameters):
                return parameters
        }
    }

    var encoding: EncodingMethod {
        switch self {
            case .getItems:
                return .queryString
            case .postItem:
                return .body
        }
    }

    var headers: [String: String]? {
        return nil // Add headers if needed
    }
}
```

### **2. Creating Network Requests**

Use the **`NetworkManager`** class to create and handle network requests. The **`NetworkManager`** offers methods to perform requests, handle responses, and more.

```swift
let networkManager = NetworkManager<MyNetworkTask>()

networkManager.request(
    .getItems, // Use the enum case to specify the network task
    map: MyResponseModel.self, // Replace with your response model
    session: URLSession.shared,
    onLoading: { isLoading in
        // Handle loading state
    },
    onSuccess: { response in
        // Handle successful response
    },
    onError: { error in
        // Handle error
    },
    onMapError: { data in
        // Handle mapping error
    }
)
```

With the **`enum`** implementation for **`MyNetworkTask`**, each case of the enum represents a different network task configuration, making it easier to manage and create network requests using the **`NetworkManager`** class.
