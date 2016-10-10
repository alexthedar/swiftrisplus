//
//  HomeViewController.swift
//  SwifttrisPlus
//
//  Created by Alexandar on 8/2/16.
//  Copyright © 2016 Alexandar. All rights reserved.
//

import UIKit
import GameKit

class HomeViewController: UIViewController, GKGameCenterControllerDelegate {
    
    var achievements: [GKAchievement]?


    @IBAction func leadersButton(sender: AnyObject) {
        showLeaderBoard()
    }
    @IBAction func achievementsButton(sender: AnyObject) {
        print("achievements")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        authenticateLocalPlayer()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let viewController: GameViewController = (segue.destinationViewController as? GameViewController)!
        
        if self.achievements != nil {
            viewController.achievements = self.achievements!
        }
        if(segue.identifier == "timedGame"){
            viewController.defaultTimer = 120
        } else if (segue.identifier == "endlessGame"){
            viewController.defaultTimer = 0
        }
    }
    
    func authenticateLocalPlayer(){
        var localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {(viewController, error) -> Void in
            if ((viewController) != nil) {
                self.presentViewController(viewController!, animated: true, completion: nil)
            }else{
                print("(GameCenter) Player authenticated: \(GKLocalPlayer.localPlayer().authenticated) error:\(error)")
            }
        }
    }
    
    func showLeaderBoard() {
        let gameCenterVC = GKGameCenterViewController()
        gameCenterVC.gameCenterDelegate = self
        gameCenterVC.viewState = GKGameCenterViewControllerState.Leaderboards
        gameCenterVC.leaderboardTimeScope = GKLeaderboardTimeScope.AllTime
        gameCenterVC.leaderboardIdentifier = "topScores"
        self.presentViewController(gameCenterVC, animated: true, completion: nil)
    }
    
    @IBAction func achievementButtonPressed() {
        showAchievements()
    }
    
    func showAchievements() {
        let gameCenterVC = GKGameCenterViewController()
        gameCenterVC.gameCenterDelegate = self
        gameCenterVC.viewState = GKGameCenterViewControllerState.Achievements
        self.presentViewController(gameCenterVC, animated: true, completion: nil)
    }
    
    
    func loadPreExistingAchievements() {
        GKAchievement.loadAchievementsWithCompletionHandler({ (achievements, error) -> Void in
            if let achievements = achievements as [GKAchievement]! {
                self.achievements = achievements
                print("Successfully downloaded your past achievements")
                

            } else if (achievements == nil) {
                print("This player has not made any progress towards any achievements, and we should initialize some achievements for them to do")
                self.achievements = []
                
                for (achievementID, _) in GameAchievements().allAchievements {
                    self.achievements!.append(GKAchievement.init(identifier: achievementID))
                }
                
                print("\(self.achievements)")
                
            } else {
                print("There was an error downloading previous achievements: \(error?.description)")
            }
        })
    }
    
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
