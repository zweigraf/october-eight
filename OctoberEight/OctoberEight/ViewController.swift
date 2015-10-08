//
//  ViewController.swift
//  OctoberEight
//
//  Created by Luis Reisewitz on 08.10.15.
//  Copyright © 2015 ZweiGraf. All rights reserved.
//

import UIKit
import AVFoundation

var GlobalBackgroundQueue: dispatch_queue_t {
    return dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.rawValue), 0)
}

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    let session : AVCaptureSession = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer? = nil
    @IBOutlet weak var previewHolder: UIView!
    
    // MARK: Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        createSession()
        
    }
    
    override func viewDidLayoutSubviews() {
        adjustPreviewFrame()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Session & Preview Handling
    
    func createSession() {
        guard let videoDevices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) as? [AVCaptureDevice] else {
            failToCreateSession()
            return
        }
        
        let frontDevices = videoDevices.filter { (el) -> Bool in
            el.position == .Front
        }
        
        guard let device = frontDevices.first else {
            failToCreateSession()
            return
        }
        guard let input = try? AVCaptureDeviceInput(device: device) else {
            failToCreateSession()
            return
        }
        
        session.addInput(input)
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        
        session.startRunning()
        
        mergePreview(previewLayer!)
        
        let metaOutput = AVCaptureMetadataOutput()
        
        let queue = GlobalBackgroundQueue
        metaOutput.setMetadataObjectsDelegate(self, queue: queue)
        
        session.addOutput(metaOutput)
        
        if let array = metaOutput.availableMetadataObjectTypes as? [String] {
            guard array.contains("face") else {
                failToCreateFaceDetection()
                return
            }
            metaOutput.metadataObjectTypes = ["face"]
        }
        
    }

    func failToCreateSession() {
        let alert = UIAlertController(title: "Oops", message: "Sorry, but we could not get your camera at the moment. Please try again.", preferredStyle: .Alert)
        let action = UIAlertAction(title: "Retry", style: .Default) { (action: UIAlertAction) -> Void in
            self.createSession()
        }
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }

func failToCreateFaceDetection() {
    
}
    
    func mergePreview(layer: AVCaptureVideoPreviewLayer) {
        let backingLayer = previewHolder.layer
        if let firstLayer = backingLayer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            // we assume an existing preview layer to be ours, 
            // in case this is run multiple times
            firstLayer.removeFromSuperlayer()
        }
        layer.frame = previewHolder.bounds
        layer.videoGravity = AVLayerVideoGravityResizeAspect
        backingLayer.addSublayer(layer)
    }
    
    func adjustPreviewFrame() {
        previewLayer?.frame = previewHolder.bounds
    }
    
    // MARK: AVCaptureMetadataOutputObjectsDelegate
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        print(metadataObjects)
    }
    
}

