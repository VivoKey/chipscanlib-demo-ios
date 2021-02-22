//
//  ContentView.swift
//  VivoKey ChipScan Example
//
//  Created by Ryuuzaki on 2021/02/16.
//

import SwiftUI
import ChipscanlibSwift


struct ContentView: View {

   @EnvironmentObject var reader: Reader

   @State var setKey: String = "Key 1"
   @State var setValue: String = "Value 1"

   @State var getKey: String = "Key 1"

   var body: some View {
      ScrollView {

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





         VStack {
            HStack {
               Text("Set Key:")
               //                  .padding()
               TextField("Result:", text: $setKey)
                  .textFieldStyle(RoundedBorderTextFieldStyle())
                  //                  .padding()
                  .foregroundColor(.accentColor)
               Spacer()
            }
            HStack {
               Text("Set Value:")
               //                  .padding()
               TextField("Result:", text: $setValue)
                  .textFieldStyle(RoundedBorderTextFieldStyle())
                  .foregroundColor(.accentColor)
               //                  .padding()
               Spacer()
            }
            HStack {
               Text("Message:")
               //                  .padding()
               Text(reader.setResultMessage)
               //                  .padding()
               Spacer()
            }
            Button("Set Value for Key", action: beginSet)
               .padding()
               .background(Color("darkBlue"))
               .cornerRadius(10)
            //               .padding()
            Spacer()
         }
         .padding(.horizontal)


         VStack {
            HStack {
               Text("Get Key:")
               //                  .padding()
               TextField("Result:", text: $getKey)
                  .textFieldStyle(RoundedBorderTextFieldStyle())
                  //                  .padding()
                  .foregroundColor(.accentColor)
               Spacer()
            }
            HStack {
               Text("Get Value:")
               //                  .padding()
               Text(reader.gotValue)
                  .textFieldStyle(RoundedBorderTextFieldStyle())
               //                  .padding()
               Spacer()
            }
            HStack {
               Text("Message:")
               //                  .padding()
               Text(reader.getResultMessage)
               //                  .padding()
               Spacer()
            }
            Button("Get Value for Key", action: beginGet)
               .padding()
               .background(Color("darkBlue"))
               .cornerRadius(10)
            //               .padding()
            Spacer()
         }
         .padding(.horizontal)






      }
      .background(Color("backgroundBlue").ignoresSafeArea(.all))
      .foregroundColor(.white)
   }

   func beginScan() {
      reader.beginScan()
   }

   func beginSet() {
      reader.beginSet(key: setKey, value: setValue)
   }

   func beginGet() {
      reader.beginGet(key: getKey)
   }
}

struct ContentView_Previews: PreviewProvider {
   static let reader = Reader()
   static var previews: some View {
      ContentView()
         .environmentObject(reader)
   }
}
