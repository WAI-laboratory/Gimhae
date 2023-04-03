import Combine
import Foundation

class FestivalService: BaseService {
    let url = "http://www.gimhae.go.kr/openapi/tour/festival.do"
    
    func getFestivals(page: Int) -> AnyPublisher<FestivalResponse, Error> {
        
        guard let _url = URL(string: url + "?page=\(page)") else { return Fail(error: SimpleError(message: "url not found")).eraseToAnyPublisher()}
        
        return URLSession.shared.dataTaskPublisher(for: _url)
            .tryMap(\.data)
            .tryMap { data in
                do {
                    let _data = try JSONDecoder().decode(FestivalResponse.self, from: data)
                    return _data
                } catch {
                    throw DecodeFailedError(data: data, error: error)
                }
            }
            .eraseToAnyPublisher()
    }
}
