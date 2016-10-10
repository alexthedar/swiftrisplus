//
//  GameViewController.swift
//  SwifttrisPlus
//
//  Created by Alexandar on 7/31/16.
//  Copyright (c) 2016 Alexandar. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit

 class GameViewController: UIViewController, SwiftrisDelegate, UIGestureRecognizerDelegate {

    var scene: GameScene!
    var swiftris:Swiftris!
    var panPointReference:CGPoint?
    
    var timerDisplay: TimerDisplay!
    var gameTimer: NSTimer!
    var defaultTimer: Int = 5
    
    var achievements: [GKAchievement] = []
    
    @IBOutlet weak var timeRemainingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let skView = view as! SKView
        
        skView.multipleTouchEnabled = false
        
        scene = GameScene(size: skView.bounds.size)
        
        scene.scaleMode = .AspectFill
        scene.tick = didTick
        setupTimer()
        swiftris = Swiftris()
        swiftris.delegate = self

        swiftris.beginGame()
        
        skView.presentScene(scene)
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    func didTick() {
        swiftris.letShapeFall()

    }
    func nextShape() {
        let newShapes = swiftris.newShape()
        guard let fallingShape = newShapes.fallingShape else {
            return
        }
        self.scene.addPreviewShapeToScene(newShapes.nextShape!) {}
        self.scene.movePreviewShape(fallingShape) {
            self.view.userInteractionEnabled = true
            self.scene.startTicking()
        }
    }
    
    func gameDidBegin(swiftris: Swiftris) {
        if defaultTimer > 0 {
            startTimer()
        }
        levelLabel.text = "\(swiftris.level)"
        scoreLabel.text = "\(swiftris.score)"
        scene.tickLengthMillis = TickLengthLevelOne
        // The following is false when restarting a new game
        if swiftris.nextShape != nil && swiftris.nextShape!.blocks[0].sprite == nil {
            scene.addPreviewShapeToScene(swiftris.nextShape!) {
                self.nextShape()
            }
        } else {
            nextShape()
        }
    }
    
    func gameDidEnd(swiftris: Swiftris) {
        view.userInteractionEnabled = false
        scene.stopTicking()
        if defaultTimer > 0 {
            stopTimer()
        }
        scene.playSound("gameover.mp3")
        scene.animateCollapsingLines(swiftris.removeAllBlocks(), fallenBlocks: swiftris.removeAllBlocks()) {
            swiftris.beginGame()
            if self.defaultTimer > 0 {
                self.stopTimer()
            }

        }

    }
    
    func gameDidLevelUp(swiftris: Swiftris) {
        levelLabel.text = "\(swiftris.level)"
        if scene.tickLengthMillis >= 100 {
            scene.tickLengthMillis -= 100
        } else if scene.tickLengthMillis > 50 {
            scene.tickLengthMillis -= 50
        }
        scene.playSound("levelup.mp3")

        
    }
    
    func gameShapeDidDrop(swiftris: Swiftris) {
        scene.stopTicking()
        scene.redrawShape(swiftris.fallingShape!) {
            swiftris.letShapeFall()
        }
        scene.playSound("drop.mp3")

        
    }
    
    func gameShapeDidLand(swiftris: Swiftris) {
        scene.stopTicking()
        self.view.userInteractionEnabled = false
        // #10
        let removedLines = swiftris.removeCompletedLines()
        if removedLines.linesRemoved.count > 0 {
            self.scoreLabel.text = "\(swiftris.score)"
            scene.animateCollapsingLines(removedLines.linesRemoved, fallenBlocks:removedLines.fallenBlocks) {
                // #11
                self.gameShapeDidLand(swiftris)
            }
            scene.playSound("bomb.mp3")
        } else {
            nextShape()
        }
    }
    
    // #17
    func gameShapeDidMove(swiftris: Swiftris) {
        scene.redrawShape(swiftris.fallingShape!) {}
    }

    @IBOutlet weak var gameTypeLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBAction func didSwipe(sender: UISwipeGestureRecognizer) {
        swiftris.dropShape()

    }
    @IBAction func didTap(sender: UITapGestureRecognizer) {
        swiftris.rotateShape()
    }
    @IBAction func didPan(sender: UIPanGestureRecognizer) {
        let currentPoint = sender.translationInView(self.view)
        if let originalPoint = panPointReference {
            // #3
            if abs(currentPoint.x - originalPoint.x) > (BlockSize * 0.9) {
                // #4
                if sender.velocityInView(self.view).x > CGFloat(0) {
                    swiftris.moveShapeRight()
                    panPointReference = currentPoint
                } else {
                    swiftris.moveShapeLeft()
                    panPointReference = currentPoint
                }
            }
        } else if sender.state == .Began {
            panPointReference = currentPoint
        }
    }
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // #6
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UISwipeGestureRecognizer {
            if otherGestureRecognizer is UIPanGestureRecognizer {
                return true
            }
        } else if gestureRecognizer is UIPanGestureRecognizer {
            if otherGestureRecognizer is UITapGestureRecognizer {
                return true
            }
        }
        return false
    }
    
    func setupTimer() {
        if ( defaultTimer > 0 ) {
            timerDisplay = TimerDisplay(timeInSeconds: defaultTimer)
            self.gameTimer = NSTimer(timeInterval: 1.0, target: self, selector: #selector(GameViewController.updateCurrentTimeLeft), userInfo: nil, repeats: true)
        } else {
            timerDisplay = TimerDisplay(endlessGame: true)
        }
        
        updateTimeLabel(timerDisplay.timeAsString())
    }
    
    func startTimer() {
        NSRunLoop.mainRunLoop().addTimer(self.gameTimer, forMode: NSRunLoopCommonModes)
    }
    
    func stopTimer() {
        self.gameTimer.invalidate()
    }
    
    func updateCurrentTimeLeft() {
        if timerDisplay.timeInSeconds >= 1 {
            timerDisplay.timeInSeconds -= 1
            updateTimeLabel(timerDisplay.timeAsString())
        } else {
            updateTimeLabel("Game Over")
            swiftris.endGame()
        }
    }
    
    func updateTimeLabel(timeLeftString: String) {
        timeRemainingLabel.text = timeLeftString
    }
    
    func gameDidBreakBlocks(rowsBroken: Int) {
        
        for achievement in achievements where achievement.completed != true {
            achievement.percentComplete += ( 100 * Double(rowsBroken) / Double(GameAchievements().allAchievements[achievement.identifier!]!) )
        }
        
        recordAchievements()
    }
    

    
    func reportScoresToGameCenter() {
        if GKLocalPlayer.localPlayer().authenticated {
            let gkScore = GKScore(leaderboardIdentifier: "topScores")
            gkScore.value = Int64(swiftris.score)
            GKScore.reportScores([gkScore]) { (error) -> Void in
                if (error != nil) {
                    print("Error reporting scores: \(error!.description)")
                } else {
                    print("Top Score of \(gkScore.value) reported successfully to Game Center")
                }
            }
        }
    }
    
    func recordAchievements() {
        let achievement = GKAchievement(identifier: "achievement.9890")
        achievement.showsCompletionBanner = true
        print("Attempting to update achievements: \(achievements)")
        
        GKAchievement.reportAchievements(achievements) { (error) -> Void in
            if (error != nil) {
                print("Error updating achievements: \(error?.description)")
            }
        }
    }


}
