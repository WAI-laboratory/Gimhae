import Foundation
import Combine

class DustService {
    static let shared = DustService()
    private let urlSession = URLSession.shared
    let url = URL(string: "http://smartcity.gimhae.go.kr/smart_tour/dashboard/api/publicData/dustSensor")
    
    
    func getDust() -> AnyPublisher<DustResponse, Error> {
        guard let url = self.url else { return Fail(error: SimpleError(message: "url not found")).eraseToAnyPublisher() }
        return urlSession
            .dataTaskPublisher(for: url)
            .tryMap(\.data)
            .tryMap { data in
                do {
                    let datas = try JSONDecoder().decode(DustResponse.self, from: data)
                    
                    return datas
                } catch {
                    throw SimpleError(message: "decode failed \(error)")
                }
            }
            .eraseToAnyPublisher()
    }
}
