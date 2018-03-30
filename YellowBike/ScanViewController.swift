//
//  ScanViewController.swift
//  YellowBike
//
//  Created by butcher on 2018/3/30.
//  Copyright © 2018年 butcher. All rights reserved.
//

import UIKit
import swiftScan
import FTIndicator

class ScanViewController: LBXScanViewController {

    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var panelView: UIView!
    
    var isFlashOn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "扫码用车"
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        self.bottomLayoutConstraint.constant = CGFloat(-bottomHeight)
        
        var style = LBXScanViewStyle()
        style.anmiationStyle = .NetGrid
        style.animationImage = UIImage(named: "qrcode_Scan_weixin_Line")
        
        scanStyle = style
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.view.bringSubview(toFront: panelView)

    }
    
    @IBAction func flashBtnTap(_ sender: Any) {
        isFlashOn = !isFlashOn
        
        scanObj?.changeTorch()
    }
    
   
    @IBAction func inputBtnTap(_ sender: Any) {
        
    }
    
    override func handleCodeResult(arrayResult: [LBXScanResult]) {
        if let result = arrayResult.first {
            let msg = result.strScanned
            
            FTIndicator.setIndicatorStyle(.dark)
            FTIndicator.showToastMessage(msg)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBar.barStyle = .default
        self.navigationController?.navigationBar.tintColor = UIColor.black
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
