//
//  CollectionVC.swift
//  Hydra
//
//  Created by ZhuFaner on 2017/9/5.
//  Copyright © 2017年 Zhufaner. All rights reserved.
//

import UIKit
import MJRefresh
import Alamofire
import ObjectMapper

class CollectionVC: UITableViewController {

    var dataSource: Members?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(loadData))
        tableView.mj_header.beginRefreshing()

    }
    
    func loadData(){
        do{
            let data = try JSONSerialization.data(withJSONObject: App.favoriteList, options: [])
            let json = String(data: data, encoding: .utf8)!
            Alamofire.request("http://47.94.140.221:9090/api/collection", method: .post, parameters: ["ids": json, "page": 1]).responseObject { (response: DataResponse<Members>) in
                self.tableView.mj_header.endRefreshing()
                self.dataSource = response.value
                self.tableView.reloadData()
            }
        }catch{
            
        }
    }
    
    var isLoading: Bool = false
    func loadMore(){
        if isLoading{
            return
        }
        isLoading = true
        Alamofire.request("http://47.94.140.221:9090/api/collection", method: .post, parameters: ["ids": App.favoriteList, "page": dataSource!.current_page+1]).responseObject { (response: DataResponse<Members>) in
            self.dataSource?.insert(item: response.value!)
            self.tableView.reloadData()
            self.isLoading = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "Detail"?:
            if let detail = segue.destination as? DetailVC{
                detail.id = dataSource!.list[tableView.indexPathForSelectedRow!.row].id
            }
        default:
            break
        }
    }
}

extension CollectionVC{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.list.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = dataSource!.list[indexPath.row]
        if item.images.isEmpty{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! Cell
            cell.data = item
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath) as! ImageCell
            cell.data = item
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if dataSource!.list[indexPath.row].images.isEmpty{
            return UITableViewAutomaticDimension
        }else{
            return 600
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if dataSource!.list.count - indexPath.row <= 5 {
            if dataSource!.haveMore{
                loadMore()
            }
        }
    }
}
