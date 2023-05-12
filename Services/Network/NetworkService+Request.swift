import Foundation
import Combine

extension NetworkService {
    
    func request<R : Request>(_ request : R,
                              options : RequestOptions = .init(),
                              progress : Progress? = nil) -> AnyPublisher<R.TransformedResponse, Error> {
        // Checking if we should return mocked data right away.
  
        guard state.shouldUseMockData == false && options.useMockData == false else {
            return makeMockedResponse(for: request)
        }
      
        return makeUrlComponents(for: request)
            .flatMap { makeURLRequest(from: request, components: $0) }
            .flatMap { executeURLRequest(request, urlRequest: $0, progress: progress) }
            .flatMap { decodeURLResponse(request, urlResult: $0) }
            .receive(on: DispatchQueue.global(qos: .utility))
            .tryCatch { try handleErrors(request, options: options, error: $0) }
            .eraseToAnyPublisher()
    }
    
}

extension NetworkService {
    
    fileprivate func makeMockedResponse<R : Request>(for request : R) -> AnyPublisher<R.TransformedResponse, Error> {
        if let mockedRequest = request as? AnyMockedRequest,
           let mockedResponse = mockedRequest.rawMockedResponse as? R.TransformedResponse {
            // If we have mocked request, we just return the data provided
            // by the type right away.
            
            return Just(mockedResponse)
                .delay(for: .seconds(0.5), scheduler: RunLoop.main)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        else if R.Response.self == EmptyResponse.self {
            //For empty response, we always return empty response as a mocked one
            
            return Just(EmptyResponse() as! R.TransformedResponse)
                .delay(for: .seconds(0.2), scheduler: RunLoop.main)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        else {
            // Otherwise we just return an empty publisher which actually
            // never fires.
            
            return PassthroughSubject<R.TransformedResponse, Error>()
                .eraseToAnyPublisher()
        }
    }
    
}

extension NetworkService {
    
    fileprivate func checkAuthenticationStatus<R : Request>(for request : R) -> AnyPublisher<Void, Error> {
        Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
}

extension NetworkService {
    
    fileprivate func makeUrlComponents<R : Request>(for request : R) -> AnyPublisher<URLComponents, Error> {
        // Resolving URL for the specified request.
        // Firstly we need to encode it and obtain its components.
        
        let urlString = "\(request.ignoresEndpoint == false ? configuration.endpoint : "")\(request.path)"
        
        guard let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed),
              let url = URL(string: encodedString),
              var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            // If we cannot resolve the URL, we gracefully return the error
            // which will propagate downstream.
            
            return Fail(error: NetworkError.invalidRequestUrl)
                .eraseToAnyPublisher()
        }
        
        // Now we need to modify our URL components to include parameters for requests
        // that don't contain body
        if request.method == .get || request.method == .delete {
            var items: [URLQueryItem] = []
            
            var data = request.data
            
            if let paginationData = data["pagination"] as? [String : Any] {

                for (key, value) in paginationData {
                    data[key] = value
                }
                
                data["pagination"] = nil
            }
            
            for (name, value) in data {
                if let array = value as? [String] {
                    items.append(contentsOf: array.map({ value in
                        URLQueryItem(name: name + "[]", value: "\(value)")
                    }))
                } else if type(of: value) == type(of: NSNumber(value: true)), let boolean = value as? Bool {
                    items.append(URLQueryItem(name: name, value: boolean == true ? "true" : "false"))
                } else {
                    items.append(URLQueryItem(name: name, value: "\(value)"))
                }
            }
            
            for (name, value) in request.customQueries {
                items.append(.init(name: name, value: value))
            }

            components.queryItems = items
        }
    
        // If we can construct the URL, we can just return its components.
        return Just(components)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
}

extension NetworkService {
    
    fileprivate func makeURLRequest<R : Request>(from request : R, components : URLComponents) -> AnyPublisher<URLRequest, Error> {
        var urlRequest = URLRequest(
            url: components.url!,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0)
        
        //TODO: additional auth headers maybe?
        
        //TODO: create String enum for header field types and use rawValue
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        for (name, value) in request.customHeaders {
            urlRequest.addValue(value, forHTTPHeaderField: name)
        }
        
        urlRequest.httpMethod = request.method.rawValue.uppercased()
        
        //TODO: make the auth setup reusable
//        let username = "general_read"
//        let password = "Qw3rtyu!"
//        let loginString = String(format: "%@:%@", username, password)
//        if let loginData = loginString.data(using: String.Encoding.utf8) {
//            let base64LoginString = loginData.base64EncodedString()
//            urlRequest.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
//        }
//
//        do {
//            let jsonData = try JSONSerialization.data(withJSONObject: request.data, options: .prettyPrinted)
//            // here "jsonData" is the dictionary encoded in JSON data
//
//            urlRequest.httpBody = jsonData
//
//        } catch {
//            print(error.localizedDescription)
//        }
        
        
        return Just(urlRequest)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
}

extension NetworkService {
    
    typealias URLRequestExecutionResult = (data : Data, response : URLResponse)
    
    fileprivate func executeURLRequest<R : Request>(_ request : R,
                                        urlRequest : URLRequest,
                                        progress : Progress? = nil) -> AnyPublisher<URLRequestExecutionResult, Error> {
        // Executing a request means firing it using the underlying
        // URLSession method. We use the bare URLSession method, but
        // not their Combine method because we need access to seeing the
        // progress of the request.
        
        Deferred {
            Future<URLRequestExecutionResult, Error> { fulfill in
                let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                    if let error = error {
                        fulfill(.failure(error))
                    } else if let data = data, let response = response {
                        let result = (data: data, response: response)
                        fulfill(.success(result))
                    }
                }
                
                progress?.addChild(task.progress, withPendingUnitCount: 100)
                
                print("[NetworkService] Sending request: \(R.self) w/ \(String(describing: urlRequest.url))")
                
                task.resume()
            }
        }.eraseToAnyPublisher()
    }
    
}

extension NetworkService {
    
    fileprivate func decodeURLResponse<R : Request>(_ request : R,
                                        urlResult : URLRequestExecutionResult) -> AnyPublisher<R.TransformedResponse, Error> {
        do {
            if let response = urlResult.response as? HTTPURLResponse {
                var headers = [String : String]()
                
                for (name, value) in response.allHeaderFields {
                    guard let name = name as? String else {
                        continue
                    }
                    
                    headers[name] = value as? String
                }
                
                center.state.headers = headers
            }
            
            //print(urlResult.data)
            
            let decoder = JSONDecoder()
            decoder.dataDecodingStrategy = .base64
            decoder.keyDecodingStrategy = .useDefaultKeys
            decoder.nonConformingFloatDecodingStrategy = .convertFromString(positiveInfinity: "+∞", negativeInfinity: "-∞", nan: "NaN")
            
            let intermediateResponse = Just(try decoder.decode(R.Response.self, from: urlResult.data))
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
            
            return try request.transform(intermediateResponse)
        }
        catch let error {
            print("[NetworkService] Generic error: \(error.localizedDescription)")
            
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
    
}

extension NetworkService {
    
    fileprivate func handleErrors<R : Request>(_ request : R, options : RequestOptions, error : Error) throws -> AnyPublisher<R.TransformedResponse, Error> {
        if options.shouldSupressErrors == false && options.useMockData == false {
            //TODO: make modal testable via services call
            //services.modal.presentErrorToast(error: error)
            print("[NetworkService] Error: \(error.localizedDescription)")
        }
        
        print("[NetworkService] Unauthorized access to the endpoint.")
        
        throw error
    }
    
}
