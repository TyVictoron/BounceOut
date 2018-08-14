//
//  ViewController2.swift
//  BounceOut
//
//  Created by Ty on 3/30/15.
//  Copyright (c) 2015 TyGames. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController2: UIViewController, UICollisionBehaviorDelegate {
    
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
        
        //Score set up
        scoreLabel.text = "Score: \(score)"
        score = 0
        
        //Hides ResumeButton
        resumeButtonOutlet.isHidden = true
        
        // Add background
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "BounceOutBackground.png")!)
        
        // add a ball object to the view
        ball = UIView(frame: CGRect(x: view.center.x, y: view.center.y, width: 20, height: 20))
        ball.backgroundColor = UIColor.white
        ball.layer.cornerRadius = 10
        ball.clipsToBounds = true
        view.addSubview(ball)
        
        // add a red paddle object to the view
        paddle = UIView(frame: CGRect(x: view.center.x, y: view.center.y * 1.7, width: 80, height: 20))
        paddle.backgroundColor = UIColor.red
        view.addSubview(paddle)
        
        dynamicAnimator = UIDynamicAnimator(referenceView: view)
        
        // Set up bricks
        let width = (Int)(view.bounds.size.width - 40)
        let xOffset = ((Int)(view.bounds.size.width) % 42) / 2
        
        for x in stride(from: xOffset, to: width, by: 42) {addBlock(x: x, y:  40, color: UIColor.blue)}
        for x in stride(from: xOffset, to: width, by: 42) {addBlock(x: x, y:  62, color: UIColor.blue)}
        for x in stride(from: xOffset, to: width, by: 42) {addBlock(x: x, y:  84, color: UIColor.yellow)}
        for x in stride(from: xOffset, to: width, by: 42) {addBlock(x: x, y:  106, color: UIColor.yellow)}
        for x in stride(from: xOffset, to: width, by: 42) {addBlock(x: x, y:  128, color: UIColor.blue)}
        
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
        let pushBehavior = UIPushBehavior(items: [ball], mode: .instantaneous)
        pushBehavior.pushDirection = CGVector(dx: 0.2, dy: 1.0)
        pushBehavior.magnitude = 0.25
        dynamicAnimator.addBehavior(pushBehavior)
        
        //creat collision behaviors so ball can bounce off other objects
        collisionBehavior = UICollisionBehavior(items: allObjects)
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        collisionBehavior.collisionMode = .everything
        collisionBehavior.collisionDelegate = self
        dynamicAnimator.addBehavior(collisionBehavior)
        
        textLabel.text = "Lives: \(lives)"
        
        blockHit = self.setupAudioPlayerWithFile(file: "BlockHit", type:"wav")
        loseLife = self.setupAudioPlayerWithFile(file: "loseLife", type:"wav")
    }
    
    @IBAction func dragPaddle(sender: UIPanGestureRecognizer) {
        let panGesture = sender.location(in: view)
        paddle.center = CGPoint(x: panGesture.x, y: paddle.center.y)
        dynamicAnimator.updateItem(usingCurrentState: paddle)
    }
    
    // collision behavior deligate method (with boundary)
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, at p: CGPoint) {
        if item.isEqual(ball) && p.y > paddle.center.y {
            lives-=1
            loseLife.play()
            if lives > 0 {
                textLabel.text = "Lives: \(lives)"
                ball.center = view.center
                dynamicAnimator.updateItem(usingCurrentState: ball)
            }
            else {
                textLabel.text = "Game Over!"
                ball.removeFromSuperview()
                collisionBehavior.removeItem(ball)
                resetGame(winLossText: "Game Over!")
            }
        }
    }
    
    // collision behavior delegate method (with another object)
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item1: UIDynamicItem, with item2: UIDynamicItem, at p: CGPoint) {
        _ = UIView()
        var hiddenBlockCount = 0
        for block in bricks {
            if item1.isEqual(ball) && item2.isEqual(block) {
                if block.backgroundColor == UIColor.blue {
                    block.backgroundColor = UIColor.yellow
                    scoreLabel.text = "Score: \(score+=1)"
                    blockHit.play()
                }
                else {
                    block.isHidden = true
                    collisionBehavior.removeItem(block)
                    scoreLabel.text = "Score: \(score+=1)"
                    blockHit.play()
                }
            }
            if block.isHidden == true {
                hiddenBlockCount+=1
            }
        }
        if hiddenBlockCount == bricks.count {
            resetGame(winLossText: "You Win!")
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
        ball.isHidden = true
        paddle.isHidden = true
        collisionBehavior.removeItem(ball)
        dynamicAnimator.updateItem(usingCurrentState: ball)
        collisionBehavior.removeItem(paddle)
        dynamicAnimator.updateItem(usingCurrentState: paddle)
        ball.removeFromSuperview()
        
        // Reset button / exit to menu
        let alert = UIAlertController(title: winLossText, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        
        let playAgainAction = UIAlertAction(title: "Play Again", style: UIAlertActionStyle.default) { (action) -> Void in
            self.viewDidLoad()
        }
        
        alert.addAction(playAgainAction)
        self.present(alert, animated: true, completion: nil)
        
        let quitAction = UIAlertAction(title: "Quit", style: UIAlertActionStyle.destructive) { (action) -> Void in
            if let resultController = self.storyboard?.instantiateViewController(withIdentifier: "MenuID") as? MenuViewController {
                self.present(resultController, animated: true, completion: nil)
            }
        }
        alert.addAction(quitAction)
    }
    
    // check for all blocks hidden
    func addBlock(x: Int, y: Int, color: UIColor) {
        let block = UIView(frame: CGRect(x: (CGFloat)(x), y: (CGFloat)(y), width: 40, height: 20))
        block.backgroundColor = color
        view.addSubview(block)
        bricks.append(block)
        allObjects.append(block)
    }
    
    @IBAction func pauseButton(sender: UIButton) {
        resumeButtonOutlet.isHidden = false
        
        let ballDynamicBehavior = UIDynamicItemBehavior(items: [ball])
        ballDynamicBehavior.friction = 0
        ballDynamicBehavior.resistance = 100
        ballDynamicBehavior.elasticity = 1.0
        ballDynamicBehavior.allowsRotation = false
        dynamicAnimator.addBehavior(ballDynamicBehavior)
    }
    
    @IBAction func ResumeButtonAction(sender: UIButton) {
        
        resumeButtonOutlet.isHidden = true
        collisionBehavior.addItem(ball)
        dynamicAnimator.updateItem(usingCurrentState: ball)
        
        let ballDynamicBehavior = UIDynamicItemBehavior(items: [ball])
        ballDynamicBehavior.friction = 0
        ballDynamicBehavior.resistance = 0
        ballDynamicBehavior.elasticity = 1.0
        ballDynamicBehavior.allowsRotation = false
        dynamicAnimator.addBehavior(ballDynamicBehavior)
        
        let pushBehavior = UIPushBehavior(items: [ball], mode: .instantaneous)
        pushBehavior.pushDirection = CGVector(dx: 0.2, dy: 1.0)
        pushBehavior.magnitude = 0.25
        dynamicAnimator.addBehavior(pushBehavior)
        
    }
    
    // Block Hit sound setup
    func setupAudioPlayerWithFile(file:NSString, type:NSString) -> AVAudioPlayer  {
        //1
        let path = Bundle.main.path(forResource: file as String, ofType:type as String)
        let url = NSURL.fileURL(withPath: path!)
        
        //2
        var _: NSError?
        
        //3
        var audioPlayer:AVAudioPlayer?
        
        do { audioPlayer = try AVAudioPlayer(contentsOf: url)}
        catch { print("sadness") }
        
        //4
        return audioPlayer!
    }
}
