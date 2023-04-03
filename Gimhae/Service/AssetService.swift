import Combine
import Foundation

class AssetService: BaseService {
    let url = "http://www.gimhae.go.kr/openapi/tour/asset.do"
    
    func getAssets(page: Int) -> AnyPublisher<AssetResponse, Error> {
        guard let _url = URL(string: url + "?page=\(page)") else { return Fail(error: SimpleError(message: "url not found")).eraseToAnyPublisher()}
        
        return URLSession.shared.dataTaskPublisher(for: _url)
            .tryMap(\.data)
            .tryMap { data in
                do {
                    let _data = try JSONDecoder().decode(AssetResponse.self, from: data)
                    return _data
                } catch {
                    throw DecodeFailedError(data: data)
                }
            }
            .eraseToAnyPublisher()
    }
    
}

struct AssetResponse: Codable {
    var record_count: Int
    var address: String
    var name: String
    var pageunit: Int
    var page: Int
    var page_count: Int
    var results: Int
    
}

struct GimhaeAsset: Codable {
    var idx: String
    var name: String
    var category: String
    var area: String
    var copy: String
    var manage: String
    var phone: String
    var homepage: String
    var content: String
    var fee: String
    var usehour: String
    var address: String
    var xposition: String
    var yposition: String
    var parking: String
    var images: String
    
    var assetnumber: String
    var assetdate: String
    var assetscale: String
    var assetage: String
    
}

//
//{
//    "record_count": 82,
//    "address": "",
//    "name": "",
//    "pageunit": 1,
//    "page": 1,
//    "results": [
//        {
//            "idx": 617,
//            "name": "간재 전우 초상",
//            "category": "도지정문화재_유형문화재",
//            "area": "장유3동",
//            "copy": "이 작품은 견본 바탕에 간재 전우(1841-1922)의 정면관을 그린 초상화이다.",
//            "manage": "가야사복원과 문화재관리팀",
//            "phone": "055-330-3921",
//            "homepage": "",
//            "content": "이 작품은 견본 바탕에 간재 전우(1841-1922)의 정면관을 그린 초상화이다. 화문석 위에 앉은 정면관의 자세, 세필로 그린 안면 육리문의 묘사, 얼굴의 백광표현, 안면부는 극세필을 통한 명암을 강조한 반면 의복묘사에서는 담채와 담묵을 즐겨 사용한 점 등 석지 채용신의 화풍을 잘 드러내고 있다. 특히 화문석의 문양과 바라보는 시점이 정면관을 하고 있는 특징은 1920년을 기점으로 이전과 이후의 시기를 알 수 있는 중요한 요소인데 정면관의 시점인 간재의 영정은 이를 알 수 있는 하나의 기준작이 되므로 경상남도 유형문화재로 지정되었다.",
//            "fee": "전화문의",
//            "usehour": "전화문의",
//            "address": "김해시 덕정로77번길 11-12",
//            "xposition": "35.18091388446529",
//            "yposition": "128.7950850090066",
//            "parking": "전화문의",
//            "images": [
//                "http://www.gimhae.go.kr/CmsMultiFile/view.do?multifileId=MF00000883&idx=4633"
//            ],
//            "assetnumber": "도 유형문화재 제540호",
//            "assetdate": "",
//            "assetscale": "",
//            "assetage": "일제강점기"
//        }
//    ],
//    "page_count": 82,
//    "status": "OK"
//}
