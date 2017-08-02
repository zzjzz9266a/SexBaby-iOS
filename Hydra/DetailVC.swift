//
//  DetailVC.swift
//  Hydra
//
//  Created by ZhuFaner on 2017/7/31.
//  Copyright © 2017年 Zhufaner. All rights reserved.
//

import UIKit
import AlamofireObjectMapper
import Alamofire

class DetailVC: UITableViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    
    @IBOutlet weak var areaLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var projectLabel: UILabel!
    @IBOutlet weak var securityLabel: UILabel!
    @IBOutlet weak var judgelabel: UILabel!
    
    @IBOutlet weak var detailLabel: UILabel!
    
    var baby: Member?
    var id: Int = 0
    var province: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    func loadData(){
        Alamofire.request("http://47.94.140.221:9090/api/detail/\(id)", method: .post, parameters: ["province": province]).responseObject { (response: DataResponse<Member>) in
            self.baby = response.value
            self.refreshContent()
            self.tableView.reloadData()
        }
    }
    
    func refreshContent(){
        titleLabel.text = baby?.title
        priceLabel.text = baby?.price
        phoneLabel.text = baby?.connection
        areaLabel.text = "所属地区：" + (baby?.province ?? "") + (baby?.area ?? "")
        addressLabel.text = baby?.address
        ageLabel.text = baby?.age
        projectLabel.text = baby?.project
        securityLabel.text = baby?.security
        judgelabel.text = baby?.judge
        detailLabel.text = baby?.detail
    }
}

extension DetailVC{
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
