//
//  Reader.swift
//  VivoKey ChipScan Example
//
//  Created by Ryuuzaki on 2021/02/19.
//

import CoreNFC
import ChipscanlibSwift



class Reader: NSObject, NFCTagReaderSessionDelegate, ObservableObject {
   var session: NFCTagReaderSession?

   @Published var chipID = "Get Challenge First"
   @Published var memberType = "Get Challenge First"
   @Published var memberID = "Get Challenge First"

   let vivoAuth: VivoAuthenticator = VivoAuthenticator(apikey: "PUT-YOUR-KEY-HERE")


   // Keeping Result
   var vivoAuthResult: VivoAuthResult? = nil

   // For displaying
   @Published var setResultMessage: String = "set result message"
   @Published var getResultMessage: String = "get result message"
   @Published var gotValue: String = "get value result"


   override init() {
      super.init()
   }

   func beginScan() {
      // Set up to scan for Spark2 and Spark1 chips.
      self.session = NFCTagReaderSession(pollingOption: [.iso14443, .iso15693], delegate: self, queue: .main)
      self.session?.alertMessage = "Hold Your iPhone Near Your VivoKey"
      self.session?.begin()
      self.vivoAuth.getChallenge()
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

            if vtag == nil {
               session.invalidate(errorMessage: "NOT A VIVOKEY?")
               return
            }

            self.vivoAuth.setTag(receivedTag: vtag!)

            self.vivoAuth.run { result in
               // Saving result on class variable to make SET GET calls latter.
               self.vivoAuthResult = result
               print("Chip ID: \(result.chipId)")
               print("Member Type: \(result.memberType)")
               print("Member ID: \(result.memberId)")
               self.chipID = tag.identifier.hexEncodedString()
               self.memberType = result.memberType
               self.memberID = result.memberId
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
            let vtag = VivoTag(tag: tag)
            print("tag uid: ", vtag.getUid())
            
            self.vivoAuth.setTag(receivedTag: vtag)

            self.vivoAuth.run { result in
               // Saving result on class variable to make SET GET calls latter.
               self.vivoAuthResult = result
               print("Chip ID: \(result.chipId)")
               print("Member Type: \(result.memberType)")
               print("Member ID: \(result.memberId)")
               self.chipID = tag.identifier.hexEncodedString()
               self.memberType = result.memberType
               self.memberID = result.memberId
               session.invalidate()
            }
         }
      }
   }


   // FOR KEY VALUE STORE:

   func beginSet(key: String, value: String) {
      // result from vivoAuth.run { result is saved in self.vivoAuthResult

      guard let vivoKeyAuth = self.vivoAuthResult else { return }

      let keyValueAPI = VivoKVAPI(authres: vivoKeyAuth)
      keyValueAPI.setKV(keyvals: [key: value])
      keyValueAPI.runSetKV() {response in
         // return message (success or fail) to published variable self.setResultMessage async
         // Example:
         DispatchQueue.main.async {
            self.setResultMessage = response
         }
      }
   }

   func beginGet(key: String) {
      // result from vivoAuth.run { result is saved in self.vivoAuthResult
      // return message (success or fail) to published variable self.getResultMessage async
      // if successful, write obtained value to self.gotValue async

      guard let vivoKeyAuth = self.vivoAuthResult else { return }

      let keyValueAPI = VivoKVAPI(authres: vivoKeyAuth)
      keyValueAPI.getKV(keyvals: [key])
      keyValueAPI.runGetKV() { response in
         self.getResultMessage = response?.getResultCode() ?? ""
         self.gotValue = response?.getKV()[key] ?? ""

      }
   }
}


extension Data {
   struct HexEncodingOptions: OptionSet {
      let rawValue: Int
      static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
   }

   func hexEncodedString(options: HexEncodingOptions = []) -> String {
      let hexDigits = options.contains(.upperCase) ? "0123456789ABCDEF" : "0123456789abcdef"
      if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
         let utf8Digits = Array(hexDigits.utf8)
         return String(unsafeUninitializedCapacity: 2 * count) { (ptr) -> Int in
            var p = ptr.baseAddress!
            for byte in self {
               p[0] = utf8Digits[Int(byte / 16)]
               p[1] = utf8Digits[Int(byte % 16)]
               p += 2
            }
            return 2 * count
         }
      } else {
         let utf16Digits = Array(hexDigits.utf16)
         var chars: [unichar] = []
         chars.reserveCapacity(2 * count)
         for byte in self {
            chars.append(utf16Digits[Int(byte / 16)])
            chars.append(utf16Digits[Int(byte % 16)])
         }
         return String(utf16CodeUnits: chars, count: chars.count)
      }
   }
}
