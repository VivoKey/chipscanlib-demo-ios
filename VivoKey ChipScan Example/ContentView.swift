//
//  ContentView.swift
//  VivoKey ChipScan Example
//
//  Created by Ryuuzaki on 2021/02/16.
//

import SwiftUI
import chipscanlib_swift

struct ContentView: View {

   @EnvironmentObject var reader: Reader

    var body: some View {
      VStack {

         VStack {
            Text("VivoKey ChipScan Library")
               .font(.title)
            Text("Demo App")
               .font(.title2)
         }

         VStack {
            HStack {
               Text("Tag ID:")
                  .padding()
               Text(reader.chipID)
                  .padding()
               Spacer()
            }
            HStack {
               Text("Result:")
                  .padding()
               Text(reader.memberType)
                  .padding()
               Spacer()
            }
            HStack {
               Text("Message:")
                  .padding()
               Text(reader.memberID)
                  .padding()
               Spacer()
            }
         }
         .padding(.vertical)
         .background(Color.black.opacity(0.2))
         Button("Get challenge", action: beginScan)
            .padding()
            .background(Color("darkBlue"))
            .cornerRadius(10)
            .padding()
         Spacer()
      }
      .background(Color("backgroundBlue").ignoresSafeArea(.all))
      .foregroundColor(.white)
    }

   func beginScan() {
      reader.beginScan()
   }
}

struct ContentView_Previews: PreviewProvider {
   static let reader = Reader()
    static var previews: some View {
        ContentView()
         .environmentObject(reader)
    }
}
