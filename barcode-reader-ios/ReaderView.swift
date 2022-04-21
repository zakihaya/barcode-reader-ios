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
    case stop
}

public protocol ReaderViewDelegate: AnyObject {
    func didFinishRead(code: String?)
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
        if let targetVideoDevice = videoDevice {
            let videoInput: AVCaptureDeviceInput = try! AVCaptureDeviceInput(device: targetVideoDevice)
            captureSession.addInput(videoInput)
        }

        // output
        let output = AVCaptureMetadataOutput()
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureSession.addOutput(output) //プレビューアウトプットセット
        output.metadataObjectTypes = output.availableMetadataObjectTypes
        
        // preview layer
        prevlayer = AVCaptureVideoPreviewLayer(session: captureSession)
        prevlayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        // prevlayer.videoGravity = AVLayerVideoGravity.resizeAspect
        layer.addSublayer(prevlayer)

        captureSession.startRunning()
    }
    
    public override func layoutSubviews() {
        prevlayer.frame = bounds
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
        var detectionString : String?
        
        // 対応バーコードタイプ
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
        
        // 複数のバーコードの同時取得も可能
        for metadata in metadataObjects {
            for barcodeType in barCodeTypes {
                if metadata.type == barcodeType {
                    barCodeObject = self.prevlayer.transformedMetadataObject(for: metadata as! AVMetadataMachineReadableCodeObject)
                    highlightViewRect = barCodeObject.bounds
                    if let codeObject = metadata as? AVMetadataMachineReadableCodeObject {
                        detectionString = codeObject.stringValue
                    }
                    // self.session.stopRunning()
                    break
                }
            }
        }
        debugPrint("ReaderView:", detectionString ?? "unknown code")
        delegate?.didFinishRead(code: detectionString)
        self.prevlayer.frame = highlightViewRect
    }
}
    
struct ReaderView: UIViewRepresentable {
    @Binding var readerRecordingStatus: ReaderRecordingStatus
    let didFinishRead: (_ code: String?) -> Void
    
    final public class Coordinator: NSObject, ReaderViewDelegate {
        private var readerView: ReaderView
        let didFinishRead: (_ code: String?) -> Void
        init(_ readerView: ReaderView, didFinishRead: @escaping (_ code:String?) -> Void) {
            self.readerView = readerView
            self.didFinishRead = didFinishRead
        }
        
        func didFinishRead(code: String?) {
            didFinishRead(code)
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self, didFinishRead: didFinishRead)
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
        case .stop:
            return
        }
    }
}
