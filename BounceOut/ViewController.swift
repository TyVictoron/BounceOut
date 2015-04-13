//
//  ViewController.swift
//  BounceOut
//
//  Created by Ty on 3/19/15.
//  Copyright (c) 2015 TyGames. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController,UICollisionBehaviorDelegate {

    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var resumeButtonOutlet: UIButton!
    @IBOutlet weak var textLabel: UILabel!
    var dynamicAnimator = UIDynamicAnimator()
    var collisionBehavior = UICollisionBehavior()
    var ball = UIView()
    var paddle = UIView()
    var bricks : [UIView] = []
    var allObjects : [UIView] = []
    var lives = 5
    var blockHit = AVAudioPlayer()
    var loseLife = AVAudioPlayer()
    var score = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Score
        scoreLabel.text = "Score: \(score)"
        score = 0
        
        //Hide Resume Button
        resumeButtonOutlet.hidden = true
        
        // Add background
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "BounceOutBackground.png")!)
        
        // add a ball object to the view
        ball = UIView(frame: CGRectMake(view.center.x, view.center.y, 20, 20))
        ball.backgroundColor = UIColor.whiteColor()
        ball.layer.cornerRadius = 10
        ball.clipsToBounds = true
        view.addSubview(ball)
        
        // add a red paddle object to the view
        paddle = UIView(frame: CGRectMake(view.center.x, view.center.y * 1.7
            , 80, 20))
        paddle.backgroundColor = UIColor.redColor()
        view.addSubview(paddle)
        
        dynamicAnimator = UIDynamicAnimator(referenceView: view)
        
        // Set up bricks
        var width = (Int)(view.bounds.size.width - 40)
        var xOffset = ((Int)(view.bounds.size.width) % 42) / 2
        for var x = xOffset; x < width; x += 42 {addBlock(x, y:  40, color: UIColor.blueColor())}
        for var x = xOffset; x < width; x += 42 {addBlock(x, y:  62, color: UIColor.blueColor())}
        for var x = xOffset; x < width; x += 42 {addBlock(x, y:  84, color: UIColor.yellowColor())}
        for var x = xOffset; x < width; x += 42 {addBlock(x, y:  106, color: UIColor.yellowColor())}
        for var x = xOffset; x < width; x += 42 {addBlock(x, y:  128, color: UIColor.yellowColor())}
        
        // create dynamic behavior for the ball
        let ballDynamicBehavior = UIDynamicItemBehavior(items: [ball])
        ballDynamicBehavior.friction = 0
        ballDynamicBehavior.resistance = 0
        ballDynamicBehavior.elasticity = 1.0
        ballDynamicBehavior.allowsRotation = false
        dynamicAnimator.addBehavior(ballDynamicBehavior)
        allObjects.append(ball)
        
        // create dynamic behavior for the paddle
        let paddleDynamicBahavior = UIDynamicItemBehavior(items: [paddle])
        paddleDynamicBahavior.density = 10000
        paddleDynamicBahavior.resistance = 100
        paddleDynamicBahavior.allowsRotation = false
        dynamicAnimator.addBehavior(paddleDynamicBahavior)
        allObjects.append(paddle)
        
        // create dynamic behavior for the brick
        let brickDynamicBehavior = UIDynamicItemBehavior(items: bricks)
        brickDynamicBehavior.density = 10000
        brickDynamicBehavior.resistance = 100
        brickDynamicBehavior.allowsRotation = false
        dynamicAnimator.addBehavior(brickDynamicBehavior)
        
        // create push behavior to get the ball moving
        let pushBehavior = UIPushBehavior(items: [ball], mode: .Instantaneous)
        pushBehavior.pushDirection = CGVectorMake(0.2, 1.0)
        pushBehavior.magnitude = 0.25
        dynamicAnimator.addBehavior(pushBehavior)
        
        //creat collision behaviors so ball can bounce off other objects
        collisionBehavior = UICollisionBehavior(items: allObjects)
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        collisionBehavior.collisionMode = .Everything
        collisionBehavior.collisionDelegate = self
        dynamicAnimator.addBehavior(collisionBehavior)
        
        textLabel.text = "Lives: \(lives)"
        
        blockHit = self.setupAudioPlayerWithFile("BlockHit", type:"wav")
        loseLife = self.setupAudioPlayerWithFile("loseLife", type:"wav")
    }

    @IBAction func dragPaddle(sender: UIPanGestureRecognizer) {
        var panGesture = sender.locationInView(view)
        paddle.center = CGPointMake(panGesture.x, paddle.center.y)
        dynamicAnimator.updateItemUsingCurrentState(paddle)
    }
    
    // collision behavior deligate method (with boundary)
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying, atPoint p: CGPoint) {
        if item.isEqual(ball) && p.y > paddle.center.y {
            lives--
            loseLife.play()
            if lives > 0 {
                textLabel.text = "Lives: \(lives)"
                ball.center = view.center
                dynamicAnimator.updateItemUsingCurrentState(ball)
            }
            else {
                textLabel.text = "Game Over!"
                ball.removeFromSuperview()
                collisionBehavior.removeItem(ball)
                resetGame("Game Over!")
            }
        }
    }
    
    // collision behavior delegate method (with another object)
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item1: UIDynamicItem, withItem item2: UIDynamicItem, atPoint p: CGPoint) {
        var item = UIView()
        var hiddenBlockCount = 0
        for block in bricks {
            if item1.isEqual(ball) && item2.isEqual(block) {
                if block.backgroundColor == UIColor.blueColor() {
                    block.backgroundColor = UIColor.yellowColor()
                    scoreLabel.text = "Score: \(score++)"
                    blockHit.play()
                }
                else {
                    block.hidden = true
                    collisionBehavior.removeItem(block)
                    scoreLabel.text = "Score: \(score++)"
                    blockHit.play()
                }
            }
            if block.hidden == true {
                hiddenBlockCount++
            }
        }
        if hiddenBlockCount == bricks.count {
            resetGame("You Win!")
        }
    }
    
    // Reset Lives
    func resetLives() {
        if lives == 0 {
            lives = 5
        }
    }
    
    // Reset func
    func resetGame(winLossText: String) {
        
        // Reset ball, paddle and remove bricks
        resetLives()
        allObjects = []
        bricks = []
        ball.hidden = true
        paddle.hidden = true
        collisionBehavior.removeItem(ball)
        dynamicAnimator.updateItemUsingCurrentState(ball)
        collisionBehavior.removeItem(paddle)
        dynamicAnimator.updateItemUsingCurrentState(paddle)
        ball.removeFromSuperview()
        
        // Reset button / exit to menu
        var alert = UIAlertController(title: winLossText, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        
        var playAgainAction = UIAlertAction(title: "Play Again", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.viewDidLoad()
        }
        
        alert.addAction(playAgainAction)
        self.presentViewController(alert, animated: true, completion: nil)
        
        var quitAction = UIAlertAction(title: "Quit", style: UIAlertActionStyle.Destructive) { (action) -> Void in
            if let resultController = self.storyboard?.instantiateViewControllerWithIdentifier("MenuID") as? MenuViewController {
                self.presentViewController(resultController, animated: true, completion: nil)
            }
        }
        alert.addAction(quitAction)
    }
    
    // check for all blocks hidden
    func addBlock(x: Int, y: Int, color: UIColor) {
        var block = UIView(frame: CGRectMake((CGFloat)(x), (CGFloat)(y), 40, 20))
        block.backgroundColor = color
        view.addSubview(block)
        bricks.append(block)
        allObjects.append(block)
    }
    
    @IBAction func pauseButton(sender: UIButton) {
        resumeButtonOutlet.hidden = false
        
        let ballDynamicBehavior = UIDynamicItemBehavior(items: [ball])
        ballDynamicBehavior.friction = 0
        ballDynamicBehavior.resistance = 100
        ballDynamicBehavior.elasticity = 1.0
        ballDynamicBehavior.allowsRotation = false
        dynamicAnimator.addBehavior(ballDynamicBehavior)
    }
    
    @IBAction func ResumeButtonAction(sender: UIButton) {
        
        resumeButtonOutlet.hidden = true
        collisionBehavior.addItem(ball)
        dynamicAnimator.updateItemUsingCurrentState(ball)
        
        let ballDynamicBehavior = UIDynamicItemBehavior(items: [ball])
        ballDynamicBehavior.friction = 0
        ballDynamicBehavior.resistance = 0
        ballDynamicBehavior.elasticity = 1.0
        ballDynamicBehavior.allowsRotation = false
        dynamicAnimator.addBehavior(ballDynamicBehavior)
        
        let pushBehavior = UIPushBehavior(items: [ball], mode: .Instantaneous)
        pushBehavior.pushDirection = CGVectorMake(0.2, 1.0)
        pushBehavior.magnitude = 0.25
        dynamicAnimator.addBehavior(pushBehavior)
        
    }
    
    // Block Hit sound setup
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
}