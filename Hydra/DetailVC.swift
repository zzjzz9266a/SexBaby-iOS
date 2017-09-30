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
import Kingfisher
//import SKPhotoBrowser

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
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewLayout: UICollectionViewFlowLayout!
    
    var starBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    
    var baby: Member?
    var id: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setStar()
        loadData()
    }
    
    func loadData(){
        Alamofire.request("https://baby.zhangzhijie.net/api/detail/\(id)", method: .post).responseObject { (response: DataResponse<Member>) in
            self.baby = response.value
            self.refreshContent()
            self.tableView.reloadData()
        }
    }
    
    func setStar(){
        starBtn.setImage(#imageLiteral(resourceName: "星标"), for: .normal)
        starBtn.setImage(#imageLiteral(resourceName: "星标-实心"), for: .selected)
        starBtn.addTarget(self, action: #selector(starClick), for: .touchUpInside)
        starBtn.isSelected = App.favoriteList.contains(id)
        let btnItem = UIBarButtonItem()
        btnItem.customView = starBtn
        navigationItem.rightBarButtonItem = btnItem
    }
    
    func refreshContent(){
        pageControl.numberOfPages = baby?.images.count ?? 0
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
        collectionView.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let screenWidth = UIScreen.main.bounds.width
        collectionViewLayout.itemSize = CGSize(width: screenWidth, height: screenWidth)
        collectionViewLayout.minimumLineSpacing = 0
        collectionViewLayout.minimumInteritemSpacing = 0
    }
    
    @objc func starClick(){
        if let index = App.favoriteList.index(of: id){
            App.favoriteList.remove(at: index)
            starBtn.isSelected = false
        }else{
            App.favoriteList.append(id)
            starBtn.isSelected = true
        }
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
        switch indexPath.section {
        case 1:
            if baby?.images.count == 0{
                return 0
            }else{
                return UIScreen.main.bounds.width
            }
        default:
            return UITableViewAutomaticDimension
        }
    }
}

extension DetailVC: UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return baby?.images.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        (cell.viewWithTag(10086) as? UIImageView)?.kf.setImage(with: URL(string: baby!.images[indexPath.row]))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let images = baby!.images.map({SKPhoto.photoWithImageURL($0)})
        let skVC = SKPhotoBrowser(photos: images)
        skVC.initializePageIndex(indexPath.row)
        present(skVC, animated: true, completion: nil)
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == collectionView{
            let index = Int(scrollView.contentOffset.x/UIScreen.main.bounds.width)
            pageControl.currentPage = index
        }
    }
}
