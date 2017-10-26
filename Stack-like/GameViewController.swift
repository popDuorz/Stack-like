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

class GameViewController: UIViewController {
    
    @IBOutlet weak var scnView: SCNView!
  
    @IBOutlet weak var scoreLabel: UILabel!
    
    var scnScene: SCNScene!
    
    var height = 0
    var direction = true
    
    var previewSize = SCNVector3(0.7, 0.2, 0.7)
    var previewPosition = SCNVector3(0, 0.1, 0)
    var currentSize = SCNVector3(0.7, 0.2, 0.7)
    var currentPosition = SCNVector3Zero
    
    var offset = SCNVector3Zero
    var absoluteOffset = SCNVector3Zero
    var newSize = SCNVector3Zero
    
    var perfectMatches = 0
  
    override func viewDidLoad() {
        super.viewDidLoad()
  
        scnScene = SCNScene(named: "art.scnassets/Scenes/GameScene.scn")
        scnView.scene = scnScene
        
        let box = SCNBox(width: 0.7, height: 0.2, length: 0.7, chamferRadius: 0)
        let blockNode = SCNNode(geometry: box)
        blockNode.position.z = -0.85
        blockNode.position.y = 0.1
        blockNode.name = "Block\(height)"
        
        blockNode.geometry?.firstMaterial?.diffuse.contents = UIColor(displayP3Red: 0.01 * CGFloat(height), green: 0, blue: 1, alpha: 1)
        
        scnScene.rootNode.addChildNode(blockNode)
        
        scnView.isPlaying = true
        scnView.delegate = self
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        
        
    }
    
}

extension GameViewController: SCNSceneRendererDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        if let currentNode = scnScene.rootNode.childNode(withName: "Block\(height)", recursively: false) {
            
            if height % 2 == 0 {
                
                if currentNode.position.z >= 0.85 {
                    
                    direction = true
                }
                else if currentNode.position.z <= -0.85 {
                    
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
                
                if currentNode.position.x >= 0.85 {
                    
                    direction = true
                }
                else if currentNode.position.x <= -0.85 {
                    
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
    }
}
