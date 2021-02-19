//
//  Reader.swift
//  VivoKey ChipScan Example
//
//  Created by Ryuuzaki on 2021/02/19.
//

import CoreNFC
import chipscanlib_swift

class Reader: NSObject, NFCTagReaderSessionDelegate, ObservableObject {
   var session: NFCTagReaderSession?

   @Published var chipID = "Start Scan"
   @Published var memberType = "----"
   @Published var memberID = "----"

   let vivoAuth: VivoAuthenticator = VivoAuthenticator(apikey: "130d3e43391e36820c82b2b8aa591b71e1d990239439bec57dc9a8056684")

   override init() {
      super.init()
   }

   func beginScan() {
      // Set up to scan for Spark2 and Spark1 chips.
      self.session = NFCTagReaderSession(pollingOption: [.iso14443, .iso15693], delegate: self, queue: .main)
      self.session?.alertMessage = "Hold Your iPhone Near Your VivoKey"
      self.session?.begin()

      DispatchQueue.main.async {
         self.chipID = "STARTED SCAN"
         self.memberType = "STARTED SCAN"
         self.memberID = "STARTED SCAN"
      }
   }

   func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
      //      print(session.connectedTag ?? "Session did become active")
   }

   func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
      session.invalidate(errorMessage: error.localizedDescription)
   }

   func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
      // GOT SPARK2, Only need to read NDEF data.
      if case let NFCTag.iso7816(tag) = tags.first! {
         print("==============GOT ISO7816==============")
         session.connect(to: tags.first!) { (error: Error?) in
            if let error = error {
               self.session?.invalidate(errorMessage: error.localizedDescription)
               return
            }

            var vtag: VivoTag?
            if(tag.initialSelectedAID == "D2760000850101" || tag.initialSelectedAID == "D2760000850100") {
               print("==============GOT SPARK==============")
               vtag = VivoTag(tag: tag, sub: VivoTag.NTAG4XX)
            } else if (tag.initialSelectedAID == "A00000074700CC68E88C01") {
               print("==============GOT APEX==============")
               vtag = VivoTag(tag: tag, sub: VivoTag.APEX)
            }

            self.vivoAuth.setTag(receivedTag: vtag!)

            self.vivoAuth.run { result in

               DispatchQueue.main.async {
                  print("Chip ID: \(result.chipid)")
                  print("Member Type: \(result.membertype)")
                  print("Member ID: \(result.memberid)")
                  self.chipID = result.chipid
                  self.memberType = result.membertype
                  self.memberID = result.memberid
               }
               session.invalidate()

            }
         }
      }

      // GOT SPARK1, Need to perform Tam1 Challenge from tokenJSON and return result
      if case let NFCTag.iso15693(tag) = tags.first! {
         print(tag.identifier.description)
         print("==============GOT SPARK 1==============")
         session.connect(to: tags.first!) { error in
            if let error = error  {
               self.session?.invalidate(errorMessage: error.localizedDescription)
               return
            }

            // ADD CODE HERE FOR SPARK1



         }
      }
   }
}


