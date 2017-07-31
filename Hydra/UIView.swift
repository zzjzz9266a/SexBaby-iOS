//
//  UIView.swift
//  crm
//
//  Created by ZhuFaner on 2017/1/16.
//  Copyright © 2017年 北京水木优品科技有限公司. All rights reserved.
//

import UIKit

extension UIView{
    
    var origin: CGPoint{
        set{
            self.frame = CGRect(x: newValue.x, y: newValue.y, width: width, height: height)
        }
        get{
            return frame.origin
        }
    }
    
    var x: CGFloat{
        set{
            let origin = self.origin
            self.origin = CGPoint(x: newValue, y: origin.y)
        }
        get{
            return origin.x
        }
    }
    
    var y: CGFloat{
        set{
            let origin = self.origin
            self.origin = CGPoint(x: origin.x, y: newValue)
        }
        get{
            return origin.y
        }
    }
    
    var size: CGSize{
        set{
            let bounds = self.bounds
            self.bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: newValue.width, height: newValue.height)
        }
        get{
            return bounds.size
        }
    }
    
    var width: CGFloat{
        set{
            size = CGSize(width: newValue, height: size.height)
        }
        get{
            return size.width
        }
    }
    
    var height: CGFloat{
        set{
            size = CGSize(width: width, height: newValue)
        }
        get{
            return size.height
        }
    }
    
    func setConstraint(attr: NSLayoutAttribute, to view: UIView, constant: CGFloat, relation: NSLayoutRelation = .equal){
        view.addConstraint(NSLayoutConstraint(item: self, attribute: attr, relatedBy: relation, toItem: view, attribute: attr, multiplier: 1, constant: constant))
    }
}
