//
//  ReaderView.swift
//  barcode-reader-ios
//
//  Created by haayzaki on 2022/04/16.
//

import SwiftUI
import AVFoundation

enum ReaderRecordingStatus: String {
    case ready
    case start
    case stop
}

public protocol ReaderViewDelegate: AnyObject {
    func didFinishRecording(outputFileURL: URL)
}

public class UIReaderView: UIView, AVCaptureMetadataOutputObjectsDelegate {
    private var videoDevice: AVCaptureDevice?
    private var videoLayer : AVCaptureVideoPreviewLayer!
    private var prevlayer: AVCaptureVideoPreviewLayer!
    public weak var delegate: ReaderViewDelegate?
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let captureSession: AVCaptureSession = AVCaptureSession()
        videoDevice = defaultCamera()

        // video input setting
        let videoInput: AVCaptureDeviceInput = try! AVCaptureDeviceInput(device: videoDevice!)
        captureSession.addInput(videoInput)

        //アウトプット
        let output = AVCaptureMetadataOutput()
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureSession.addOutput(output)//プレビューアウトプットセット
        output.metadataObjectTypes = output.availableMetadataObjectTypes
        
        // preview layer
        prevlayer = AVCaptureVideoPreviewLayer(session: captureSession)
        prevlayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        // prevlayer.videoGravity = AVLayerVideoGravity.resizeAspect
        layer.addSublayer(prevlayer)

        // video quality setting
//        captureSession.beginConfiguration()
//        if captureSession.canSetSessionPreset(.hd4K3840x2160) {
//            captureSession.sessionPreset = .hd4K3840x2160
//        } else if captureSession.canSetSessionPreset(.high) {
//            captureSession.sessionPreset = .high
//        }
//        captureSession.commitConfiguration()

        captureSession.startRunning()
    }
    
    public override func layoutSubviews() {
        prevlayer.frame = bounds
    }
    
    func startRecording() {
        // start recording
        let tempDirectory: URL = URL(fileURLWithPath: NSTemporaryDirectory())
        let fileURL: URL = tempDirectory.appendingPathComponent("mytemp1.mov")
        // fileOutput.startRecording(to: fileURL, recordingDelegate: self)
    }
    
    func stopRecording() {
        // stop recording
        // fileOutput.stopRecording()
    }
    
    private func defaultCamera() -> AVCaptureDevice? {
        if let device = AVCaptureDevice.default(.builtInDualCamera, for: AVMediaType.video, position: .back) {
            return device
        } else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back) {
            return device
        } else {
            return nil
        }
    }
    
    // バーコードが見つかった時に呼ばれる
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        var highlightViewRect = CGRect.zero
        var barCodeObject : AVMetadataObject!
        var detectionString : String!
        
        //対応バーコードタイプ
        let barCodeTypes = [AVMetadataObject.ObjectType.upce,
                            AVMetadataObject.ObjectType.code39,
                            AVMetadataObject.ObjectType.code39Mod43,
                            AVMetadataObject.ObjectType.ean13,
                            AVMetadataObject.ObjectType.ean8,
                            AVMetadataObject.ObjectType.code93,
                            AVMetadataObject.ObjectType.code128,
                            AVMetadataObject.ObjectType.pdf417,
                            AVMetadataObject.ObjectType.qr,
                            AVMetadataObject.ObjectType.aztec
        ]
        
        //複数のバーコードの同時取得も可能
        for metadata in metadataObjects {
            for barcodeType in barCodeTypes {
                if metadata.type == barcodeType {
                    barCodeObject = self.prevlayer.transformedMetadataObject(for: metadata as! AVMetadataMachineReadableCodeObject)
                    highlightViewRect = barCodeObject.bounds
                    detectionString = (metadata as! AVMetadataMachineReadableCodeObject).stringValue
                    // self.session.stopRunning()
                    break
                }
            }
        }
        print(detectionString)
        self.prevlayer.frame = highlightViewRect
    }
}

extension UIReaderView: AVCaptureFileOutputRecordingDelegate {
    public func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        delegate?.didFinishRecording(outputFileURL: outputFileURL)
    }
}
    
struct ReaderView: UIViewRepresentable {
    @Binding var readerRecordingStatus: ReaderRecordingStatus
    let didFinishRecording: (_ outputFileURL: URL) -> Void
    
    final public class Coordinator: NSObject, ReaderViewDelegate {
        private var readerView: ReaderView
        let didFinishRecording: (_ outputFileURL: URL) -> Void
        init(_ readerView: ReaderView, didFinishRecording: @escaping (_ outputFileURL:URL) -> Void) {
            self.readerView = readerView
            self.didFinishRecording = didFinishRecording
        }
        
        func didFinishRecording(outputFileURL: URL) {
            didFinishRecording(outputFileURL)
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self, didFinishRecording: didFinishRecording)
    }
    
    func makeUIView(context: Context) -> UIReaderView {
        let uiReaderView = UIReaderView()
        uiReaderView.delegate = context.coordinator
        return uiReaderView
    }
    
    func updateUIView(_ uiView: UIReaderView, context: Context) {
        switch readerRecordingStatus {
        case .ready:
            return
        case .start:
            uiView.startRecording()
        case .stop:
            uiView.stopRecording()
        }
    }
}
