//
//  BattleViewController.swift
//  TechMon
//
//  Created by Yamamoto Miu on 2020/09/19.
//  Copyright © 2020 Yamamoto Miu. All rights reserved.
//

import UIKit

class BattleViewController: UIViewController {
    
    @IBOutlet weak var playerNameLabel: UILabel!
    @IBOutlet weak var playerImageView: UIImageView!
    @IBOutlet weak var playerHPLabel: UILabel!
    @IBOutlet weak var playerMPLabel: UILabel!
    @IBOutlet weak var playerTPLabel: UILabel!
    
    @IBOutlet weak var enemyNameLabel: UILabel!
    @IBOutlet weak var enemyImageView: UIImageView!
    @IBOutlet weak var enemyHPLabel: UILabel!
    @IBOutlet weak var enemyMPLabel: UILabel!
    
    let techMonManager = TechMonManager.shared
    
    var player: Character!
    var enemy: Character!
    
//    var playerHP = 100
//    var playerMP = 0
//    var enemyHP = 200
//    var enemyMP = 0
    
    var gameTimer: Timer!
    var isPlayerAttackAvailable : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //キャラクターの読み込み
        player = techMonManager.player
        enemy = techMonManager.enemy
        
        //プレイヤーのステータスを反映
        playerNameLabel.text = "勇者"
        playerImageView.image = UIImage(named: "yusya.png")
    
        //敵のステータスを反映
        enemyNameLabel.text = "龍"
        enemyImageView.image = UIImage(named: "monster.png")
        
        player.currentHP = player.maxHP
        enemy.currentHP = enemy.maxHP
        
        updateUI()

        //ゲームスタート
        gameTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateGame), userInfo: nil, repeats: true)
        gameTimer.fire()
    }
    
    //画面が見えるようになる時に呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        techMonManager.playBGM(fileName: "BGM_battle001")
    }

    
    //画面が見えなくなる時に呼ばれる
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        techMonManager.stopBGM()
    }
    
    //ステータスの反映
    func updateUI() {
        playerHPLabel.text = "\(player.currentHP) / \(player.maxHP)"
        playerMPLabel.text = "\(player.currentMP) / \(player.maxMP)"
        playerTPLabel.text = "\(player.currentTP) / \(player.maxTP)"
        enemyHPLabel.text = "\(enemy.currentHP) / \(enemy.maxHP)"
        enemyMPLabel.text = "\(enemy.currentMP) / \(enemy.maxMP)"
    }
    
    //0.1秒毎にゲームの状態を更新する
    @objc func updateGame() {
        //プレイヤーのステータスを更新
        player.currentMP += 1
        if player.currentMP >= 20 {
            isPlayerAttackAvailable = true
            player.currentMP = 20
        }else{
            isPlayerAttackAvailable = false
        }
        //敵のステータスを更新
        enemy.currentMP += 1
        if enemy.currentMP >= 35 {
             enemyAttack()
             enemy.currentMP = 0
         }
        
        updateUI()
        
//        playerMPLabel.text = "\(playerMP)/20"
//        enemyMPLabel.text = "\(enemyMP)/35"
    }
    
    //敵の攻撃
    func enemyAttack() {
        
        techMonManager.damageAnimation(imageView: playerImageView)
        techMonManager.playSE(fileName: "SE_attack")
        
        player.currentHP -= 20
        
        if player.currentHP <= 0 {
            finishBattle(vanishImageView: playerImageView, isPlayerWin: false)
        }
        judgeBattle()
    }
    
    //勝敗が決定した時の処理
    func finishBattle(vanishImageView: UIImageView, isPlayerWin: Bool) {
        
        techMonManager.vanishAnimation(imageView: vanishImageView)
        techMonManager.stopBGM()
        gameTimer.invalidate()
        isPlayerAttackAvailable = false
        
        var finishMassage: String = ""
        
        if isPlayerWin {
            techMonManager.playSE(fileName: "SE_fanfare")
            finishMassage = "勇者の勝利！！"
        }else {
            techMonManager.playSE(fileName: "SE_gameover")
            finishMassage = "勇者の敗北..."
        }
        
        let alert = UIAlertController(title: "バトル終了", message: finishMassage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
            self.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated:true, completion: nil)
    }
    
    //攻撃するメソッドをかこう
    @IBAction func attackAction() {
        techMonManager.damageAnimation(imageView: enemyImageView)
        techMonManager.playSE(fileName: "SE_attack")
        
        enemy.currentHP -= player.attackPoint
        
        player.currentTP += 10
        if player.currentTP >= player.maxTP {
            player.currentTP = player.maxTP
        }
        player.currentMP = 0
        
        judgeBattle()
    }
    @IBAction func tameruAction() {
        
        if isPlayerAttackAvailable {
            techMonManager.playSE(fileName: "SE_charge")
            player.currentTP += 40
            
            if player.currentTP >= player.maxTP {
                player.currentTP = player.maxTP
            }
            
            player.currentMP = 0
        }
        
    }
    
    @IBAction func fireAction(){
        
        if isPlayerAttackAvailable && player.currentTP >= 40 {
            
            techMonManager.damageAnimation(imageView: enemyImageView)
            techMonManager.playSE(fileName: "SE_fire")
            
            player.currentTP -= 40
            enemy.currentHP -= 100
            
            if player.currentTP <= 0 {
                player.currentTP = 0
            }
            
            player.currentMP = 0
            judgeBattle()
       
        }
    }
    
    func judgeBattle() {
        if player.currentHP <= 0 {
            finishBattle(vanishImageView: playerImageView, isPlayerWin: false)
        }else if  enemy.currentHP <= 0 {
            finishBattle(vanishImageView: enemyImageView, isPlayerWin: true)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
