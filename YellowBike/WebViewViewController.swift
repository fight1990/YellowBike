//
//  WebViewViewController.swift
//  YellowBike
//
//  Created by butcher on 2018/3/27.
//  Copyright © 2018年 butcher. All rights reserved.
//

let SCREEN_WIDTH = UIScreen.main.bounds.size.width
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
let SCREEN_ORIGIN_Y = (UIApplication.shared.statusBarFrame.size.height + 44)

import UIKit
import WebKit

class WebViewViewController: UIViewController,WKUIDelegate,WKNavigationDelegate {
    
    
    var webView:WKWebView!
    var progressView:UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        self.title = "热门活动"
        
        webView = WKWebView(frame: self.view.frame)
        webView.uiDelegate = self;
        webView.navigationDelegate = self;
        self.view.addSubview(webView)
        
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        
        progressView = UIProgressView(frame: CGRect(x: 0, y: SCREEN_ORIGIN_Y, width: SCREEN_WIDTH, height: 5))
        progressView.tintColor = .orange
        progressView.trackTintColor = .white
        self.view.addSubview(progressView)
        
        let url = URL(string: "http://m.ofo.so/active.html")
        let request = NSURLRequest(url: url!)
        webView.load(request as URLRequest)
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if webView.isEqual(object) && (keyPath?.elementsEqual("estimatedProgress"))! {
            
            let newProgress:NSNumber = change?[.newKey] as! NSNumber
            progressView.setProgress(newProgress.floatValue, animated: true)
            
            if newProgress.floatValue >= 1.0 {

                let delay = DispatchTime.now() + DispatchTimeInterval.seconds(1)
                DispatchQueue.main.asyncAfter(deadline: delay) {
                    self.switchProgress(1, withHidden: true)
                }
            }
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
//        let queue = DispatchQueue(label: "switchProgress")
//        queue.async {
//            self.switchProgress(0, withHidden: false)
//        }
        self.switchProgress(0, withHidden: false)
        
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        

    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.init(uptimeNanoseconds: UInt64(5 * NSEC_PER_SEC))) {
            self.switchProgress(1, withHidden: true)
        }
    }

    func switchProgress(_ value:Float, withHidden hidden:Bool) {
        progressView.setProgress(value, animated: true)
        progressView.isHidden = hidden
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")

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
