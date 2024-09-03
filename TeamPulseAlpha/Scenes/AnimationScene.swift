//
//  AnimationScene.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/23/24.
//

import SpriteKit
import SwiftUI

/// The `AnimationScene` class handles the rendering and animation of heart rate visuals
/// in the form of hearts and cluster rings in a SpriteKit scene. The scene also includes
/// background music and sound effects for cluster events.
class AnimationScene: SKScene {

    // MARK: - Properties

    // Hearts representing different sensors
    private var blueHeart: SKSpriteNode!
    private var greenHeart: SKSpriteNode!
    private var redHeart: SKSpriteNode!

    // Rings representing cluster associations
    private var blueRing: SKShapeNode!
    private var greenRing: SKShapeNode!
    private var redRing: SKShapeNode!
    private var allRing01: SKShapeNode!
    private var allRing02: SKShapeNode!
    private var allRing03: SKShapeNode!

    // Stars representing active clusters
    private var activeStars: [SKSpriteNode] = []

    // Last recorded heart rate values for each sensor
    private var lastValues: [String: Double] = ["Blue": 0.0, "Green": 0.0, "Red": 0.0]

    // Current state of clusters
    private var currentClusterState: [Bool] = [false, false, false, false, false, false]
    
    // Background music node
    private var backgroundMusic: SKAudioNode!

    // Cluster sound effect node
    private var clusterSound: SKAudioNode!
    
    // Time tracking for animations
    var startTime: TimeInterval = 0
    
    // MARK: - Scene Setup

    override func didMove(to view: SKView) {
        // Set the scene's scale mode to resize to fill the view
        scene?.scaleMode = .resizeFill
        
        // Initialize hearts and rings
        setupHeartsAndRings()

        // Add hearts and rings to the scene
        addHeartsAndRingsToScene()

        // Play background music
        playBackgroundMusic()
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Compute time elapsed and update stars if necessary
        let elapsedTime = computeDeltaTime(currentTime: currentTime)
        if elapsedTime > 5.0 {
            updateStars()
            startTime = 0
        }
    }
    
    // MARK: - Heart and Ring Setup
    
    /// Initializes heart and ring nodes with specific colors.
    private func setupHeartsAndRings() {
        blueHeart = createHeart(color: .blue)
        greenHeart = createHeart(color: .green)
        redHeart = createHeart(color: .red)

        blueRing = createRing(color: .cyan)
        greenRing = createRing(color: .purple)
        redRing = createRing(color: .orange)
        let goldenColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        allRing01 = createRing(color: goldenColor)
        allRing02 = createRing(color: goldenColor)
        allRing03 = createRing(color: goldenColor)
    }

    /// Adds heart and ring nodes to the scene.
    private func addHeartsAndRingsToScene() {
        addChild(blueHeart)
        addChild(greenHeart)
        addChild(redHeart)
        
        addChild(blueRing)
        addChild(greenRing)
        addChild(redRing)
        addChild(allRing01)
        addChild(allRing02)
        addChild(allRing03)
    }
    
    // MARK: - Animation Updates
    
    /// Updates heart positions based on new heart rate data.
    /// - Parameters:
    ///   - blueHR: Heart rate for the blue sensor.
    ///   - greenHR: Heart rate for the green sensor.
    ///   - redHR: Heart rate for the red sensor.
    func updateHeartPositions(blueHR: Double, greenHR: Double, redHR: Double) {
        updateRingContexts()
        updateHeartContexts()

        // Normalize and calculate positions for each heart
        let bluePos = positionForHeartRate(id: "Blue", hr: blueHR)
        let greenPos = positionForHeartRate(id: "Green", hr: greenHR)
        let redPos = positionForHeartRate(id: "Red", hr: redHR)
        
        // Move hearts smoothly to new positions
        runMoveAction(for: blueHeart, to: bluePos)
        runMoveAction(for: greenHeart, to: greenPos)
        runMoveAction(for: redHeart, to: redPos)

        // Update ring positions based on cluster state
        updateRingPositions()
    }

    /// Updates the colors of the hearts based on the cluster state.
    private func updateHeartContexts() {
        if currentClusterState[4] || currentClusterState[5] {
            let goldenColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
            blueHeart.color = goldenColor
            greenHeart.color = goldenColor
            redHeart.color = goldenColor
        } else {
            blueHeart.color = .blue
            greenHeart.color = .green
            redHeart.color = .red
        }
    }

    /// Updates the visibility of rings based on the cluster state.
    private func updateRingContexts() {
        blueRing.alpha = (currentClusterState[1] || currentClusterState[2]) ? 1.0 : 0.0
        greenRing.alpha = (currentClusterState[1] || currentClusterState[3]) ? 1.0 : 0.0
        redRing.alpha = (currentClusterState[2] || currentClusterState[3]) ? 1.0 : 0.0
        let allRingAlpha = (currentClusterState[4] || currentClusterState[5]) ? 1.0 : 0.0
        allRing01.alpha = allRingAlpha
        allRing02.alpha = allRingAlpha
        allRing03.alpha = allRingAlpha
    }

