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
    var province: String?
    var filterBtn: FuckingButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(loadData))
        tableView.mj_header.beginRefreshing()
        setupFilterBtn()
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
    
    func filting(){
        DropDownMenuManager.share.showTriangle = true
        DropDownMenuManager.share.show(CGRect(x: UIScreen.main.bounds.width-64, y: 32, width: 64, height: 30), options: ["北京", "四川", "广东", "云南"], finish: { (index, text) in
            self.filterBtn.setTitle(text, for: .normal)

            let contents = CFStringCreateMutableCopy(nil, 0, text as CFString)
            CFStringTransform(contents, nil, kCFStringTransformToLatin, false)
            CFStringTransform(contents, nil, kCFStringTransformStripCombiningMarks, false)
            let pinyin = (contents! as String).replacingOccurrences(of: " ", with: "")
            self.province = pinyin
            self.tableView.mj_header.beginRefreshing()
        })
    }
    
    func loadData(){
        guard province != nil else {
            tableView.mj_header.endRefreshing()
            return
        }
        Alamofire.request("http://zhangzhijie.space:8080/api/list", method: .post, parameters: ["province": province!, "page": 1]).responseObject { (response: DataResponse<Members>) in
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
                detail.province = province!
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
        Alamofire.request("http://zhangzhijie.space:8080/api/list", method: .post, parameters: ["province": province!, "page": dataSource!.current_page+1]).responseObject { (response: DataResponse<Members>) in
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! Cell
        cell.data = dataSource!.list[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if dataSource!.list.count - indexPath.row <= 5 {
            if dataSource!.haveMore{
                loadMore()
            }
        }
    }
}

class Cell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    var data: Member?{
        didSet{
            guard data != nil else {return}
            titleLabel.text = data!.title
            priceLabel.text = data!.price
            timeLabel.text = "发布时间：" + data!.public_date
        }
    }
}