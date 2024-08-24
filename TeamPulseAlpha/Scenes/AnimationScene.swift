//
//  AnimationScene.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/23/24.
//

import SpriteKit
import SwiftUI

class AnimationScene: SKScene {

    // Properties for hearts
    private var blueHeart: SKSpriteNode!
    private var greenHeart: SKSpriteNode!
    private var redHeart: SKSpriteNode!

    // Properties for cluster rings
    private var blueRing: SKShapeNode!
    private var greenRing: SKShapeNode!
    private var redRing: SKShapeNode!
    private var allRing01: SKShapeNode!
    private var allRing02: SKShapeNode!
    private var allRing03: SKShapeNode!

    // Properties to track clusters
    private var activeStars: [SKSpriteNode] = []

    private var lastValues: [String: Double] = ["Blue": 0.0, "Green": 0.0, "Red": 0.0]
    private var currentClusterState: [Bool] = [false, false, false, false, false, false]
    
    // Background music
    private var backgroundMusic: SKAudioNode!

    // cluster sound
    private var clusterSound: SKAudioNode!
    
    // time values
    var startTime:TimeInterval = 0
    
    override func didMove(to view: SKView) {
        
        //backgroundColor = .black // Set the background to black (cosmos)
        
        scene?.scaleMode = .resizeFill
        
        // Initialize hearts
        blueHeart = createHeart(color: .blue)
        greenHeart = createHeart(color: .green)
        redHeart = createHeart(color: .red)
        
        // Initialize rings
        blueRing = createRing(color: .cyan)
        greenRing = createRing(color: .purple)
        redRing = createRing(color: .orange)
        allRing01 = createRing(color: UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0))
        allRing02 = createRing(color: UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0))
        allRing03 = createRing(color: UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0))

        // Add hearts to the scene
        addChild(blueHeart)
        addChild(greenHeart)
        addChild(redHeart)
        
        addChild(blueRing)
        addChild(greenRing)
        addChild(redRing)
        addChild(allRing01)
        addChild(allRing02)
        addChild(allRing03)

        // Play background music
        playBackgroundMusic()
    }
    
    override func update(_ currentTime: TimeInterval) {
        let elapsedTime = computeDeltaTime(currentTime: currentTime)
        if elapsedTime > 5.0 {
            updateStars()
            startTime = 0
        }
    }
    
    private func computeDeltaTime(currentTime: TimeInterval) -> TimeInterval {
        if startTime.isZero {
            startTime = currentTime
            return 0
        }
        else {
            return currentTime - startTime
        }
    }
    
    func reset() {
        
    }
    
    
    // Create a heart with a specific color
    private func createHeart(color: UIColor) -> SKSpriteNode {
        let heart = SKSpriteNode(imageNamed: "heart")
        heart.color = color
        heart.colorBlendFactor = 1.0
        heart.size = CGSize(width: 20, height: 20) // Adjust size as needed
        heart.position = positionForHeartRate(id: "", hr: 0.0)
        return heart
    }
    
    // Create a ring with a specific color
    private func createRing(color: UIColor) -> SKShapeNode {
        let ring = SKShapeNode(circleOfRadius: 15)
        ring.strokeColor = color
        ring.position = CGPoint(x: 100, y: 100)
        ring.glowWidth = 0.3
        ring.lineWidth = 2.0
        ring.alpha = 0.0
        return ring
    }
    
    // Play background music
    private func playBackgroundMusic() {
        if let musicURL = Bundle.main.url(forResource: "backgroundMusic", withExtension: "mp3") {
            backgroundMusic = SKAudioNode(url: musicURL)
            addChild(backgroundMusic)
            backgroundMusic.autoplayLooped = true
        }
    }
        
    private func PlayClusterSound() {
        if let musicURL = Bundle.main.url(forResource: "clusterSound", withExtension: "mp3") {
            clusterSound = SKAudioNode(url: musicURL)
            clusterSound.autoplayLooped = false
            addChild(clusterSound)
            clusterSound.run(SKAction.play())
        }
    }
    
    // Function to update heart positions based on heart rate data
    func updateHeartPositions(blueHR: Double, greenHR: Double, redHR: Double) {

        updateRingContexts()
        updateHeartContexts()

        // Normalize and calculate positions
        let bluePos = positionForHeartRate(id: "Blue", hr: blueHR)
        let greenPos = positionForHeartRate(id: "Green", hr: greenHR)
        let redPos = positionForHeartRate(id: "Red", hr: redHR)
        
        // Move hearts smoothly
        let blueAction = SKAction.move(to: bluePos, duration: 0.5)
        blueAction.timingMode = .easeInEaseOut

        let greenAction = SKAction.move(to: greenPos, duration: 0.5)
        greenAction.timingMode = .easeInEaseOut
        
        let redAction = SKAction.move(to: redPos, duration: 0.5)
        redAction.timingMode = .easeInEaseOut

        blueHeart.run(blueAction)
        greenHeart.run(greenAction)
        redHeart.run(redAction)

        if currentClusterState[1] {
            greenRing.run(blueAction)
            blueRing.run(greenAction)
        }
        if currentClusterState[2] {
            redRing.run(blueAction)
            blueRing.run(redAction)
        }
        if currentClusterState[3] {
            redRing.run(greenAction)
            greenRing.run(redAction)
        }
        if currentClusterState[4] || currentClusterState[5] {
            allRing01.run(blueAction)
            allRing02.run(greenAction)
            allRing03.run(redAction)
        }
        
    }
    
    private func updateHeartContexts() {
        if currentClusterState[4] || currentClusterState[5] {
            blueHeart.color = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
            greenHeart.color = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
            redHeart.color = UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
        }
        else {
            blueHeart.color = .blue
            greenHeart.color = .green
            redHeart.color = .red
        }
    }

    private func updateRingContexts() {
        if currentClusterState[1] || currentClusterState[2] {
            blueRing.alpha = 1.0
        }
        else {
            blueRing.alpha = 0.0
        }
        if currentClusterState[1] || currentClusterState[3] {
            greenRing.alpha = 1.0
        }
        else {
            greenRing.alpha = 0.0
        }
        if currentClusterState[2] || currentClusterState[3] {
            redRing.alpha = 1.0
        }
        else {
            redRing.alpha = 0.0
        }
        if currentClusterState[4] || currentClusterState[5] {
            allRing01.alpha = 1.0
            allRing02.alpha = 1.0
            allRing03.alpha = 1.0
        }
        else {
            allRing01.alpha = 0.0
            allRing02.alpha = 0.0
            allRing03.alpha = 0.0
        }
    }

    // Function to normalize heart rate and calculate position
    private func positionForHeartRate(id: String, hr: Double) -> CGPoint {
        let normalizedHR = min(max((hr - 40) / 160, 0.0), 1.0)
        var x = normalizedHR
        let y = normalizedHR

        if !id.isEmpty {
            x = lastValues[id]!
            lastValues[id] = normalizedHR
        }
        return CGPoint(x: x * size.width, y: y * size.height)
    }
    
    // Function to add a star when a new cluster is formed
    func addStar() {
        let star = SKSpriteNode(imageNamed: "star")
        star.size = CGSize(width: 20, height: 20) // Adjust size as needed
        star.position = CGPoint(x: CGFloat.random(in: 0...size.width),
                                y: CGFloat.random(in: 0...size.height))
        addChild(star)
        activeStars.append(star)
        
        PlayClusterSound()
        
        // Add random movement
        let moveAction01 =
            SKAction.move(to: CGPoint(x: CGFloat.random(in: 0...size.width),
                                             y: CGFloat.random(in: 0...size.height)),
                          duration: 10.0)
        let moveAction02 =
            SKAction.move(to: CGPoint(x: CGFloat.random(in: 0...size.width),
                                             y: CGFloat.random(in: 0...size.height)),
                          duration: 10.0)
        let moveAction03 =
            SKAction.move(to: CGPoint(x: CGFloat.random(in: 0...size.width),
                                             y: CGFloat.random(in: 0...size.height)),
                          duration: 10.0)
        let moveAction04 =
            SKAction.move(to: CGPoint(x: CGFloat.random(in: 0...size.width),
                                             y: CGFloat.random(in: 0...size.height)),
                          duration: 10.0)
        let moveAction05 =
            SKAction.move(to: CGPoint(x: CGFloat.random(in: 0...size.width),
                                             y: CGFloat.random(in: 0...size.height)),
                          duration: 10.0)
        let moveAction06 =
            SKAction.move(to: CGPoint(x: CGFloat.random(in: 0...size.width),
                                             y: CGFloat.random(in: 0...size.height)),
                          duration: 10.0)

        let repeatMove = SKAction.repeatForever(SKAction.sequence([moveAction01, moveAction02, moveAction03, moveAction04, moveAction05, moveAction06, moveAction06.reversed(), moveAction05.reversed(), moveAction04.reversed(), moveAction03.reversed(), moveAction02.reversed(), moveAction01.reversed()]))
        
        star.run(repeatMove)
        
        // Remove star after 5 minutes
        let removeAction = SKAction.sequence([
            SKAction.wait(forDuration: 300),
            SKAction.removeFromParent()
        ])
        star.run(removeAction)
    }
    
    // Function to handle cluster circles
    func updateClusterCircles(clusterState: [Bool]) {
        currentClusterState = clusterState
    }
    
    func updateStars() {
        let spawn = currentClusterState[1] || currentClusterState[2] || currentClusterState[3] || currentClusterState[4] || currentClusterState[5]
        if spawn {
            addStar()
        }
    }
}
