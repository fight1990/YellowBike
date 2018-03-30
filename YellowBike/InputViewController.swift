//
//  InputViewController.swift
//  YellowBike
//
//  Created by butcher on 2018/3/31.
//  Copyright © 2018年 butcher. All rights reserved.
//

import UIKit

class InputViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "扫码用车", style: .plain, target: self, action: #selector(backAction))
        
    }
    
    @objc func backAction() {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func OpenLock(_ sender: Any) {
    }
    
    @IBAction func openLight(_ sender: Any) {
    }
    
    @IBAction func voiceAction(_ sender: Any) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
