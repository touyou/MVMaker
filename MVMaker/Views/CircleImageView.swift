//
//  CircleImageView.swift
//  MVMaker
//
//  Created by 藤井陽介 on 2017/07/28.
//  Copyright © 2017年 藤井陽介. All rights reserved.
//

import UIKit

@IBDesignable
class CircleImageView: UIImageView {
    
    @IBInspectable var cornerRadius: CGFloat = 64.0 {

        didSet {
        
            setUpView()
        }
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        setUpView()
    }
    
    override func prepareForInterfaceBuilder() {
        
        super.prepareForInterfaceBuilder()
        setUpView()
    }
    
    func setUpView() {
        
        self.layer.cornerRadius = self.cornerRadius
        self.clipsToBounds = true
    }
}
