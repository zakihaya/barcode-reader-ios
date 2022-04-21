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
                .padding()
            ReaderView(readerRecordingStatus: $recordingStatus) { code in
                recordingStatus = .ready
                if (!canRead) {
                    return
                }
                canRead = false
                
                // TODO: 金額指定ロジックの修正
                let prices = [100, 200, 300, 400, 500, 600, 700, 800, 900]
                let price = prices.randomElement() ?? 300
                
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
