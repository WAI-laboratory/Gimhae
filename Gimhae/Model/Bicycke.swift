import Foundation

struct BicycleResponse: Codable {
    var status: String
    var message: String
    var data: [Bicycle]

}
struct Bicycle: Codable, Equatable {
    var mgtNo: String
    var name: String
    var xCoordinate: String
    var yCoordinate: String
    var addr: String
    
    var latitude: Double? {
        return Double(self.yCoordinate)
    }
    
    var longitude: Double? {
        return Double(self.xCoordinate)
    }
}


struct BicycleInOutResponse: Codable {
    var status: String
    var message: String
    var data: [BicycleInOut]
}

struct BicycleInOut: Codable, Equatable {
    var facId: String
    var mgtNo: String
    var name: String
    var inCnt: Int // 대여수
    var outCnt: Int // 반납수
}


//{"status":"200","message":"정상 처리 되었습니다.","data":[{"facId":"FAC_8f0bd5951318428a95f4d1fe863724be","mgtNo":"STATION_001","name":"봉황역","inCnt":7356,"outCnt":6830},{"facId":"FAC_e5cddeb0545646c7a99eeec754a680cb","mgtNo":"STATION_002","name":"수로왕릉역","inCnt":4585,"outCnt":4710},{"facId":"FAC_f1169b68015042a8b25ef596f4e2687e","mgtNo":"STATION_003","name":"수로왕릉","inCnt":2842,"outCnt":3367},{"facId":"FAC_415e9919208345f59f67b7683db181b3","mgtNo":"STATION_004","name":"대성동고분박물관","inCnt":4170,"outCnt":4560},{"facId":"FAC_6e64c0d08eeb481dbfd249189804479c","mgtNo":"STATION_005","name":"박물관역","inCnt":3299,"outCnt":3597},{"facId":"FAC_fd0778e1184c4b71a10ba7893ebabb5a","mgtNo":"STATION_006","name":"수로왕비릉","inCnt":669,"outCnt":733},{"facId":"FAC_c8e3fdbd4c2c421785c0bf86acf686cf","mgtNo":"STATION_007","name":"국립김해박물관","inCnt":4076,"outCnt":4309},{"facId":"FAC_7a509388cad040209bc8bb6020cf8276","mgtNo":"STATION_008","name":"연지공원역","inCnt":7357,"outCnt":6300},{"facId":"FAC_f38037c4fa7c4cb9809bb982c34ebf21","mgtNo":"STATION_009","name":"연지공원","inCnt":5525,"outCnt":5923},{"facId":"FAC_13f5018c34b045d98a085671c8d2aeaf","mgtNo":"STATION_010","name":"거북공원","inCnt":7598,"outCnt":7277},{"facId":"FAC_c4dd9ac359b748b98b0ef4cb2c835f15","mgtNo":"STATION_011","name":"공주공원","inCnt":4834,"outCnt":4861}]}
