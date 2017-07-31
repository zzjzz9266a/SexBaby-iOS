//
//  PullDownMenu.swift
//  DropDownMenu-Demo
//
//  Created by ZhuFaner on 2017/6/1.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit

enum ShowType{
    case point
    case line
    case fade
}

class DropDownMenuManager: NSObject {
    
    static let share = DropDownMenuManager()
    
    //已选的内容
    public var selected: String?
    
    //选择菜单项的回调
    public var finishCallBack: ((_ index: Int, _ title: String) -> Void)?
    
    //显示的动画类型
    public var showType: ShowType = .fade
    
    public var font: UIFont = UIFont.systemFont(ofSize: 16)
    
    public var textColor: UIColor = UIColor.darkGray
    
    //是否显示箭头
    public var showTriangle: Bool = false
    
    private var mask: MaskView = MaskView(frame: UIScreen.main.bounds)
    
    private var triangle = Triangle()
    
    private var isShown:Bool = false
    
    private var triangleHeight: CGFloat{
        return Triangle.triangleHeight
    }
    
    private var rect: CGRect = CGRect.zero
    
    public var options:Array<String> = [] {//菜单项数据，设置后自动刷新列表
        didSet {
            reload()
        }
    }
    
    private var _rowHeight:CGFloat = 0
    public var rowHeight:CGFloat { //菜单项的每一行行高，默认和本控件一样高，如果为0则和本空间初始高度一样
        get{
            if _rowHeight == 0{
                return 44
            }
            return _rowHeight
        }
        set{
            _rowHeight = newValue
            reload()
        }
    }
    
    private var _menuMaxHeight:CGFloat = 0
    public var menuHeight : CGFloat{// 菜单展开的最大高度，当它为0时全部展开
        get {
            if _menuMaxHeight == 0{
                return CGFloat(self.options.count) * self.rowHeight
            }
            return min(_menuMaxHeight, CGFloat(self.options.count) * self.rowHeight)
        }
        set {
            _menuMaxHeight = newValue
            reload()
        }
    }
    
    public var menuWidth: CGFloat = 150{
        didSet{
            reload()
        }
    }
    
    private lazy var optionsList:UITableView = { //下拉列表
        let table = UITableView(frame: CGRect.zero, style: .plain)
        table.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        table.dataSource = self
        table.delegate = self
        table.layer.cornerRadius = 3
        table.layer.masksToBounds = true
        table.alpha = 0
        return table
    }()
    
    private var keyWindow: UIWindow?{
        return UIApplication.shared.keyWindow
    }
    
    //最终坐标
    private var originX: CGFloat{
        if menuWidth + rect.origin.x > UIScreen.main.bounds.width{
            return rect.maxX - menuWidth
        }else{
            return rect.origin.x
        }
    }
    
    //最终坐标
    private var originY: CGFloat{
        if menuHeight+rect.origin.y+rect.size.height-0.5 > UIScreen.main.bounds.height{
            return rect.origin.y - menuHeight - (showTriangle ? triangleHeight : 0)
        }else{
            return rect.maxY + (showTriangle ? triangleHeight : 0)
        }
    }
    
    //初始坐标
    private var startX: CGFloat{
        return menuWidth + rect.origin.x > UIScreen.main.bounds.width ? rect.maxX : rect.origin.x
    }
    
    //初始坐标
    private var startY: CGFloat{
        return menuHeight+rect.origin.y+rect.size.height-0.5 > UIScreen.main.bounds.height ? rect.origin.y : rect.maxY
    }
    
    override init() {
        super.init()
        mask.addSubview(optionsList)
    }
    
    func show(_ rect: CGRect, options: Array<String>, finish: ((_ index: Int, _ title: String) -> Void)?){
        self.rect = rect
        self.options = options
        self.finishCallBack = finish
        
        mask.frame = UIScreen.main.bounds
        keyWindow?.addSubview(mask)
        
        optionsList.reloadData()
        
        switch showType{
        case .line:
            lineShow()
        case .point:
            pointShow()
        case .fade:
            fadeShow()
        }
        
        addTriangle()
    }
    
    //绘制箭头
    private func addTriangle(){
        if showTriangle{
            mask.addSubview(triangle)
            triangle.up = menuHeight+rect.origin.y+rect.size.height-0.5 <= UIScreen.main.bounds.height
            
            if menuHeight+rect.origin.y+rect.size.height-0.5 <= UIScreen.main.bounds.height{
                triangle.frame = CGRect(x: rect.origin.x+rect.width/2-10, y: rect.maxY, width: 20, height: 10)
            }else{
                triangle.frame = CGRect(x: rect.origin.x+rect.width/2-10, y: rect.origin.y-10, width: 20, height: 10)
            }
            triangle.setNeedsDisplay()
            triangle.alpha = 0
            UIView.animate(withDuration: 0.25, animations: {
                self.triangle.alpha = 1
            })
        }
    }
    
