//
//  SearchVC.swift
//  Hydra
//
//  Created by ZhuFaner on 2017/9/5.
//  Copyright © 2017年 Zhufaner. All rights reserved.
//

import UIKit
import Alamofire
import MJRefresh

class SearchVC: UITableViewController {
    static var nib: SearchVC{
        return UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchVC") as! SearchVC
    }
    
    var results: Members?
    
    var keyword: String?
    
    weak var vc: ViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func loadData(){
        
    }
    
    var isLoading: Bool = false
    func loadMore(){
        if isLoading{
            return
        }
        isLoading = true
        guard let word = keyword else {return}
        Alamofire.request("http://47.94.140.221:9090/api/search", method: .post, parameters: ["province": vc.province, "keyword": word, "page": results!.current_page+1]).responseObject { (response: DataResponse<Members>) in
            self.results?.insert(item: response.value!)
            self.tableView.reloadData()
            self.isLoading = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "Detail"?:
            if let detail = segue.destination as? DetailVC{
                detail.id = results!.list[tableView.indexPathForSelectedRow!.row].id
            }
        default:
            break
        }
    }
}

extension SearchVC{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results?.list.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = results!.list[indexPath.row]
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DetailVC") as! DetailVC
        detailVC.id = results!.list[indexPath.row].id
        presentingViewController?.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if results!.list[indexPath.row].images.isEmpty{
            return UITableViewAutomaticDimension
        }else{
            return 600
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if results!.list.count - indexPath.row <= 5 {
            if results!.haveMore{
                loadMore()
            }
        }
    }

}

extension SearchVC: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        guard let keyword = searchController.searchBar.text else {return}
        self.keyword = keyword
        Alamofire.request("https://baby.zhangzhijie.net/api/search", method: .post, parameters: ["province": vc.province, "keyword": keyword]).responseObject { (response: DataResponse<Members>) in
            self.results = response.value!
            self.tableView.reloadData()
        }
    }
}