    /// Updates the positions of the rings based on the cluster state.
    private func updateRingPositions() {
        if currentClusterState[1] {
            greenRing.run(SKAction.move(to: blueHeart.position, duration: 0.5))
            blueRing.run(SKAction.move(to: greenHeart.position, duration: 0.5))
        }
        if currentClusterState[2] {
            redRing.run(SKAction.move(to: blueHeart.position, duration: 0.5))
            blueRing.run(SKAction.move(to: redHeart.position, duration: 0.5))
        }
        if currentClusterState[3] {
            redRing.run(SKAction.move(to: greenHeart.position, duration: 0.5))
            greenRing.run(SKAction.move(to: redHeart.position, duration: 0.5))
        }
        if currentClusterState[4] || currentClusterState[5] {
            allRing01.run(SKAction.move(to: blueHeart.position, duration: 0.5))
            allRing02.run(SKAction.move(to: greenHeart.position, duration: 0.5))
            allRing03.run(SKAction.move(to: redHeart.position, duration: 0.5))
        }
    }
    
    // MARK: - Cluster Management
    
    /// Updates the cluster circles based on the provided cluster state.
    /// - Parameter clusterState: A boolean array representing the active clusters.
    func updateClusterCircles(clusterState: [Bool]) {
        currentClusterState = clusterState
    }
    
    /// Adds a star to the scene when a new cluster is formed.
    func addStar() {
        let star = createStar()
        addChild(star)
        activeStars.append(star)
        
        // Play cluster sound effect
        playClusterSound()

        // Add random movement to the star
        runStarMovement(for: star)
        
        // Remove the star after 5 minutes
        let removeAction = SKAction.sequence([
            SKAction.wait(forDuration: 300),
            SKAction.removeFromParent()
        ])
        star.run(removeAction)
    }
    
    /// Updates the stars based on the current cluster state.
    func updateStars() {
        if currentClusterState[4] || currentClusterState[5] {
            addStar()
        }
    }
    
    // MARK: - Audio Management
    
    /// Plays background music in a loop.
    private func playBackgroundMusic() {
        if let musicURL = Bundle.main.url(forResource: "backgroundMusic", withExtension: "mp3") {
            backgroundMusic = SKAudioNode(url: musicURL)
            backgroundMusic.autoplayLooped = true
            addChild(backgroundMusic)
        }
    }

    /// Plays a sound effect when a cluster is formed.
    private func playClusterSound() {
        if let musicURL = Bundle.main.url(forResource: "clusterSound", withExtension: "mp3") {
            clusterSound = SKAudioNode(url: musicURL)
            clusterSound.autoplayLooped = false
            addChild(clusterSound)
            clusterSound.run(SKAction.play())
        }
    }
    
    // MARK: - Utility Functions
    
    /// Computes the time elapsed since the last update.
    /// - Parameter currentTime: The current time from the update loop.
    /// - Returns: The time elapsed since the last update.
    private func computeDeltaTime(currentTime: TimeInterval) -> TimeInterval {
        if startTime.isZero {
            startTime = currentTime
            return 0
        } else {
            return currentTime - startTime
        }
    }

    /// Creates a heart node with the specified color.
    /// - Parameter color: The color of the heart.
    /// - Returns: A `SKSpriteNode` representing the heart.
    private func createHeart(color: UIColor) -> SKSpriteNode {
        let heart = SKSpriteNode(imageNamed: "heart")
        heart.color = color
        heart.colorBlendFactor = 1.0
        heart.size = CGSize(width: 40, height: 40)  // Adjust size as needed
        heart.position = positionForHeartRate(id: "", hr: 0.0)
        return heart
    }

    /// Creates a ring node with the specified color.
    /// - Parameter color: The color of the ring.
    /// - Returns: A `SKShapeNode` representing the ring.
    private func createRing(color: UIColor) -> SKShapeNode {
        let ring = SKShapeNode(circleOfRadius: 25)
        ring.strokeColor = color
        ring.position = CGPoint(x: 100, y: 100)
        ring.glowWidth = 0.3
        ring.lineWidth = 2.0
        ring.alpha = 0.0
        return ring
    }

    /// Creates a star node and adds it to the scene.
    /// - Returns: A `SKSpriteNode` representing the star.
    private func createStar() -> SKSpriteNode {
        let star = SKSpriteNode(imageNamed: "star")
        star.size = CGSize(width: 20, height: 20)  // Adjust size as needed
        star.position = CGPoint(x: CGFloat.random(in: 0...size.width),
                                y: CGFloat.random(in: 0...size.height))
        return star
    }

    /// Calculates the position of the heart based on its heart rate.
    /// - Parameters:
    ///   - id: The identifier of the heart (e.g., "Blue", "Green", "Red").
    ///   - hr: The heart rate value.
    /// - Returns: A `CGPoint` representing the position of the heart.
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

    /// Runs a smooth move action on a given node.
    /// - Parameters:
    ///   - node: The `SKSpriteNode` to move.
    ///   - position: The target position for the move action.
    private func runMoveAction(for node: SKSpriteNode, to position: CGPoint) {
        let moveAction = SKAction.move(to: position, duration: 0.5)
        moveAction.timingMode = .easeInEaseOut
        node.run(moveAction)
    }

    /// Runs a random movement action on a star.
    /// - Parameter star: The `SKSpriteNode` representing the star.
    private func runStarMovement(for star: SKSpriteNode) {
        let moveActions = (1...6).map { _ in
            SKAction.move(to: CGPoint(x: CGFloat.random(in: 0...size.width),
                                      y: CGFloat.random(in: 0...size.height)),
                          duration: 10.0)
        }
        let reverseActions = moveActions.reversed().map { $0.reversed() }
        let fullMovement = SKAction.sequence(moveActions + reverseActions)
        let repeatMovement = SKAction.repeatForever(fullMovement)
        star.run(repeatMovement)
    }
}
