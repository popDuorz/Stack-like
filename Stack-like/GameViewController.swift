/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import SceneKit
import SpriteKit
import SpriteKit

class GameViewController: UIViewController {
    
    @IBOutlet weak var scnView: SCNView!
  
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    var scnScene: SCNScene!
    
    var height = 0
    var direction = true
    
    var previousSize = SCNVector3(0.7, 0.2, 0.7)
    var previousPosition = SCNVector3(0, 0.1, 0)
    //var currentSize = SCNVector3(0.7, 0.2, 0.7)
    var currentPosition = SCNVector3Zero
    
    var offset = SCNVector3Zero
    var absoluteOffset = SCNVector3Zero
    var newSize = SCNVector3Zero
    
    var perfectMatches = 0
    
    var sounds = [String : SCNAudioSource]()
  
    override func viewDidLoad() {
        super.viewDidLoad()
  
        scnScene = SCNScene(named: "art.scnassets/Scenes/GameScene.scn")
        loadSound(name: "gameOver", path: "art.scnassets/Audio/GameOver.wav")
        loadSound(name: "perfectMatch", path: "art.scnassets/Audio/PerfectFit.wav")
        loadSound(name: "Miss", path: "art.scnassets/Audio/SliceBlock.wav")
        scnView.scene = scnScene

        scnView.isPlaying = true
        scnView.delegate = self
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBAction func PlayGame(_ sender: Any) {

        playButton.isHidden = true

        let gameScene = SCNScene(named: "art.scnassets/Scenes/GameScene.scn")
        scnScene = gameScene
        let transtion = SKTransition.fade(withDuration: 1.0)
        let mainCamera = scnScene.rootNode.childNode(withName: "MainCamera", recursively: false)

        scnView.present(scnScene, with: transtion, incomingPointOfView: mainCamera)

        height = 0
        scoreLabel.text = "\(height)"
        direction = true
        perfectMatches = 0

        currentPosition = SCNVector3Zero
        previousPosition = SCNVector3(x: 0, y: 0.1, z: 0)
        previousSize = SCNVector3(x: 0.7, y: 0.2, z: 0.7)

        let boxNode = SCNNode(geometry: SCNBox(width: 0.7, height: 0.2, length: 0.7, chamferRadius: 0))
        boxNode.geometry?.firstMaterial?.diffuse.contents = UIColor(red: CGFloat(height)/10.0, green: CGFloat(height)/20.0, blue: CGFloat(height)/30.0, alpha: 1)
        boxNode.name = "Block\(height)"
        boxNode.position = SCNVector3(x: 0, y: 0.1, z: -0.7)
        scnScene.rootNode.addChildNode(boxNode)

    }
    
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        
        if let currentBoxNode = scnScene.rootNode.childNode(withName: "Block\(height)", recursively: false) {
            currentPosition = currentBoxNode.presentation.position

            offset = previousPosition - currentPosition
            absoluteOffset = offset.absoluteValue()
            newSize = previousSize - absoluteOffset
            
            if checkEntireMiss(currentBoxNode) {
                playSound(sound: "Miss", node: currentBoxNode)
                return
            }
            if !checkPerfectMatch(currentBoxNode) {
                addBrokenBlock(currentBoxNode)
            }
            currentBoxNode.geometry = SCNBox(width: CGFloat(newSize.x), height: 0.2, length: CGFloat(newSize.z), chamferRadius: 0)
            currentBoxNode.geometry?.firstMaterial?.diffuse.contents = UIColor(red: CGFloat(height)/10.0, green: CGFloat(height)/20.0, blue: CGFloat(height)/30.0, alpha: 1)
            currentBoxNode.position = SCNVector3Make(currentPosition.x + offset.x / 2, currentPosition.y, currentPosition.z + offset.z / 2)
            currentBoxNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: currentBoxNode.geometry!, options: nil))
 
