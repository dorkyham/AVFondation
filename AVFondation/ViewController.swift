//
//  ViewController.swift
//  AVFondation
//
//  Created by Annisa Nabila Nasution on 08/07/19.
//  Copyright © 2019 Annisa Nabila Nasution. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    let captureSession = AVCaptureSession()
    var previewLayer:CALayer!
    var captureDevice:AVCaptureDevice!

    let minimumZoom: CGFloat = 1.0
    let maximumZoom: CGFloat = 3.0
    var lastZoomFactor: CGFloat = 1.0
    
    @IBOutlet var cameraView: UIView!
    
    var takePhoto = false
    var isGridShowen = true
    
    @IBOutlet var gridLine: UIImageView!
    
    @IBAction func buttonTake(_ sender: Any) {
        takePhoto = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinch(sender:)))
        
        cameraView.addGestureRecognizer(pinchGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareCamera()
    }
    
    @objc func pinch(sender:UIPinchGestureRecognizer){
        guard let device = captureDevice else { return }
        
        // Return zoom value between the minimum and maximum zoom values
        func minMaxZoom(_ factor: CGFloat) -> CGFloat {
            return min(min(max(factor, minimumZoom), maximumZoom), device.activeFormat.videoMaxZoomFactor)
        }
        
        func update(scale factor: CGFloat) {
            do {
                try device.lockForConfiguration()
                defer { device.unlockForConfiguration() }
                device.videoZoomFactor = factor
            } catch {
                print("\(error.localizedDescription)")
            }
        }
        
        let newScaleFactor = minMaxZoom(sender.scale * lastZoomFactor)
        
        switch sender.state {
        case .began: fallthrough
        case .changed: update(scale: newScaleFactor)
        case .ended:
            lastZoomFactor = minMaxZoom(newScaleFactor)
            update(scale: lastZoomFactor)
        default: break
        }
    }
    
    
    func prepareCamera(){
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        if let availabeDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back).devices as? [AVCaptureDevice] {
            captureDevice = availabeDevices.first
            beginSession()
        }
    }
    
    func beginSession(){
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(captureDeviceInput)
        }catch{
            print(error.localizedDescription)
        }
            //buat kamera
            let previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
            self.previewLayer = previewLayer
            self.cameraView.layer.addSublayer(previewLayer)
            self.previewLayer.frame = self.cameraView.bounds
        
            captureSession.startRunning()
        
            //masukin gridnya
            self.view.addSubview(gridLine)
        
            let dataOutput = AVCaptureVideoDataOutput()
            dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString):NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
        
            dataOutput.alwaysDiscardsLateVideoFrames = true

            captureSession.addOutput(dataOutput)
        
            captureSession.commitConfiguration()
        
            let queue = DispatchQueue(label: "com.brianadvent.captureQueue")
        dataOutput.setSampleBufferDelegate(self as! AVCaptureVideoDataOutputSampleBufferDelegate, queue: queue)
        
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if takePhoto {
            takePhoto = false
            if let image = self.getImageFromSampleBuffer(buffer: sampleBuffer){
                let photoVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PhotoVC") as! PhotoViewController
                
                photoVC.takenPhoto = image
                
                DispatchQueue.main.async {
              
                    self.present(photoVC, animated: true, completion: {
                        self.stopCaptureSession()
                    })
                }
            }
        }
    }
    
    func getImageFromSampleBuffer(buffer:CMSampleBuffer) -> UIImage?{
        if let pixerBuffer = CMSampleBufferGetImageBuffer(buffer){
            let ciImage = CIImage(cvPixelBuffer: pixerBuffer)
            let context = CIContext()
            
            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixerBuffer), height: CVPixelBufferGetHeight(pixerBuffer))
            
            if let image = context.createCGImage(ciImage, from: imageRect){
                return UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .right)
            }
        }
        return nil
    }
    
    func stopCaptureSession(){
        self.captureSession.stopRunning()
        
        if let inputs = captureSession.inputs as? [AVCaptureDeviceInput]{
            for input in inputs{
                self.captureSession.removeInput(input)
            }
        }
    }
    
    
    @IBAction func gridButton(_ sender: Any) {
        if isGridShowen{
            gridLine.isHidden = true
            isGridShowen = false
        }else{
            gridLine.isHidden = false
            isGridShowen = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

