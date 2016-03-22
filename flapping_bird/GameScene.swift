//
//  GameScene.swift
//  flapping_bird
//
//  Created by Joey Poon on 3/20/16.
//  Copyright (c) 2016 joeypoon. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var gameActive = false
    var bg = SKSpriteNode()
    var bird = SKSpriteNode()
    var topPipe = SKSpriteNode()
    var bottomPipe = SKSpriteNode()
    
    enum ColliderType: UInt32 {
        case Bird = 1
        case Object = 2
    }
    
    override func didMoveToView(view: SKView) {
        self.speed = 0
        self.physicsWorld.contactDelegate = self
        
        createBg()
        createGround()
        createBird()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if gameActive == false {
            startGame()
        }
        
        //bird movement on tap
        bird.physicsBody!.velocity = CGVectorMake(0, 0)
        bird.physicsBody!.applyImpulse(CGVectorMake(0, 70))
    }
    
    override func update(currentTime: CFTimeInterval) {
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        gameOver()
    }
    
    
    //custom
    func createBg() {
        
        //get texture
        let bgTexture = SKTexture(imageNamed: "bg.png")
        
        //move bg towards left to give scrolling effect
        let moveBg = SKAction.moveByX(-bgTexture.size().width, y: 0, duration: 9)
        
        //move bg back into place after scrolling is done
        let replaceBg = SKAction.moveByX(bgTexture.size().width, y: 0, duration: 0)
        
        //infinite scrolling
        let moveBgForever = SKAction.repeatActionForever(SKAction.sequence([moveBg, replaceBg]))
        
        //create bg 3 times to fill space
        for var i: CGFloat = 0; i < 3; i++ {
            
            //create from texture
            bg = SKSpriteNode(texture: bgTexture)
            
            //position bg
            bg.position = CGPoint(x: bgTexture.size().width/2 + bgTexture.size().width * i, y: CGRectGetMidY(self.frame))
            
            //set height
            bg.size.height = self.frame.height
            
            //add infinite scrolling
            bg.runAction(moveBgForever)
            
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
        let animation = SKAction.animateWithTextures([birdTexture, birdTexture2], timePerFrame: 0.1)
        let makeBirdFlap = SKAction.repeatActionForever(animation)
        bird.runAction(makeBirdFlap)
        
        //add physics
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height/2)
        
        //no gravity until start
        bird.physicsBody!.dynamic = false
        
        //collision detection
        bird.physicsBody!.categoryBitMask = ColliderType.Bird.rawValue
        bird.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        bird.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        
        //set position
        bird.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        
        //force sprite to appear on top
        bird.zPosition = 1
        
        //attach to frame
        self.addChild(bird)
    }
    
    func createGround() {
        
        //create ground
        let ground = SKNode()
        
        //add position
        ground.position = CGPointMake(0, 0)
        
        //add physics
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, 1))
        
        //no gravity
        ground.physicsBody!.dynamic = false
        
        //collision detection
        ground.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        ground.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        ground.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        
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
        let movePipes = SKAction.moveByX(-self.frame.size.width * 2, y: 0, duration: NSTimeInterval(self.frame.size.width / 100))
        let removePipes = SKAction.removeFromParent()
        let pipeMovement = SKAction.sequence([movePipes, removePipes])
        topPipe.runAction(pipeMovement)
        bottomPipe.runAction(pipeMovement)
        
        //position pipes
        topPipe.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) + topPipe.size.height/2 + gapHeight/2 + pipeOffset)
        bottomPipe.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) - bottomPipe.size.height/2 - gapHeight/2 + pipeOffset)
        
        //add physics to pipes
        topPipe.physicsBody = SKPhysicsBody(rectangleOfSize: topPipeTexture.size())
        bottomPipe.physicsBody = SKPhysicsBody(rectangleOfSize: bottomPipeTexture.size())
        
        //remove gravity
        topPipe.physicsBody!.dynamic = false
        bottomPipe.physicsBody!.dynamic = false
        
        //collision detection
        topPipe.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        topPipe.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        topPipe.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        bottomPipe.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        bottomPipe.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        bottomPipe.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        
        //add pipes to frame
        self.addChild(topPipe)
        self.addChild(bottomPipe)

    }
    
    func startGame() {
        gameActive = true
        self.speed = 1
        
        //add gravity
        bird.physicsBody!.dynamic = true
        
        //keep creating pipes
        _ = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: Selector("createPipes"), userInfo: nil, repeats: true)
    }
    
    func gameOver() {
        gameActive = false
        self.speed = 0
        print("Game Over")
    }
}