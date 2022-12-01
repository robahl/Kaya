//
//  GameScene.swift
//  Kaya
//
//  Created by Robert Ahlberg on 2022-11-24.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    // MARK: - Variables
    private var gameStarted = false
    private var gameOver = false
    private let obstacleWidth = 60
    private let gap = 140
    private let obstacleMoveDuration = 3.5
    
    private var canScore = false
    private var score = 0 {
        didSet {
            scoreLabel.text = String(score)
        }
    }
    
    private lazy var scoreLabel: SKLabelNode = {
        let label = SKLabelNode()
        label.fontSize = 54
        label.text = "0"
        label.position = CGPoint(x: self.size.width / 2, y: self.size.height - 150)
        return label
    }()
    
    private lazy var statusLabel: SKLabelNode = {
        let label = SKLabelNode()
        label.fontSize = 48
        label.text = "TAP TO BEGIN"
        label.fontName = "AvenirNext-Bold"
        label.fontColor = UIColor.yellow
        label.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2 + 40)
        return label
    }()
    
    private lazy var rocket: SKSpriteNode = {
        let rocket = SKSpriteNode(imageNamed: "rocket")
        print("rocket.size \(rocket.size)")
        rocket.physicsBody = SKPhysicsBody(rectangleOf: rocket.size)
        rocket.position = CGPoint(
            x: self.size.width / 2 - rocket.frame.size.width / 2,
            y: self.size.height / 2 - rocket.frame.size.height / 2)
        return rocket
    }()
    
    private lazy var upperObstacle: SKShapeNode = {
        let size = CGSize(width: obstacleWidth, height: Int(self.size.height) / 2 - (gap / 2))
        let obstacle = SKShapeNode(rectOf: size)
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: obstacleWidth, height: Int(self.size.height) / 2 - (gap / 2)))
        obstacle.physicsBody?.isDynamic = false
        obstacle.fillColor = .blue
        obstacle.lineWidth = 0
        
        obstacle.position.x = self.size.width + CGFloat(obstacleWidth)
        obstacle.position.y = self.size.height - obstacle.frame.size.height / 2
        
        return obstacle
    }()
    
    private lazy var lowerObstacle: SKShapeNode = {
        let size = CGSize(width: obstacleWidth, height: Int(self.size.height) / 2 - (gap / 2))
        let obstacle = SKShapeNode(rectOf: size)
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: size)
        obstacle.physicsBody?.isDynamic = false
        obstacle.fillColor = .blue
        obstacle.lineWidth = 0
        
        obstacle.position.x = self.size.width + CGFloat(obstacleWidth)
        obstacle.position.y = 0 + obstacle.frame.size.height / 2
        
        return obstacle
    }()
    
    // MARK: - Lifecycle
    override func sceneDidLoad() {
        physicsWorld.gravity = CGVector(dx: 0, dy: -7)
        physicsWorld.contactDelegate = self
        
        let worldEdge = SKPhysicsBody(edgeLoopFrom: self.frame)
        worldEdge.friction = 0
        worldEdge.restitution = 0
        physicsBody = worldEdge
        
        addChild(scoreLabel)
        addChild(statusLabel)
        
        addChild(rocket)
        
        addChild(upperObstacle)
        addChild(lowerObstacle)
        
        // Setup physics contact
        rocket.physicsBody?.contactTestBitMask = rocket.physicsBody!.collisionBitMask
        
        let openScoreAction = SKAction.run {
            self.canScore = true
        }
        let moveAction = SKAction.moveTo(x: CGFloat(-1 - self.obstacleWidth / 2), duration: obstacleMoveDuration)
        let resetPositionAction = SKAction.run {
            self.upperObstacle.position.x = self.size.width + CGFloat(self.obstacleWidth)
            self.upperObstacle.position.y = self.size.height - self.upperObstacle.frame.size.height / 2
            
            self.lowerObstacle.position.x = self.size.width + CGFloat(self.obstacleWidth)
            self.lowerObstacle.position.y = 0 + self.lowerObstacle.frame.size.height / 2
        }
        
        let sequence = SKAction.sequence([
            openScoreAction,
            moveAction,
            resetPositionAction
        ])
        
        let repeatAction = SKAction.repeatForever(sequence)
        
        upperObstacle.run(repeatAction)
        lowerObstacle.run(repeatAction)
    }
    
    override func didMove(to view: SKView) {
        view.isPaused = true
    }
    
    // MARK: - Game loop
    override func update(_ currentTime: TimeInterval) {
        if (upperObstacle.position.x + upperObstacle.frame.size.width / 2 < rocket.position.x - rocket.frame.size.width / 2) {
            if canScore {
                score += 1
            }
            canScore = false
        }
        
        // Rotate ship according the velocity
        // Reset rotation
        rocket.physicsBody?.angularVelocity = 0
        rocket.zRotation = 0
        let angle = atan2(rocket.physicsBody?.velocity.dy ?? 0, size.width / obstacleMoveDuration)
        let rotateAction = SKAction.rotate(byAngle: angle, duration: 0.7)
        rocket.run(rotateAction)
    }
    
    // MARK: - Input
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !gameStarted && !gameOver {
            view?.isPaused = false
            statusLabel.isHidden = true
        }
        
        rocket.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        rocket.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 28))
        
        super.touchesBegan(touches, with: event)
    }
    
    // MARK: - SKPhysicsContactDelegate
    func didBegin(_ contact: SKPhysicsContact) {
        statusLabel.text = "GAME OVER"
        statusLabel.isHidden = false
        gameOver = true
        view?.isPaused = true
    }
}
