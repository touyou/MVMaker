//
//  PageViewController.swift
//  MVMaker
//
//  Created by 藤井陽介 on 2017/08/03.
//  Copyright © 2017年 藤井陽介. All rights reserved.
//

import UIKit

class PageViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    var image: UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        imageView.image = image
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
