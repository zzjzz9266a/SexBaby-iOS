//
//  ReverseButton.swift
//  crm
//
//  Created by ZhuFaner on 2017/5/17.
//  Copyright © 2017年 北京水木优品科技有限公司. All rights reserved.
//

import UIKit

@IBDesignable
class ReverseButton: UIButton {
    
    @IBInspectable var padding: CGFloat = 0

    override func layoutSubviews() {
        super.layoutSubviews()
        guard currentImage != nil, titleLabel != nil else { return }
        titleEdgeInsets = UIEdgeInsets(top: 0, left: -currentImage!.size.width-padding/2, bottom: 0, right: currentImage!.size.width+padding/2)
        imageEdgeInsets = UIEdgeInsets(top: 0, left: titleLabel!.width+padding/2, bottom: 0, right: -titleLabel!.width-padding/2)
    }

}

@IBDesignable
class FuckingButton: UIButton {
    @IBInspectable var verticalMargin: CGFloat = 0
    @IBInspectable var horizontalMargin: CGFloat = 0
    
    @IBInspectable var borderColor: UIColor?{
        didSet{
            layer.borderColor = borderColor?.cgColor
            setTitleColor(borderColor, for: .normal)
        }
    }
    
    @IBInspectable var borderWidth: CGFloat{
        set{
            layer.borderWidth = newValue
        }
        get{
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat{
        set{
            layer.cornerRadius = newValue
        }
        get{
            return layer.cornerRadius
        }
    }
    
    var title: String?{
        set{
            setTitle(newValue, for: .normal)
            isHidden = newValue == nil
        }
        get{
            return titleLabel?.text
        }
    }
    
    @IBInspectable var reverse: Bool = false{
        didSet{
            layoutSubviews()
        }
    }
    
    @IBInspectable var padding: CGFloat = 0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if reverse{            
            guard currentImage != nil, titleLabel != nil else { return }
            titleEdgeInsets = UIEdgeInsets(top: 0, left: -currentImage!.size.width-padding/2, bottom: 0, right: currentImage!.size.width+padding/2)
            imageEdgeInsets = UIEdgeInsets(top: 0, left: titleLabel!.width+padding/2, bottom: 0, right: -titleLabel!.width-padding/2)
        }
    }
    
    override var intrinsicContentSize: CGSize{
        return CGSize(width: super.intrinsicContentSize.width + horizontalMargin*2, height: super.intrinsicContentSize.height + verticalMargin*2)
    }
}
