//
//  Member.swift
//  Hydra
//
//  Created by ZhuFaner on 2017/7/29.
//  Copyright © 2017年 Zhufaner. All rights reserved.
//

import ObjectMapper

struct Member: Mappable{
    var id: String = ""
    var title: String = ""
    var connection: String = ""
    var price: String = ""
    var public_date: String = ""
    var area: String = ""
    var age: String = ""
    var security: String = ""
    var judge: String = ""
    var project: String = ""
    var detail: String = ""
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        connection <- map["connection"]
        price <- map["price"]
        public_date <- map["public_date"]
        area <- map["area"]
        age <- map["age"]
        security <- map["security"]
        judge <- map["judge"]
        project <- map["project"]
        detail <- map["detail"]
    }
}

struct Members: Mappable {
    var list: [Member] = []
    var current_page: Int = 0
    var last_page: Int = 0
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        list <- map["data"]
        current_page <- map["current_page"]
        last_page <- map["last_page"]
    }
    
    mutating func insert(item: Members){
        if current_page < last_page{
            last_page = item.last_page
            current_page = item.current_page
            list += item.list
        }
    }
    
    var haveMore: Bool{
        return current_page < last_page
    }
}

struct Province: Mappable {
    var id: Int = 0
    var province_id: Int = 0
    var name: String = ""
    var name_pinyin: String = ""
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        province_id <- map["province_id"]
        name <- map["name"]
        name_pinyin <- map["name_pinyin"]
    }
}
