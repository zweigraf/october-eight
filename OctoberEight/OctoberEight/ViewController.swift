//
//  ViewController.swift
//  OctoberEight
//
//  Created by Luis Reisewitz on 08.10.15.
//  Copyright © 2015 ZweiGraf. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
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
        let videoDevices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        guard let device = videoDevices.first as? AVCaptureDevice else {
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
    }

    func failToCreateSession() {
        let alert = UIAlertController(title: "Oops", message: "Sorry, but we could not get your camera at the moment. Please try again.", preferredStyle: .Alert)
        let action = UIAlertAction(title: "Retry", style: .Default) { (action: UIAlertAction) -> Void in
            self.createSession()
        }
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
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
    
    
}

