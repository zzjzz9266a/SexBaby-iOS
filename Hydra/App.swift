//
//  App.swift
//  Hydra
//
//  Created by ZhuFaner on 2017/9/5.
//  Copyright © 2017年 Zhufaner. All rights reserved.
//

import Foundation

struct App {
    static var favoriteList: [Int]{
        set{
            UserDefaults.standard.set(newValue, forKey: "favoriteList")
        }
        get{
            return UserDefaults.standard.array(forKey: "favoriteList") as? [Int] ?? []
        }
    }
}
