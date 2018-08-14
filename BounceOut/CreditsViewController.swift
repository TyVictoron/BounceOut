//
//  CreditsViewController.swift
//  BounceOut
//
//  Created by Ty on 4/7/15.
//  Copyright (c) 2015 TyGames. All rights reserved.
//

import UIKit
//import iAd

class CreditsViewController: UIViewController {

//    @IBOutlet weak var adBannerView: ADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        //iAd
//        self.canDisplayBannerAds = true
//        self.adBannerView.delegate = self
//        self.adBannerView.hidden = true //hide until ad loaded
        
    }
    
//    //iAd
//    func bannerViewWillLoadAd(banner: ADBannerView!) {
//        NSLog("bannerViewWillLoadAd")
//    }
//
//    func bannerViewDidLoadAd(banner: ADBannerView!) {
//        NSLog("bannerViewDidLoadAd")
//        self.adBannerView.hidden = false //now show banner as ad is loaded
//    }
//
//    func bannerViewActionDidFinish(banner: ADBannerView!) {
//        NSLog("bannerViewDidLoadAd")
//
//        //optional resume paused game code
//
//    }
//
//    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
//        NSLog("bannerViewActionShouldBegin")
//
//        //optional pause game code
//
//        return true
//    }
//
//    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
//        NSLog("bannerView")
//    }
    
    @IBAction func dismissButtonTapped(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
