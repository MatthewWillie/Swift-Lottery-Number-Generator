//
//  BallDropAnimation.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 2/25/25.
//

//import SpriteKit
//import SwiftUI

//// MARK: - BallDropScene
//class BallDropScene: SKScene {
//    
//    // Store a reference to the ground for repositioning.
//    private var ground: SKSpriteNode?
//    
//    override func didMove(to view: SKView) {
//        // Set clear backgrounds for both the scene and the view.
//        backgroundColor = .clear
//        view.backgroundColor = .clear
//        
//        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
//        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
//        
//        addGround()
//        dropBalls()
//    }
//    
//    // Update physics boundaries and reposition ground when scene size changes.
//    override func didChangeSize(_ oldSize: CGSize) {
//        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
//        if let ground = ground {
//            ground.position = CGPoint(x: size.width / 2, y: size.height * 0.5)
//            ground.size = CGSize(width: size.width, height: 10)
//            ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
//            ground.physicsBody?.isDynamic = false
//        }
//    }
//    
//    func addGround() {
//        // Place the ground at 20% of the scene height.
//        let groundNode = SKSpriteNode(color: .clear, size: CGSize(width: size.width, height: 10))
//        groundNode.position = CGPoint(x: size.width / 2, y: size.height * 0.2)
//        groundNode.physicsBody = SKPhysicsBody(rectangleOf: groundNode.size)
//        groundNode.physicsBody?.isDynamic = false
//        addChild(groundNode)
//        self.ground = groundNode
//    }
//    
//    func dropBalls() {
//        let screenWidth = UIScreen.main.bounds.width
//        let ballSize: CGFloat = 50  // Diameter of each ball.
//        let spacing: CGFloat = ballSize + 10
//        
//        let startX = (screenWidth - (spacing * 6)) / 2
//        let positions: [CGFloat] = (0..<7).map { startX + (CGFloat($0) * spacing) }
//        
//        let ballImages = ["lotto_ball", "lotto_ball", "lotto_ball", "lotto_ball", "lotto_ball", "red_ball", "red_ball"]
//        let generatedNumbers = generateEuroMillionsNumbers()
//
//        for (index, xPos) in positions.enumerated() {
//            let delay = Double(index) * 0.2
//            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
//                self.createBall(at: CGPoint(x: xPos, y: self.size.height - 50),
//                                imageName: ballImages[index],
//                                number: generatedNumbers[index])
//            }
//        }
//    }
//    
//    func createBall(at position: CGPoint, imageName: String, number: Int) {
//        let ball = SKSpriteNode(imageNamed: imageName)
//        ball.size = CGSize(width: 50, height: 50)
//        ball.position = position
//        ball.alpha = 0  // Start hidden
//        
//        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2)
//        ball.physicsBody?.restitution = 0.6
//        ball.physicsBody?.friction = 0.2
//        ball.physicsBody?.mass = 0.5
//        ball.physicsBody?.linearDamping = 0.5
//        
//        // Create the label for the generated number.
//        let label = SKLabelNode(text: "\(number)")
//        label.fontSize = 25
//        label.fontName = "Times New Roman"
//        label.fontColor = .black
//        // Center the label within the ball.
//        label.position = .zero
//        label.verticalAlignmentMode = .center
//        label.horizontalAlignmentMode = .center
//        label.zPosition = 1
//        ball.addChild(label)
//        
//        addChild(ball)
//        
//        // Fade in the ball.
//        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
//        ball.run(fadeIn)
//    }
//    
//    func generateEuroMillionsNumbers() -> [Int] {
//        let mainNumbers = Array(1...50).shuffled().prefix(5).sorted()
//        let luckyStars = Array(1...12).shuffled().prefix(2).sorted()
//        return mainNumbers + luckyStars
//    }
//}

// MARK: - TransparentSpriteView
///// A UIViewRepresentable that configures an SKView with a transparent background.
//struct TransparentSpriteView: UIViewRepresentable {
//    var scene: SKScene
//    
//    func makeUIView(context: Context) -> SKView {
//        let skView = SKView()
//        skView.allowsTransparency = true
//        skView.backgroundColor = .clear
//        skView.preferredFramesPerSecond = 60
//        skView.ignoresSiblingOrder = true
//        
//        scene.scaleMode = .resizeFill
//        skView.presentScene(scene)
//        return skView
//    }
//    
//    func updateUIView(_ uiView: SKView, context: Context) {
//        scene.size = uiView.bounds.size
//    }
//}

// MARK: - BallDropView
//struct BallDropView: View {
//    var scene: SKScene {
//        let scene = BallDropScene(size: CGSize(width: UIScreen.main.bounds.width,
//                                                 height: UIScreen.main.bounds.height))
//        scene.scaleMode = .resizeFill
//        return scene
//    }
//    
//    var body: some View {
//        TransparentSpriteView(scene: scene)
//            .edgesIgnoringSafeArea(.all)
//            .background(Color.clear)
//    }
//}

//#Preview {
//    BallDropView()
//}