    private func fadeShow(){
        optionsList.frame = CGRect(x: originX, y: originY, width: menuWidth, height: menuHeight)
        optionsList.alpha = 0
        UIView.animate(withDuration: 0.25, animations: {
            self.optionsList.alpha = 1
            self.mask.backgroundColor = UIColor(white: 0, alpha: 0.2)
        }) { (finish) in
            if finish{
                self.isShown = true
            }
        }
    }
    
    private func lineShow(){
        optionsList.alpha = 1
        optionsList.frame = CGRect(x: originX, y: startY, width: menuWidth, height: 0)
        UIView.animate(withDuration: 0.25, animations: {
            self.optionsList.frame = CGRect(x: self.originX, y: self.originY, width: self.menuWidth, height: self.menuHeight)
            self.mask.backgroundColor = UIColor(white: 0, alpha: 0.2)
        }) { (finish) in
            if finish{
                self.isShown = true
            }
        }
    }
    
    private func pointShow(){
        optionsList.alpha = 1
        optionsList.frame = CGRect(x: startX, y: startY, width: 0, height: 0)
        
        UIView.animate(withDuration: 0.25, animations: {
            self.optionsList.frame = CGRect(x: self.originX, y: self.originY, width: self.menuWidth, height: self.menuHeight)
            self.mask.backgroundColor = UIColor(white: 0, alpha: 0.2)
        }) { (finish) in
            if finish{
                self.isShown = true
            }
        }
    }
    
    func hide(){
        UIView.animate(withDuration: 0.25, animations: {
            self.mask.backgroundColor = UIColor(white: 0, alpha: 0)
            switch self.showType {
            case .line:
                self.optionsList.frame = CGRect(x: self.originX, y: self.startY, width: self.menuWidth, height: 0)
            case .point:
                self.optionsList.frame = CGRect(x: self.startX, y: self.startY, width: 0, height: 0)
                break
            case .fade:
                self.optionsList.alpha = 0
                self.triangle.alpha = 0
            }
            
        }) { (finish) in
            if finish{
                self.isShown = false
                self.mask.removeFromSuperview()
                self.triangle.removeFromSuperview()
                self.finishCallBack = nil
            }
        }
        
    }
    
    private func reload(){
        if !self.isShown {
            return
        }
        optionsList.reloadData()
        UIView.animate(withDuration: 0.25, animations: {
            self.mask.backgroundColor = UIColor(white: 0, alpha: 0.4)
            self.optionsList.frame = CGRect(x: self.originX, y: self.originY, width: self.menuWidth, height: self.menuHeight)
        }) { finish in
            if finish{
                self.isShown = true
            }
        }
    }
}

extension DropDownMenuManager: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "")
        if selected == options[indexPath.row]{
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none
        }
        cell.textLabel?.text = options[indexPath.row]
        cell.textLabel?.textColor = textColor
        cell.textLabel?.font = font
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        finishCallBack?(indexPath.row, options[indexPath.row])
        hide()
    }
}

fileprivate class MaskView: UIView{
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 0, alpha: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor(white: 0, alpha: 0)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        DropDownMenuManager.share.hide()
    }
}

fileprivate class Triangle: UIView{
    static let triangleWidth: CGFloat = 20
    
    static let triangleHeight: CGFloat = 10
    
    private var triangleLayer: CAShapeLayer?
    
    //箭头方向
    public var up: Bool = true
    
    override func draw(_ rect: CGRect) {
        triangleLayer?.removeFromSuperlayer()
        triangleLayer = nil
        let path = UIBezierPath()
        let trianglePoint = CGPoint(x: width/2, y: up ? 0 : height)
        path.move(to: trianglePoint)
        let triangleY = up ? (trianglePoint.y + Triangle.triangleHeight) : (trianglePoint.y - Triangle.triangleHeight)
        path.addLine(to: CGPoint(x: trianglePoint.x - Triangle.triangleWidth * 0.5, y: triangleY))
        path.addLine(to: CGPoint(x: trianglePoint.x + Triangle.triangleWidth * 0.5, y: triangleY))
        triangleLayer = CAShapeLayer()
        triangleLayer!.path = path.cgPath
        triangleLayer!.fillColor = UIColor.white.cgColor
        triangleLayer!.strokeColor = UIColor.white.cgColor
        layer.addSublayer(triangleLayer!)
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: Triangle.triangleWidth, height: Triangle.triangleHeight))
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
