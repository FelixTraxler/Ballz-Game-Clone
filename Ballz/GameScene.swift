//
//  GameScene.swift
//  Ballz
//
//  Created by Felix Traxler on 14.09.18.
//  Copyright © 2018 Felix Traxler. All rights reserved.
//

import SpriteKit
import GameplayKit

typealias Milliseconds = Double

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private enum GameState {
        case Paused, Playing, GameOver
    }
    
    let player = Player()
    let ball = Ball()
    
    private var gameState = GameState.Paused {
        didSet {
            if gameState == .Playing {
                NSCursor.hide()
            } else if gameState == .GameOver {
                NSCursor.unhide()
            }
        }
    }
    
    private var lastUpdateTime: TimeInterval = 0
    private var mouseLocation: CGPoint?
    
    private var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
            scoreLabel.position = CGPoint(x: scoreLabel.frame.width / 2 + 16, y: frame.maxY - scoreLabel.frame.height - 16)
        }
    }

    private var backgroundNode = SKShapeNode()
    private var currentHue: CGFloat = 0.5

    private let scoreLabel = SKLabelNode(text: "Score: 0")
    private let startGameLabel = SKLabelNode(text: "Click to start")
    
    override func didMove(to view: SKView) {
        
        createBackground()
        
        setupPhysics()
        createObstacles()
        
        setupScoreLabel()
        
        let startFont = NSFont.systemFont(ofSize: 40, weight: .bold)
        startGameLabel.fontName = startFont.fontName
        startGameLabel.fontSize = startFont.pointSize
        startGameLabel.color = .white
        startGameLabel.zPosition = 110
        startGameLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        
        addChild(startGameLabel)
        
        player.position = CGPoint(x: frame.midX, y: frame.minY + Player.Size.height + 20)
        ball.position = CGPoint(x: frame.midX, y: frame.midY - 100)
        
        addChild(player)
        addChild(ball)
    }
    
    private func createBackground() {
        let color1 = CIColor(red: 115.0 / 255.0, green: 97.0 / 255.0, blue: 250.0 / 255.0)
        let color2 = CIColor(red: 37.0 / 255.0, green: 6.0 / 255.0, blue: 142.0 / 255.0)
        
        let texture = SKTexture(size: size, color1: color1, color2: color2)
        texture.filteringMode = .linear
        let sprite = SKSpriteNode(texture: texture)
        sprite.position = CGPoint(x: frame.midX, y: frame.midY)
        sprite.zPosition = -100
        //addChild(sprite)
        
        backgroundNode = SKShapeNode(rect: frame)
        backgroundNode.lineWidth = 0.0
        backgroundNode.fillColor = NSColor(hue: currentHue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
        backgroundNode.zPosition = -100
        
        addChild(backgroundNode)
    }
    
    private func setupPhysics() {
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame.insetBy(dx: -1, dy: -1))
        
        physicsBody!.categoryBitMask    = PhysicsCategory.World
        physicsBody!.collisionBitMask   = PhysicsCategory.None
        physicsBody!.contactTestBitMask = PhysicsCategory.Ball
        physicsBody!.friction = 0.0
        physicsBody!.linearDamping = 0.0
        physicsBody!.restitution = 1.0
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        createGroundNode()
    }
    
    private func createGroundNode() {
        let groundNode = SKNode()
        groundNode.position = .zero
        
        groundNode.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: 0, y: frame.minY + 1),
                                               to: CGPoint(x: frame.maxX, y: frame.minY + 1))
        groundNode.physicsBody!.categoryBitMask = PhysicsCategory.Ground
        groundNode.physicsBody!.contactTestBitMask = PhysicsCategory.Ball
        
        addChild(groundNode)
    }
    
    private func createObstacles() {
        let randomPoints = randomObstaclePoints(obstacles: 10)
        
        for randomPoint in randomPoints {
            let obstacle = Obstacle()
            obstacle.position = randomPoint
            obstacle.name = "Obstacle"
            obstacle.noLivesLeft = { [unowned self] in
                self.score += 50
                
                var obstaclesLeft = false
                self.enumerateChildNodes(withName: "Obstacle", using: { (obstacleNode, stop) in
                    obstaclesLeft = true
                    stop[0] = true
                })
                
                if !obstaclesLeft {
                    self.gameOver(won: true)
                }
            }
            addChild(obstacle)
        }
    }
    
    private func setupScoreLabel() {
        let scoreFont = NSFont.systemFont(ofSize: 30, weight: .medium)
        scoreLabel.fontName = scoreFont.fontName
        scoreLabel.fontSize = scoreFont.pointSize
        scoreLabel.fontColor = .white
        scoreLabel.zPosition = -1
        scoreLabel.position = CGPoint(x: scoreLabel.frame.width / 2 + 16, y: frame.maxY - scoreLabel.frame.height - 16)
        
        addChild(scoreLabel)
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
            return
        }
        
        let delta: Milliseconds = (currentTime - lastUpdateTime) * 1000
        lastUpdateTime = currentTime
        
        mouseLocation = CGPoint(x: NSEvent.mouseLocation.x - (view?.window?.frame.minX ?? 0) - scene!.frame.minX, y: 0)
        
        player.move(until: mouseLocation?.x ?? player.frame.midX)
        
        if gameState == .Playing {
            updateBackground(delta)
            player.update(delta)
            ball.update(delta)
        }
    }
    
    private func updateBackground(_ delta: Milliseconds) {
        currentHue += CGFloat(delta / 2000.0)
        
        if currentHue > 1 {
            currentHue -= 1
        }
        
        backgroundNode.fillColor = NSColor(hue: currentHue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
    }
    
    override func mouseUp(with event: NSEvent) {
        if gameState == .Paused {
            
            gameState = .Playing
            
            startGameLabel.removeFromParent()
            
            let action = SKAction.sequence([SKAction.wait(forDuration: 2.0),
                                            SKAction.run { [weak self] in
                                                self?.applyRandomBallImpulse()
                                            }])
            
            run(action)
            
        } else if gameState == .GameOver {
            startNewGame()
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if contactMask == PhysicsCategory.Ball | PhysicsCategory.Ground {
            gameOver(won: false)
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if contactMask == PhysicsCategory.Ball | PhysicsCategory.Obstacle {
            let obstacle = [contact.bodyA.node, contact.bodyB.node].filter({ $0 is Obstacle })[0] as! Obstacle
            obstacle.wasHit()
        }
    }
    
    private func applyRandomBallImpulse() {
        let randomDirection = CGVector(dx: CGFloat.random(in: -1...1), dy: 1).normalized()
        let randomVector = randomDirection * 25
        
        ball.physicsBody?.applyImpulse(randomVector)
    }
    
    private func gameOver(won: Bool) {
        gameState = .GameOver
        ball.physicsBody?.isDynamic = false
        
        let labelText = won ? "You won! Score: \(score)" : "You Lost! Score: \(score)"
        let label = SKLabelNode(text: labelText)
        let label2 = SKLabelNode(text: "Click to start a new Game")
        let font = NSFont.systemFont(ofSize: 50, weight: .bold)
        let font2 = NSFont.systemFont(ofSize: 30, weight: .semibold)
        
        [(label, font), (label2, font2)].forEach { (labelNode, chosenFont) in
            labelNode.fontName = chosenFont.fontName
            labelNode.fontSize = chosenFont.pointSize
            labelNode.fontColor = NSColor.black
            labelNode.addShadow()
            labelNode.zPosition = 100
        }
        
        let backgroundSize = CGSize(width: 530, height: 150)
        let textBackground = SKShapeNode(rect: CGRect(origin: CGPoint(x: frame.midX - backgroundSize.width / 2,
                                                                      y: frame.midY - backgroundSize.height / 2 + 20),
                                                      size: backgroundSize))
        textBackground.fillColor = .white
        textBackground.lineWidth = 0
        textBackground.zPosition = 50
        textBackground.roundCorners(radius: 14)
        addChild(textBackground)
        
        label.position = CGPoint(x: textBackground.frame.midX, y: textBackground.frame.midY + 10)
        label2.position = CGPoint(x: textBackground.frame.midX, y: textBackground.frame.midY - 50)
        
        textBackground.addChild(label)
        textBackground.addChild(label2)
        
        textBackground.alpha = 0.0
        
        let animation = SKAction.group([SKAction.fadeIn(withDuration: 0.3),
                                        SKAction.move(by: CGVector(dx: 0, dy: -50), duration: 0.3)])
        textBackground.position.y += 50
        
        textBackground.run(animation)
    }
    
    private func startNewGame() {
        let newScene = GameScene(size: size)
        newScene.scaleMode = scaleMode
        
        let transition = SKTransition.reveal(with: SKTransitionDirection.down, duration: 1.0)
        
        view?.presentScene(newScene, transition: transition)
    }
    
    private func createObstacleGrid(columns: Int, rows: Int) -> [[CGPoint]] {
        var points = [[CGPoint]]()
        
        for _ in 0..<columns {
            points.append([CGPoint]())
        }
        
        let horizontalSpacing = frame.width / CGFloat(2 * columns + 2)
        let verticalSpacing = (frame.height * (2 / 3)) / CGFloat(rows + 2)
        
        for column in 0..<columns {
            for row in 0..<rows {
                let point = CGPoint(x: horizontalSpacing * CGFloat(2 * column + 2),
                                    y: verticalSpacing   * CGFloat(row + 2) + (frame.height * (1 / 3)))
                points[column].append(point)
            }
        }
        
        return points
    }
    
    private func randomObstaclePoints(obstacles: Int) -> [CGPoint] {
        let grid = createObstacleGrid(columns: 5, rows: 3)
        
        var allPoints = [CGPoint]()
        
        for column in grid {
            allPoints.append(contentsOf: column)
        }
        
        allPoints.shuffle()
        
        if obstacles <= 15 {
            return Array(allPoints.dropLast(allPoints.count - obstacles))
        } else {
            return Array(allPoints.dropLast(allPoints.count - 15))
        }
    }
}
