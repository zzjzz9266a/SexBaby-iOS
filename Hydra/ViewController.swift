//
//  ViewController.swift
//  Hydra
//
//  Created by ZhuFaner on 2017/7/29.
//  Copyright © 2017年 Zhufaner. All rights reserved.
//

import UIKit
import AlamofireObjectMapper
import Alamofire
import MJRefresh

class ViewController: UITableViewController {

    var dataSource: Members?
    var province: String = "北京"
    var filterBtn: FuckingButton!
    var provinces: [String] = []
    var searchVC: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(loadData))
        tableView.mj_header.beginRefreshing()
        setupSearchVC()
        setupFilterBtn()
        loadProvinces()

    }
    
    func loadProvinces(){
        Alamofire.request("https://baby.zhangzhijie.net/api/province", method: .post).responseJSON { (response) in
            if let array = response.value as? [String]{
                self.provinces = array
            }
        }
    }
    
    func setupSearchVC(){
        let resultVC = SearchVC.nib
        resultVC.vc = self
        searchVC = UISearchController(searchResultsController: resultVC)
        searchVC.searchBar.placeholder = "搜索城市、地区、详细地址"
        searchVC.searchBar.searchBarStyle = .minimal
        searchVC.delegate = self
        searchVC.searchResultsUpdater = resultVC
        definesPresentationContext = true

        tableView.tableHeaderView = searchVC.searchBar
    }
    
    func setupFilterBtn(){
        filterBtn = FuckingButton(frame: CGRect(x: 0, y: 0, width: 64, height: 34))
        filterBtn.setImage(#imageLiteral(resourceName: "下箭头"), for: .normal)
        filterBtn.reverse = true
        filterBtn.padding = 8
        filterBtn.setTitle("北京", for: .normal)
        filterBtn.setTitleColor(UIColor.darkGray, for: .normal)
        filterBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        filterBtn.addTarget(self, action: #selector(filting), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: filterBtn)
    }
    
    @objc func filting(){
        DropDownMenuManager.share.showTriangle = true
        DropDownMenuManager.share.menuHeight = 400
        DropDownMenuManager.share.show(CGRect(x: UIScreen.main.bounds.width-72, y: 32, width: 64, height: 30), options: provinces, finish: { (index, text) in
            self.filterBtn.setTitle(text, for: .normal)
            self.province = text
            self.tableView.mj_header.beginRefreshing()
        })
    }
    
    @objc func loadData(){
        Alamofire.request("https://baby.zhangzhijie.net/api/list", method: .post, parameters: ["province": province, "page": 1]).responseObject { (response: DataResponse<Members>) in
            self.tableView.mj_header.endRefreshing()
            self.dataSource = response.value!
            self.tableView.reloadData()
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
    
    var isLoading: Bool = false
    func loadMore(){
        if isLoading{
            return
        }
        isLoading = true
        Alamofire.request("https://baby.zhangzhijie.net/api/list", method: .post, parameters: ["province": province, "page": dataSource!.current_page+1]).responseObject { (response: DataResponse<Members>) in
            self.dataSource?.insert(item: response.value!)
            self.tableView.reloadData()
            self.isLoading = false
        }
    }
}

extension ViewController{
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

extension ViewController: UISearchControllerDelegate{
    func willPresentSearchController(_ searchController: UISearchController) {
        tableView.mj_header = nil
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(loadData))
    }
}

class Cell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var areaLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
    
    var data: Member?{
        didSet{
            guard data != nil else {return}
            titleLabel.text = data!.title
            priceLabel.text = data!.price
            areaLabel.text = data!.area
            timeLabel.text = "发布时间：" + data!.public_date
        }
    }
}

class ImageCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var areaLabel: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    var data: Member?{
        didSet{
            guard data != nil else {return}
            titleLabel.text = data!.title
            priceLabel.text = data!.price
            areaLabel.text = data!.area
            timeLabel.text = "发布时间：" + data!.public_date
            imgView.kf.setImage(with: URL(string: data!.images.first!))
        }
    }
}
