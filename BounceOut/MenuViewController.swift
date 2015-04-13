//
//  MenuViewController.swift
//  BounceOut
//
//  Created by Ty on 3/22/15.
//  Copyright (c) 2015 TyGames. All rights reserved.
//

import UIKit
import AVFoundation

class MenuViewController: UIViewController {

    var backgroundMusic = AVAudioPlayer()
    
    func setupAudioPlayerWithFile(file:NSString, type:NSString) -> AVAudioPlayer  {
        //1
        var path = NSBundle.mainBundle().pathForResource(file, ofType:type)
        var url = NSURL.fileURLWithPath(path!)
        
        //2
        var error: NSError?
        
        //3
        var audioPlayer:AVAudioPlayer?
        audioPlayer = AVAudioPlayer(contentsOfURL: url, error: &error)
        
        //4
        return audioPlayer!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add background
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "BounceOutBackground.png")!)
    
        backgroundMusic = self.setupAudioPlayerWithFile("mainMenu", type:"wav")
        backgroundMusic.play()
        backgroundMusic.numberOfLoops = -1
        
    }
    
    @IBAction func lvl1(sender: UIButton) {
        backgroundMusic.stop()
    }
    
    @IBAction func lvl2(sender: UIButton) {
        backgroundMusic.stop()
    }
    
    @IBAction func lvl3(sender: UIButton) {
        backgroundMusic.stop()
    }
    
    
    
    
    
    
}