            addNewBlock(currentBoxNode)
            if height >= 5 {
                let moveUpAction = SCNAction.move(by: SCNVector3(0, 0.2, 0), duration: 0.2)
                let mainCamera = scnScene.rootNode.childNode(withName: "MainCamera", recursively: false)!
                mainCamera.runAction(moveUpAction)
            }
            previousSize = SCNVector3Make(newSize.x, 0.2, newSize.z)
            previousPosition = currentBoxNode.position
            height += 1
            scoreLabel.text = "\(height)"
        }
        
    }
    
    func addNewBlock(_ currentBoxNode: SCNNode) {
        let tempNode = SCNNode()
        tempNode.geometry = SCNBox(width: CGFloat(newSize.x), height: 0.2, length: CGFloat(newSize.z), chamferRadius: 0)
        tempNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: tempNode.geometry!, options: nil))
        tempNode.geometry?.firstMaterial?.diffuse.contents = UIColor(red: CGFloat(height + 1)/10.0, green: CGFloat(height + 1)/20.0, blue: CGFloat(height + 1)/30.0, alpha: 1)
        let newBlockNode = SCNNode(geometry: tempNode.geometry)
        newBlockNode.position = SCNVector3(x: currentBoxNode.position.x, y: currentBoxNode.position.y + 0.2, z: currentBoxNode.position.z)
        newBlockNode.name = "Block\(height + 1)"
        
        if height % 2 == 0 {
            newBlockNode.position.x = -0.7
        }
        else {
            newBlockNode.position.z = -0.7
        }
        scnScene.rootNode.addChildNode(newBlockNode)
    }
    
    func addBrokenBlock(_ currentBoxNode: SCNNode) {
        
        let brokenBoxNode = SCNNode()
        if height % 2 == 0 && absoluteOffset.z > 0 {
            if currentPosition.z > 0 {
                brokenBoxNode.position = SCNVector3(x: currentPosition.x, y: currentPosition.y, z: currentPosition.z + newSize.z / 2)
            }
            else {
                brokenBoxNode.position = SCNVector3(x: currentPosition.x, y: currentPosition.y, z: currentPosition.z - newSize.z / 2)
            }
            brokenBoxNode.geometry = SCNBox(width: CGFloat(previousSize.x), height: 0.2, length: CGFloat(absoluteOffset.z), chamferRadius: 0.0)
        }
        else if height % 2 != 0 && absoluteOffset.x > 0 {
            if currentPosition.x > 0 {
                brokenBoxNode.position = SCNVector3(x: currentPosition.x + newSize.x / 2, y: currentPosition.y, z: currentPosition.z)
            }
            else {
                brokenBoxNode.position = SCNVector3(x: currentPosition.x - newSize.x / 2, y: currentPosition.y, z: currentPosition.z)
            }
            brokenBoxNode.geometry = SCNBox(width: CGFloat(absoluteOffset.x), height: 0.2, length: CGFloat(previousSize.z), chamferRadius: 0.0)
        }
        brokenBoxNode.geometry?.firstMaterial?.diffuse.contents = UIColor(red: CGFloat(height + 1) / 10.0, green: CGFloat(height + 1) / 20.0, blue: CGFloat(height + 1) / 30.0, alpha: 1)
        brokenBoxNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: brokenBoxNode.geometry!, options: nil))
        brokenBoxNode.name = "Broken\(height)"
        scnScene.rootNode.addChildNode(brokenBoxNode)
    }
    
    func checkPerfectMatch(_ currentBoxNode: SCNNode)-> Bool {
        
        if height % 2 == 0 && absoluteOffset.z <= 0.03 {
            currentBoxNode.position.z = previousPosition.z
            currentPosition.z = previousPosition.z
            playSound(sound: "perfectMatch", node: currentBoxNode)

            return true
        }
        else if height % 2 != 0 && absoluteOffset.x <= 0.03 {
            currentBoxNode.position.x = previousPosition.x
            currentPosition.z = previousPosition.z
            playSound(sound: "perfectMatch", node: currentBoxNode)

            return true
        }
        return false
    }
    
    func checkEntireMiss(_ currentBoxNode: SCNNode) -> Bool {
        
        if (height % 2 == 0 && newSize.z <= 0) || (height % 2 != 0 && newSize.x <= 0) {
            
            height += 1
            currentBoxNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: currentBoxNode.geometry!, options: nil))
            gameOver()
            return true
        }
        return false
    }
    
    func loadSound(name: String, path: String) {
        
        if let sound = SCNAudioSource(fileNamed: path) {
            
            sound.isPositional = false
            sound.load()
            sound.volume = 1.0
            sounds[name] = sound
        }
    }
    
    func playSound(sound: String, node: SCNNode) {
        node.runAction(SCNAction.playAudio(sounds[sound]!, waitForCompletion: false))
    }

    func gameOver() {
        let mainCamera = scnScene.rootNode.childNode(
                withName: "MainCamera", recursively: false)!

        let fullAction = SCNAction.customAction(duration: 0.3) { _,_ in
            let moveAction = SCNAction.move(to: SCNVector3Make(mainCamera.position.x,
                    mainCamera.position.y * (3/4), mainCamera.position.z), duration: 0.3)
            mainCamera.runAction(moveAction)
            if self.height <= 15 {
                mainCamera.camera?.orthographicScale = 1
            } else {
                mainCamera.camera?.orthographicScale = Double(Float(self.height/2) /
                        mainCamera.position.y)
            }
        }

        mainCamera.runAction(fullAction)
        playButton.isHidden = false
    }

}

extension GameViewController: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if let currentNode = scnScene.rootNode.childNode(withName: "Block\(height)", recursively: false) {
            if height % 2 == 0 {
                if currentNode.position.z >= 0.7 {
                    direction = true
                }
                else if currentNode.position.z <= -0.7 {
                    direction = false
                }
                switch direction {
                case true:
                    currentNode.position.z -= 0.03
                case false:
                    currentNode.position.z += 0.03
                }
            }
            else {
                if currentNode.position.x >= 0.7 {
                    direction = true
                }
                else if currentNode.position.x <= -0.7 {
                    direction = false
                }
                switch direction {
                case true:
                    currentNode.position.x -= 0.03
                case false:
                    currentNode.position.x += 0.03
                }
            }
        }
        for node in scnScene.rootNode.childNodes {
            if node.presentation.position.y < -8{
                node.removeFromParentNode()
            }
        }
    }
}

extension SCNVector3 {
    func absoluteValue() -> SCNVector3 {
        return SCNVector3Make(abs(self.x), abs(self.y), abs(self.z))
    }
    static func + (first: SCNVector3, second: SCNVector3) -> SCNVector3 {
        return SCNVector3Make(first.x + second.x, first.y + second.y, first.z + second.z)
    }
    static func - (first: SCNVector3, second: SCNVector3) -> SCNVector3 {
        return SCNVector3Make(first.x - second.x, first.y - second.y, first.z - second.z)
    }
}
