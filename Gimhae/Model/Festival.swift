//
//  Festival.swift
//  Gimhae
//
//  Created by 이용준 on 2023/04/03.
//

import Foundation
struct FestivalResponse: Codable {
    var record_count: Int
    var pageunit: Int
    var page_count: Int
    var page: Int
    var results: [Festival]
}

struct Festival: Codable {
    var name: String
    var address: String
    var idx: Int
    var category: String
    var area: String
    var copy: String
    var manage: String
    var phone: String
    var homepage: String
    var fee: String
    var xposition: String
    var yposition: String
    var parking: String
    var images: [String]
    var sdate: String // 시작일
    var edate: String // 종료일
    var undecided: String // 미정 여부
    var opener: String // 주관
}
