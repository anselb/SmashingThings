//
//  GameScene.swift
//  SmashingThings
//
//  Created by Ansel Bridgewater on 7/29/17.
//  Copyright © 2017 Ansel Bridgewater. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
	var orangeTree: SKSpriteNode!
	var orange: Orange?
	var touchStart: CGPoint = CGPoint.zero
	var shapeNode = SKShapeNode()
	var countLabel: SKLabelNode!
	var count: Int = 0 { didSet { countLabel.text = "\(count)" } }
	
	static func Load(level: Int) -> GameScene? {
		return GameScene(fileNamed: "Level_\(level)")
	}
	
	override func didMove(to view: SKView) {
		super.didMove(to: view)
		
		orangeTree = childNode(withName: "OrangeTree") as! SKSpriteNode
		
		addChild(shapeNode)
		shapeNode.lineWidth = 20
		shapeNode.lineCap = .round
		shapeNode.strokeColor = UIColor(white: 1, alpha: 0.3)
		
		if let clouds = SKEmitterNode(fileNamed: "CloudEmitter"){
			addChild(clouds)
			clouds.position.x = -180
			clouds.position.y = 300
			clouds.zPosition = 0
			clouds.advanceSimulationTime(160)
		}
		
		countLabel = childNode(withName: "CountLabel") as! SKLabelNode
		
		physicsWorld.contactDelegate = self
		
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		let touch = touches.first!
		let location = touch.location(in: self)
		if atPoint(location).name == "OrangeTree" {
			orange = Orange()
			addChild(orange!)
			orange?.position = location
			//let vector = CGVector(dx: 100, dy: 0)
			//orange?.physicsBody?.applyImpulse(vector)
			orange?.physicsBody?.isDynamic = false
			touchStart = location
		}
		
		for node in nodes(at: location){
			if node.name == "Sun" {
				let n = Int(arc4random() % 3 + 1)
				if let scene = GameScene.Load(level: n){
					scene.scaleMode = .aspectFill
					if let view = view {
						view.presentScene(scene)
					}
				}
			}
		}
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		let touch = touches.first!
		let location = touch.location(in: self)
		orange?.position = location
		
		let path = UIBezierPath()
		path.move(to: touchStart)
		path.addLine(to: location)
		shapeNode.path = path.cgPath
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		let touch = touches.first!
		let location = touch.location(in: self)
		let dx = (touchStart.x - location.x)
		let dy = (touchStart.y - location.y)
		let vector = CGVector(dx: dx, dy: dy)
		orange?.physicsBody?.isDynamic = true
		orange?.physicsBody?.applyImpulse(vector)
		
		shapeNode.path = nil
		
		count += 1
		
	}
	
	func didBegin(_ contact: SKPhysicsContact) {
		let nodeA = contact.bodyA.node
		let nodeB = contact.bodyB.node
		if contact.collisionImpulse > 6 {
			if nodeA?.name == "BlockHead" {
				removeBlockHead(node: nodeA!)
			} else if nodeB?.name == "BlockHead" {
				removeBlockHead(node: nodeB!)
			}
		}
	}
	
	func removeBlockHead(node: SKNode) {
		if let poof = SKEmitterNode(fileNamed: "Poof") {
			addChild(poof)
			poof.position.x = node.position.x
			poof.position.y = node.position.y
			let wait = SKAction.wait(forDuration: 3)
			let remove = SKAction.removeFromParent()
			let byePoof = SKAction.sequence([wait, remove])
			poof.run(byePoof)
		}
		node.removeFromParent()
	}
}
