////
// Copyright (c) whirlun <whirlun@yahoo.co.jp>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import SwiftUI

struct CardView: View {
    var body: some View {
        VStack {
            HStack{
                CardContentView()
                    .padding()
            }
            Spacer()
        }.frame(width: 230)
    }
}

struct CardContentView: View {
    @State var text_input = ""
    var body: some View {
        TextEditor(text: $text_input)
            .frame(width: 170, height: 90, alignment: .trailing)
            .scrollContentBackground(.hidden)
            .padding()
            .background(RoundedRectangle(cornerRadius: 6.0).fill(Color.blue))
    }
}
