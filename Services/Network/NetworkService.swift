import Foundation
import Granite

struct NetworkService : GraniteService {
    @Service var center : Center

    var configuration : Configuration = .init()
    
    init() {
        
    }
    
    mutating func setup(useMockData: Bool = false) {
        center.state.shouldUseMockData = useMockData
    }
}
