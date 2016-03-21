//
//  GameScene.swift
//  flapping_bird
//
//  Created by Joey Poon on 3/20/16.
//  Copyright (c) 2016 joeypoon. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var bg = SKSpriteNode()
    var bird = SKSpriteNode()
    var topPipe = SKSpriteNode()
    var bottomPipe = SKSpriteNode()
    
    override func didMoveToView(view: SKView) {
        createBg()
        createGround()
        createBird()
        createPipes()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        bird.physicsBody!.velocity = CGVectorMake(0, 0)
        bird.physicsBody!.applyImpulse(CGVectorMake(0, 40))
    }
    
    override func update(currentTime: CFTimeInterval) {
    }
    
    
    //custom
    func createBg() {
        let bgTexture = SKTexture(imageNamed: "bg.png")
        let moveBg = SKAction.moveByX(-bgTexture.size().width, y: 0, duration: 9)
        let replaceBg = SKAction.moveByX(bgTexture.size().width, y: 0, duration: 0)
        let moveBgForever = SKAction.repeatActionForever(SKAction.sequence([moveBg, replaceBg]))
        
        //create bg 3 times to fill space
        for var i: CGFloat = 0; i < 3; i++ {
            bg = SKSpriteNode(texture: bgTexture)
            bg.position = CGPoint(x: bgTexture.size().width/2 + bgTexture.size().width * i, y: CGRectGetMidY(self.frame))
            bg.size.height = self.frame.height
            bg.runAction(moveBgForever)
            bg.zPosition = -1
            self.addChild(bg)
        }
    }
    
    func createBird() {
        let birdTexture = SKTexture(imageNamed: "flappy1.png")
        let birdTexture2 = SKTexture(imageNamed: "flappy2.png")
        
        let animation = SKAction.animateWithTextures([birdTexture, birdTexture2], timePerFrame: 0.1)
        let makeBirdFlap = SKAction.repeatActionForever(animation)
        
        bird = SKSpriteNode(texture: birdTexture)
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: birdTexture.size().height/2)
        bird.physicsBody!.dynamic = true
        
        bird.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        bird.runAction(makeBirdFlap)
        bird.zPosition = 1
        
        self.addChild(bird)
    }
    
    func createGround() {
        let ground = SKNode()
        ground.position = CGPointMake(0, 0)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, 1))
        ground.physicsBody!.dynamic = false
        self.addChild(ground)
    }
    
    func createPipes() {
        let gapHeight = bird.texture!.size().height * 4
        let movementAmount = arc4random() % UInt32(self.frame.size.height/2)
        let pipeOffset = CGFloat(movementAmount) - self.frame.size.height/4
        
        let topPipeTexture = SKTexture(imageNamed: "pipe1.png")
        let topPipe = SKSpriteNode(texture: topPipeTexture)
        topPipe.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame) + topPipe.size.height/2 + gapHeight/2 + pipeOffset)
        self.addChild(topPipe)
        
        let bottomPipeTexture = SKTexture(imageNamed: "pipe2.png")
        let bottomPipe = SKSpriteNode(texture: bottomPipeTexture)
        bottomPipe.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame) - bottomPipe.size.height/2 - gapHeight/2 + pipeOffset)
        self.addChild(bottomPipe)
    }
}
