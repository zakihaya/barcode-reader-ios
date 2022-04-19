//
//  ContentView.swift
//  barcode-reader-ios
//
//  Created by haayzaki on 2022/04/04.
//

import SwiftUI

struct ContentView: View {
    @State var recordingStatus: ReaderRecordingStatus = .ready
    @State var canRead: Bool = false
    @State var labelText: String = ""

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
                labelText = code ?? ""
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
