//
//  MovieEditingButton.swift
//  MVMaker
//
//  Created by 藤井陽介 on 2017/07/28.
//  Copyright © 2017年 藤井陽介. All rights reserved.
//

import UIKit

@IBDesignable
class MovieEditingButton: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 50.0 {
        
        didSet {
            
            setUpView()
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 7.0 {
        
        didSet {
            
            setUpView()
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.lightGray {
        
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
        self.layer.borderWidth = self.borderWidth
        self.layer.borderColor = self.borderColor.cgColor
    }
}

