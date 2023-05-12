import Foundation
import Granite

extension NetworkService {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var headers = [String : String]()
            var shouldUseMockData: Bool = false
        }
        
        @Store public var state: State
    }
    
    fileprivate enum BaseEndpoint : String {
        case global = "9hjcy5mm7a.execute-api.us-east-1.amazonaws.com/basic"
    }
    
    struct Configuration: Codable {
        
        var endpoint : String {
            var path = "https://"
            
            path += BaseEndpoint.global.rawValue
            
            return path + "/"
        }
    }
    
    enum NetworkError: LocalizedError {
        case invalidRequestUrl
        case invalidResponse
        case unauthorized
        case backend(ErrorResponse)
        
        var errorDescription: String? {
            switch self {
            
            case .invalidRequestUrl:
                return "Invalid request URL."
                
            case .invalidResponse:
                return "Invalid response data."
                
            case .unauthorized:
                return "Insufficient rights to perform the request."
                
            case .backend(let response):
                return response.message
            
            }
        }
    }
    
}
