//
//  ContentView.swift
//  barcode-reader-ios
//
//  Created by haayzaki on 2022/04/04.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    let scanningText = "読み取り中"

    @State var recordingStatus: ReaderRecordingStatus = .ready
    @State var canRead: Bool = false
    @State var labelText: String = ""
    @State var soundPlayer = SoundPlayer()

    var body: some View {
        VStack {
            if (labelText == "" || labelText == scanningText) {
                Text(labelText)
                    .font(.system(size: 50, weight: .black, design: .default))
                    .padding()
            } else {
                Button(
                    action: {
                        soundPlayer.playForPrice(labelText)
                    }, label: {
                        Text(labelText)
                            .font(.system(size: 50, weight: .black, design: .default))
                            .padding()
                    })
            }
            ReaderView(readerRecordingStatus: $recordingStatus) { code in
                recordingStatus = .ready
                if (!canRead) {
                    return
                }
                canRead = false
                
                let price = getPrice()
                labelText = "\(String(price)) 円"
                soundPlayer.playForPrice(labelText)
            }
                .frame(width: 300, height: 400)
            if (!canRead) {
                Button(
                    action: {
                        canRead = true
                        labelText = scanningText
                    }, label: {
                        Text("読み取り").font(.largeTitle).padding(.all)
                    })
            }
        }
    }
    
    func getPrice() -> Int {
        // 4桁まで
        let digit = Int.random(in: 1...4)
        // 指数部をIntにするとDecimalが返ってきてしまい、変換が面倒になる
        let max = Int(pow(10, Float(digit)) - 1)
        let min = Int(pow(10, Float(digit - 1)))
        return Int.random(in: min...max)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
