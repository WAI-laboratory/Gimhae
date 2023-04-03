import Foundation
import Combine

class BaseService {
    let session = URLSession.shared
}

protocol Servicable {
    associatedtype Model: Codable
    var url: URL? { get set }
    
    func get() -> AnyPublisher<Model, Error>
}

extension Servicable {
    func get() -> AnyPublisher<Model, Error> {
        guard let url = self.url else { return Fail(error: SimpleError(message: "url not found")).eraseToAnyPublisher() }
        return URLSession.shared
            .dataTaskPublisher(for: url)
            .tryMap(\.data)
            .tryMap { data in
                do {
                    let datas = try JSONDecoder().decode(Model.self, from: data)
                    return datas
                } catch {
                    throw DecodeFailedError(data: data, error: error)
                }
            }
            .eraseToAnyPublisher()
    }
}
