//
//  ViewController.swift
//  QRCodeScanApp
//
//  Created by Alex Kulish on 13.03.2022.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var video = AVCaptureVideoPreviewLayer()
    // 1. Настроим сессию
    let session = AVCaptureSession()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupVideo()
    }

    @IBAction func startVideoTapped() {
        startVideo()
    }
    
    func setupVideo() {
        // 2. Настраиваем устройство видео
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        // 3. Настроим input
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!) // обработать
            session.addInput(input)
        } catch {
            fatalError(error.localizedDescription)
        }
        // 4. Настроим output
        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        // 5. Задать сессию для видео
        video = AVCaptureVideoPreviewLayer(session: session)
        video.frame = view.layer.bounds
    }
    
    func startVideo() {
        view.layer.addSublayer(video)
        session.startRunning()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard metadataObjects.count > 0 else { return }
        guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject else { return }
        if object.type == AVMetadataObject.ObjectType.qr {
            let alert = UIAlertController(title: "QR Code", message: object.stringValue, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Перейти", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Копировать", style: .default, handler: { _ in
                UIPasteboard.general.string = object.stringValue
                self.view.layer.sublayers?.removeLast()
                self.session.stopRunning()
            }))
            present(alert, animated: true, completion: nil)
        }
    }
    
}

