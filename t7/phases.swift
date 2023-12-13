//
//  phases.swift
//  t7
//
//  Created by bill donner on 12/9/23.
//

import Foundation

func pumpPhase(_ userMessage:String) async  throws{
  print ("pumping...\(userMessage)")
  try await callAI(msg1:systemMessage,
         msg2:userMessage,
         decoder:decodeQMEArray(_:))
}
func validationPhase() {
  print("validating...")
  //callAI(msg1:valsysMessage,msg2:qmeBuf)
}
func repairPhase(_ userMessage:String) async throws{
  print("repairing... \(userMessage)")
  try await callAI(msg1:repsysMessage,msg2:qmeBuf,
         decoder:decodeQuestionsArray(_:))
}
func revalidationPhase() {
  print("revalidating...")
}

enum Phases:Int {
  case pumping
  case validating
  case repairing
  case revalidating
  
  static func perform(_ performPhases:[Bool],jobno:String,msg:String) async throws {
 
    print("\n=========== Job \(jobno) ============")
   if performPhases[0] {try await pumpPhase(msg)} else {print ("Skipping pumpPhase")}
   if performPhases[1] {validationPhase()} else {print ("Skipping validationPhase")}
   if performPhases[2] {try await repairPhase(msg)} else {print ("Skipping repairPhase")}
   if performPhases[3] {revalidationPhase()} else {print ("Skipping revalidationPhase")}
  }
}

// Function to call the OpenAI API

fileprivate func decodeQuestionsArray(_ content: String) throws {
  if gverbose {print("\(content)")}
  if let data = content.data(using:.utf8) {
    let zz = try JSONDecoder().decode([QuestionsEntry].self,from:data)
    print(">assistant repair response \(zz.count) blocks ok\n")
    qmeBuf = content // stash as string
    // append response with prepended comma if we need one
    if !firstrepaired ,let repairedhandle=repairHandle {
     repairedhandle.write(",".data(using: .utf8)!)
    } else {
      firstrepaired  = false
    }
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let data = try encoder.encode(zz)
    let str = String(data:data,encoding: .utf8)
    if let str = str , let repairedhandle = repairHandle {
      let xyz = str.dropFirst().dropLast()
      repairedhandle.write(xyz.data(using: .utf8)!)
    }
  }
}
fileprivate func decodeQMEArray(_ content: String) throws {
  if gverbose {print("\(content)")}
  if let data = content.data(using:.utf8) {
    let zz = try JSONDecoder().decode([QuestionsModelEntry].self,from:data)
    print(">assistant primary response \(zz.count) blocks ok\n")
    
    // now convert the blocks into new format
    let zzz = zz.map {QuestionsEntry(from:$0)}
    let ppp = try JSONEncoder().encode(zzz)
    let str = String(data:ppp,encoding: .utf8) ?? ""
    qmeBuf = str // stash as string//
    

    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let data = try encoder.encode(zzz)
    let str2 = String(data:data,encoding: .utf8)
    if let str2 = str2 , let pumpedhandle = pumpHandle {
      let xyz = str2.dropFirst().dropLast()
      if !xyz.isEmpty {
        let xx = xyz.data(using: .utf8)
        if let xx = xx {
          // append response with prepended comma if we need one
          if !firstpumped {
         //// pumpedhandle.write(",".data(using: .utf8)!)
          } else {
            firstpumped  = false
          }
          pumpedhandle.write(xx)
          pumpedhandle.write(",".data(using: .utf8)!)
        }
      }
    }
  }
}
func callAI(msg1:String,msg2:String,
            decoder:@escaping ((String) throws -> Void )) async throws {
  let time1 = Date()
  try await callOpenAI(APIKey: apiKey,
             decoder: decoder,
             model: gmodel,
             systemMessage:  msg1,
             userMessage: msg2)
 
  let elapsed = Date().timeIntervalSince(time1)
  print(">ChatGPT \(gmodel) returned in \(elapsed) secs")
}
