//
//  ContentView.swift
//  barcode-reader-ios
//
//  Created by haayzaki on 2022/04/04.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State var recordingStatus: ReaderRecordingStatus = .ready
    @State var canRead: Bool = false
    @State var labelText: String = ""
    @State var soundPlayer = SoundPlayer()

    var body: some View {
        VStack {
            Text(labelText)
                .font(.system(size: 50, weight: .black, design: .default))
                .padding()
            ReaderView(readerRecordingStatus: $recordingStatus) { code in
                recordingStatus = .ready
                if (!canRead) {
                    return
                }
                canRead = false
                
                let digit = Int.random(in: 1...5)
                // 指数部をIntにするとDecimalが返ってきてしまい、変換が面倒になる
                let max = Int(pow(10, Float(digit)) - 1)
                let min = Int(pow(10, Float(digit - 1)))
                let price = Int.random(in: min...max)

                soundPlayer.playForPrice(price)
                labelText = "\(String(price)) 円"
            }
                .frame(width: 300, height: 400)
            if (!canRead) {
                Button(
                    action: {
                        canRead = true
                        labelText = "読み取り中"
                    }, label: {
                        Text("読み取り").font(.largeTitle).padding(.all)
                    })
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
