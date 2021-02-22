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
            Text("- User Info -")
            HStack {
               Text("Tag ID:")
               Text(reader.chipID)
               Spacer()
            }
            HStack {
               Text("Result:")
               Text(reader.memberType)
               Spacer()
            }
            HStack {
               Text("Message:")
               Text(reader.memberID)
                  .lineLimit(6)
               Spacer()
            }
         }
         .padding()
         .background(Color.black.opacity(0.2))
         HStack {
            Button("Get Challenge", action: beginScan)
               .padding()
               .background(Color("darkBlue"))
               .cornerRadius(10)
            Button("Clear", action: clearScan)
               .padding()
               .background(Color("darkBlue"))
               .cornerRadius(10)

         }

         VStack {
            Text("- SET Data -")
            HStack {
               Text("Set Key:")
               TextField("Result:", text: $setKey)
                  .textFieldStyle(RoundedBorderTextFieldStyle())
                  .foregroundColor(.accentColor)
               Spacer()
            }
            HStack {
               Text("Set Value:")
               TextField("Result:", text: $setValue)
                  .textFieldStyle(RoundedBorderTextFieldStyle())
                  .foregroundColor(.accentColor)
               Spacer()
            }
            HStack {
               Text("Message:")
               Text(reader.setResultMessage)
               Spacer()
            }
         }
         .padding()
         .background(Color.black.opacity(0.2))

         HStack {
            Spacer()
            Button("Set Value for Key", action: beginSet)
               .padding()
               .background(Color("darkBlue"))
               .cornerRadius(10)
         }
         .padding(.horizontal)

         VStack {
            Text("- GET Data -")
            HStack {
               Text("Get Key:")
               TextField("Result:", text: $getKey)
                  .textFieldStyle(RoundedBorderTextFieldStyle())
                  .foregroundColor(.accentColor)
               Spacer()
            }
            HStack {
               Text("Get Value:")
               Text(reader.gotValue)
                  .textFieldStyle(RoundedBorderTextFieldStyle())
               Spacer()
            }
            HStack {
               Text("Message:")
               Text(reader.getResultMessage)
               Spacer()
            }
         }
         .padding()
         .background(Color.black.opacity(0.2))

         HStack {
            Spacer()
            Button("Get Value for Key", action: beginGet)
               .padding()
               .background(Color("darkBlue"))
               .cornerRadius(10)
         }
         .padding(.horizontal)
      }
      .background(Color("backgroundBlue").ignoresSafeArea(.all))
      .foregroundColor(.white)
   }

   func beginScan() {
      reader.beginScan()
   }

   func clearScan() {
      reader.vivoAuthResult = nil
      reader.chipID = "Get Challenge First"
      reader.memberType = "Get Challenge First"
      reader.memberID = "Get Challenge First"
   }

   func beginSet() {
      if (reader.vivoAuthResult != nil) {
         reader.setResultMessage = "Setting Key-Value..."
         reader.beginSet(key: setKey, value: setValue)
      } else {
         reader.setResultMessage = "Get Challenge First"
      }

   }

   func beginGet() {
      if (reader.vivoAuthResult != nil) {
         reader.getResultMessage = "Getting Value..."
         reader.gotValue = "Getting Value..."
         reader.beginGet(key: getKey)
      } else {
         reader.getResultMessage = "Get Challenge First"
         reader.gotValue = "Get Challenge First"
      }
   }
}

struct ContentView_Previews: PreviewProvider {
   static let reader = Reader()
   static var previews: some View {
      ContentView()
         .environmentObject(reader)
   }
}
