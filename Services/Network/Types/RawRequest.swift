import Foundation
import Combine

protocol RawRequest : Encodable {
    associatedtype Response : Codable //TODO: rename to IntermediateResponse
    associatedtype TransformedResponse : Codable //TODO: rename to Response
    
    var ignoresEndpoint : Bool { get }
    var ignoresAuthHeader : Bool { get }
    var ignoresPercentEncoding : Bool { get }
    var path : String { get }
    var method : RequestMethod { get }
    var data : [String : Any] { get }
    var dateFormatter : DateFormatter { get }
    var customHeaders : [String : String] { get }
    var customQueries : [String : String] { get }

    func transform(_ publisher : AnyPublisher<Response, Error>) throws -> AnyPublisher<TransformedResponse, Error>
}

extension RawRequest {
    
    var ignoresEndpoint : Bool {
        false
    }
    
    var ignoresAuthHeader : Bool {
        false
    }
    
    var ignoresPercentEncoding : Bool {
        false
    }
    
    var data : [String : Any] {
        let coder = DictionaryEncoder()
        return (try? coder.encode(self)) ?? [:]
    }
    
    var dateFormatter: DateFormatter {
        .init()
    }
    
    var customHeaders: [String : String] {
        [:]
    }
    
    var customQueries: [String : String] {
        [:]
    }
}

extension RawRequest where TransformedResponse == Response {
    
    func transform(_ publisher : AnyPublisher<Response, Error>) throws -> AnyPublisher<TransformedResponse, Error> {
        publisher
    }
    
}

//MARK: OLD

public protocol Archiveable: Codable {}
extension Archiveable {
    public var archived: Data? {
        let encoder = JSONEncoder()
        do {
            return try encoder.encode(self)
        } catch let error {
            return nil
        }
    }
}

extension Data {
    public func decodeNetwork<T: NetworkResponseData>(type: T.Type, decoder: JSONDecoder? = nil) -> T? {
        
        var result: T?
            do {
                try autoreleasepool {
                    result = try (decoder ?? JSONDecoder()).decode(T.self, from: self)
                }
            } catch let error {
                result = nil
            }
        
        return result
    }
}


public protocol NetworkResponseData: Archiveable {
    var rawData: Data? { get set }
}

extension NetworkResponseData {
    public var rawData: Data? {
        get { nil }
        set {}
    }
}

