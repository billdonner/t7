//
//  phases.swift
//  t7
//
//  Created by bill donner on 12/9/23.
//

import Foundation
import q20kshare


func pumpPhase(_ userMessage:String) async  throws{
  print ("pumping...\(userMessage)")
  try await callAI(msg1:systemMessage,
                   msg2:userMessage,
         decoder:decodePumpingArray )
}
func validationPhase() async  throws {
  print("validating...")
  try await callAI(msg1:valsysMessage,
         msg2:qmeBuf,
         decoder:decodeValidationResponse )
}
func repairPhase(_ userMessage:String) async throws{
  print("repairing... \(userMessage)")
  try await callAI(msg1:repsysMessage,msg2:qmeBuf,
                   decoder:decodeQuestionsArray )
}
func revalidationPhase() async throws {
  print("revalidating...")
  try await callAI(msg1:valsysMessage,
         msg2:qmeBuf,
         decoder:decodeReValidationResponse )
}

enum Phases:Int {
  case pumping
  case validating
  case repairing
  case revalidating
  
  static func perform(_ performPhases:[Bool],jobno:String,msg:String) async throws {
 
    print("\n=========== Job \(jobno) ============")
   if performPhases[0] {try await pumpPhase(msg)} else {print ("Skipping pumpPhase")}
   if performPhases[1] {try await validationPhase()} else {print ("Skipping validationPhase")}
   if performPhases[2] {try await repairPhase(msg)} else {print ("Skipping repairPhase")}
   if performPhases[3] {try await revalidationPhase()} else {print ("Skipping revalidationPhase")}
  }
}

// Function to call the OpenAI API

fileprivate func decodeValidationResponse(_ content: String,_ started:Date, _ needscomma:Bool) throws {
  let elapsed = String(format:"%4.2f",Date().timeIntervalSince(started))
  print(">AI validation response \(content.count) bytes in \(elapsed) secs \n\(content)")
  if let validatedHandle = validatedHandle {
    validatedHandle.write(content.data(using:.utf8)!)
  }
}
fileprivate func decodeReValidationResponse(_ content: String,_ started:Date, _ needscomma:Bool) throws {
  let elapsed = String(format:"%4.2f",Date().timeIntervalSince(started))
  print(">AI revalidation response \(content.count) bytes in \(elapsed) secs \n\(content)")
  if let revalidatedHandle = revalidatedHandle {
    revalidatedHandle.write(content.data(using:.utf8)!)
  }
}

fileprivate func decodeQuestionsArray(_ content: String,_ started:Date, _ needscomma:Bool) throws {
  if gverbose {print("\(content)")}
  if let data = content.data(using:.utf8) {
    let zz = try JSONDecoder().decode([Challenge].self,from:data)
    let elapsed = String(format:"%4.2f",Date().timeIntervalSince(started))
    print(">assistant repair response \(zz.count) blocks elapsed \(elapsed) ok\n")
    qmeBuf = content // stash as string
    // append response with prepended comma if we need one
    if let repairedhandle=repairHandle {
      let str2 = content.dropFirst().dropLast()
      if !str2.isEmpty {
        if needscomma {
          repairedhandle.write(",".data(using: .utf8)!)
        }
        repairedhandle.write(str2.data(using:.utf8)!)
      }
    }
//    let encoder = JSONEncoder()
//    encoder.outputFormatting = .prettyPrinted
//    let data = try encoder.encode(zz)
//    let str = String(data:data,encoding: .utf8)
//    if let str = str , let repairedhandle = repairHandle {
//      let xyz = str.dropFirst().dropLast()
//      repairedhandle.write(xyz.data(using: .utf8)!)
//    }
  }
}

fileprivate func decodePumpingArray(_ content: String,_ started:Date, _ needscomma:Bool) throws {
  if gverbose {print("\(content)")}
  if let data = content.data(using:.utf8) {
    let zz = try JSONDecoder().decode([QuestionsModelEntry].self,from:data)
    let elapsed = String(format:"%4.2f",Date().timeIntervalSince(started))
    print(">assistant primary response \(zz.count) blocks elapsed \(elapsed) ok\n")
    // now convert the blocks into new format
    let zzz = zz.map {$0.makeChallenge()}
    let ppp = try JSONEncoder().encode(zzz)
    let str = String(data:ppp,encoding: .utf8) ?? ""
    qmeBuf = str // stash as string//     let encoder = JSONEncoder()
    if let pumpedHandle = pumpHandle {
      let str2 = str.dropFirst().dropLast()
      if !str2.isEmpty {
        if needscomma {
          pumpedHandle.write(",".data(using: .utf8)!)
        }
        pumpedHandle.write(str2.data(using:.utf8)!)
      }
    }
//    let encoder = JSONEncoder()
//    encoder.outputFormatting = .prettyPrinted
//    let data = try encoder.encode(zzz)
//    let str2 = String(data:data,encoding: .utf8)
//    if let str2 = str2 , let pumpedhandle = pumpHandle {
//      let xyz = str2.dropFirst().dropLast()
//      if !xyz.isEmpty {
//        let xx = xyz.data(using: .utf8)
//        if let xx = xx {
//          // append response with prepended comma if we need one
//          if notfirst {
//              pumpedhandle.write(",".data(using: .utf8)!)
//          } else {
//            notfirst = true
//          }
//          pumpedhandle.write(xx)
//        }
//      }
//    }
  }
}
typealias DecoderFunc =  (String,Date,Bool) throws -> Void

func callAI(msg1:String,msg2:String,
            decoder:@escaping DecoderFunc) async throws {
  try await callOpenAI(APIKey: apiKey,
             decoder: decoder,
             model: gmodel,
             systemMessage:  msg1,
             userMessage: msg2)
}
