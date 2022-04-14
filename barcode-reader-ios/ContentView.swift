//
//  ContentView.swift
//  barcode-reader-ios
//
//  Created by haayzaki on 2022/04/04.
//

import SwiftUI

struct ContentView: View {
    @State var recordingStatus: ReaderRecordingStatus = .ready
    var body: some View {
        VStack {
            Text("Hello, world!")
                .padding()
            ReaderView(readerRecordingStatus: $recordingStatus) { url in
                recordingStatus = .ready
                print(url)
            }
                .frame(width: 300, height: 400)
            Button(
                action: {
                    print("click")
                }, label: {
                    Text("ボタン").font(.largeTitle).padding(.all)
                })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
