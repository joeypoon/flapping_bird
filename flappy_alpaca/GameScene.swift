//
//  GameScene.swift
//  flapping_bird
//
//  Created by Joey Poon on 3/20/16.
//  Copyright (c) 2016 joeypoon. All rights reserved.
//

import SpriteKit
import GameKit
import GoogleMobileAds

class GameScene: SKScene, SKPhysicsContactDelegate, GKGameCenterControllerDelegate {
    
    var gameActive = false
    var gameOver = false
    var bg = SKSpriteNode()
    var bird = SKSpriteNode()
    var topPipe = SKSpriteNode()
    var bottomPipe = SKSpriteNode()
    var score = 0
    var scoreLabel = SKLabelNode()
    var gameOverLabel = SKLabelNode()
    var oldPipes = SKSpriteNode()
    var interstitial: GADInterstitial!
    
    enum ColliderType: UInt32 {
        case bird = 1
        case object = 2
        case pipeGap = 4
    }
    
    override func didMove(to view: SKView) {
        self.speed = 0
        self.physicsWorld.contactDelegate = self
        
        createBg()
        createGround()
        createBird()
        createScoreLabel()
        createPipes()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !gameActive {
            startGame()
        } else {
            //bird movement on tap
            bird.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
            bird.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 70))
        }
        
        if gameOver {
            restartGame()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == ColliderType.pipeGap.rawValue || contact.bodyB.categoryBitMask == ColliderType.pipeGap.rawValue {
            score += 1
            scoreLabel.text = String(score)
            removePipes()
            createPipes()
        } else {
            if !gameOver {
                gameEnd()
            }
        }
    }
    
    
    //custom
    func createBg() {
        
        //get texture
        let bgTexture = SKTexture(imageNamed: "bg.png")
        
        //move bg towards left to give scrolling effect
        let moveBg = SKAction.moveBy(x: -bgTexture.size().width, y: 0, duration: 9)
        
        //move bg back into place after scrolling is done
        let replaceBg = SKAction.moveBy(x: bgTexture.size().width, y: 0, duration: 0)
        
        //infinite scrolling
        let moveBgForever = SKAction.repeatForever(SKAction.sequence([moveBg, replaceBg]))
        
        //create bg 3 times to fill space
        for i in 0..<3 {
            //create from texture
            bg = SKSpriteNode(texture: bgTexture)
            
            //position bg
            bg.position = CGPoint(x: bgTexture.size().width/2 + bgTexture.size().width * CGFloat(i), y: self.frame.midY)
            
            //set height
            bg.size.height = self.frame.height
            
            //add infinite scrolling
            bg.run(moveBgForever)
            
            //set as bg
            bg.zPosition = -1
            
            //attach to frame
            self.addChild(bg)
        }
    }
    
    func createBird() {
        
        //create from texture
        let birdTexture = SKTexture(imageNamed: "flappy1.png")
        let birdTexture2 = SKTexture(imageNamed: "flappy2.png")
        bird = SKSpriteNode(texture: birdTexture)
        
        //animations
        let animation = SKAction.animate(with: [birdTexture, birdTexture2], timePerFrame: 0.1)
        let makeBirdFlap = SKAction.repeatForever(animation)
        bird.run(makeBirdFlap)
        
        //add physics
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height/3)
        
        //no gravity until start
        bird.physicsBody!.isDynamic = false
        
        //collision detection
        bird.physicsBody!.categoryBitMask = ColliderType.bird.rawValue
        bird.physicsBody!.contactTestBitMask = ColliderType.object.rawValue
        bird.physicsBody!.collisionBitMask = ColliderType.object.rawValue
        
        //set position
        bird.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        
        //force sprite to appear on top
        bird.zPosition = 1
        
        //attach to frame
        self.addChild(bird)
    }
    
    func createGround() {
        
        //create ground
        let ground = SKNode()
        
        //add position
        ground.position = CGPoint(x: 0, y: 0)
        
        //add physics
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.size.width, height: 1))
        
        //no gravity
        ground.physicsBody!.isDynamic = false
        
        //collision detection
        ground.physicsBody!.categoryBitMask = ColliderType.object.rawValue
        ground.physicsBody!.contactTestBitMask = ColliderType.object.rawValue
        ground.physicsBody!.collisionBitMask = ColliderType.object.rawValue
        
        //attach to frame
        self.addChild(ground)
    }
    
    func createPipes() {
        //create pipes from texture
        let topPipeTexture = SKTexture(imageNamed: "pipe1.png")
        let topPipe = SKSpriteNode(texture: topPipeTexture)
        
        let bottomPipeTexture = SKTexture(imageNamed: "pipe2.png")
        let bottomPipe = SKSpriteNode(texture: bottomPipeTexture)
        
        //make distance between pipes 4x bird size
        let gapHeight = bird.texture!.size().height * 4
        
        //random vertical points for pipes
        let movementAmount = arc4random() % UInt32(self.frame.size.height/2)
        let pipeOffset = CGFloat(movementAmount) - self.frame.size.height/4
        
        //move pipes between scenes
        let movePipes = SKAction.moveBy(x: -self.frame.size.width * 2, y: 0, duration: TimeInterval(self.frame.size.width / 100))
        let removePipes = SKAction.removeFromParent()
        let pipeMovement = SKAction.sequence([movePipes, removePipes])
        topPipe.run(pipeMovement)
        bottomPipe.run(pipeMovement)
        
        //position pipes
        topPipe.position = CGPoint(x: self.frame.midX + self.frame.size.width, y: self.frame.midY + topPipe.size.height/2 + gapHeight/2 + pipeOffset)
        bottomPipe.position = CGPoint(x: self.frame.midX + self.frame.size.width, y: self.frame.midY - bottomPipe.size.height/2 - gapHeight/2 + pipeOffset)
        
        //add physics to pipes
        topPipe.physicsBody = SKPhysicsBody(rectangleOf: topPipeTexture.size())
        bottomPipe.physicsBody = SKPhysicsBody(rectangleOf: bottomPipeTexture.size())
        
        //remove gravity
        topPipe.physicsBody!.isDynamic = false
        bottomPipe.physicsBody!.isDynamic = false
        
        //collision detection
        topPipe.physicsBody!.categoryBitMask = ColliderType.object.rawValue
        topPipe.physicsBody!.contactTestBitMask = ColliderType.object.rawValue
        topPipe.physicsBody!.collisionBitMask = ColliderType.object.rawValue
        bottomPipe.physicsBody!.categoryBitMask = ColliderType.object.rawValue
        bottomPipe.physicsBody!.contactTestBitMask = ColliderType.object.rawValue
        bottomPipe.physicsBody!.collisionBitMask = ColliderType.object.rawValue
        
        //add pipes to frame
        self.addChild(topPipe)
        self.addChild(bottomPipe)
        
        //create score gap
        let gap = SKNode()
        
        //center between pipes
        gap.position = CGPoint(x: self.frame.midX + self.frame.size.width, y: self.frame.midY + pipeOffset)
        gap.run(pipeMovement)
        
        //physics
        gap.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: topPipe.size.width/10, height: gapHeight))
        
        //no gravity
        gap.physicsBody!.isDynamic = false
        
        //collision detection
        gap.physicsBody!.categoryBitMask = ColliderType.pipeGap.rawValue
        gap.physicsBody!.contactTestBitMask = ColliderType.bird.rawValue
        gap.physicsBody!.collisionBitMask = ColliderType.pipeGap.rawValue
        
        self.addChild(gap)
    }
    
    func createScoreLabel() {
        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontSize = 60
        scoreLabel.fontColor = UIColor.orange
        scoreLabel.text = "0"
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.size.height - 70)
        scoreLabel.zPosition = 1
        self.addChild(scoreLabel)
    }
    
    func createGameOverLabel() {
        gameOverLabel.fontName = "Helvetica"
        gameOverLabel.fontSize = 30
        gameOverLabel.fontColor = UIColor.orange
        gameOverLabel.text = "Game Over. Tap to restart."
        gameOverLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        gameOverLabel.zPosition = 100
        self.addChild(gameOverLabel)
    }
    
    func removePipes() {
        topPipe.removeFromParent()
        bottomPipe.removeFromParent()
    }
    
    func saveHighScore(_ score: Int) {
        if GKLocalPlayer.localPlayer().isAuthenticated {
            let scoreReporter = GKScore(leaderboardIdentifier: "")
            scoreReporter.value = Int64(score)
            let scoreArray: [GKScore] = [scoreReporter]
            GKScore.report(scoreArray)
        }
    }
    
    func showLeaderBoard() {
        let vc = self.view?.window?.rootViewController
        let gc = GKGameCenterViewController()
        gc.gameCenterDelegate = self
        vc?.present(gc, animated: true, completion: nil)
    }
    
    //called when game center interface closed
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
    }
    
    func startGame() {
        requestAd()
        if !gameOver {
            
            gameActive = true
            self.speed = 1
            
            
            //add gravity
            bird.physicsBody!.isDynamic = true
        }
    }
    
    func gameEnd() {
        self.speed = 0
        createGameOverLabel()
        gameActive = false
        gameOver = true
        createAndLoadInterstitial()
    }
    
    func restartGame() {
        self.removeAllChildren()
        score = 0
        createBg()
        createGround()
        createBird()
        createScoreLabel()
        createPipes()
        gameOver = false
    }
    
    private func requestAd() {
        
    }
    
    private func createAndLoadInterstitial() {
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
        let request = GADRequest()
        interstitial.load(request)
    }
}
