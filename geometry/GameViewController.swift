import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController, SCNSceneRendererDelegate{
    
    
    var gameView:SCNView!
    var gameScene:SCNScene!
    var cameraNode:SCNNode!
    var targetCreationTime:TimeInterval = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        initScene()
        initCamera()
        createTarget()
        
    }
    
    func initView(){
        gameView = self.view as? SCNView
        gameView.allowsCameraControl = true
        gameView.autoenablesDefaultLighting = true
        
        gameView.delegate = self
    }
    
    func initScene(){
        gameScene = SCNScene()
        gameView.scene = gameScene
        gameView.isPlaying = true
    }
    
    func initCamera(){
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        
        cameraNode.position = SCNVector3(x: 0,y:5,z:50)
    }
    
    func createTarget(){
        let geometry:SCNGeometry = SCNPyramid(width: 1, height: 1, length: 1)
        
        let randomColor = arc4random_uniform(2) == 0 ? UIColor.yellow : UIColor.purple
        
        geometry.materials.first?.diffuse.contents = randomColor
        
        let geometryNode = SCNNode(geometry: geometry)
        geometryNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        
        if randomColor == UIColor.purple{
            geometryNode.name = "enemy"
        }else {
            geometryNode.name = "friend"
        }
        
        gameScene.rootNode.addChildNode(geometryNode)
        
        let randomDirection : Float = arc4random_uniform(2) == 0 ? -1.0 : 1.0
        
        let force = SCNVector3(x: randomDirection, y: 15, z: 0)
        
        geometryNode.physicsBody?.applyForce(force, at: SCNVector3(x: 0.05, y: 0.05, z: 0.05), asImpulse: true)
    }
    
    func renderer(_ renderer : SCNSceneRenderer, updateAtTime time: TimeInterval){
        if time > targetCreationTime{
            createTarget()
            targetCreationTime = time + 0.2
        }
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = UIColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
}
