//
//  phases.swift
//  t7
//
//  Created by bill donner on 12/9/23.
//

import Foundation

func pumpPhase(_ userMessage:String) {
  print ("pumping...\(userMessage)")
  callAI(msg1:systemMessage,
         msg2:userMessage,
         decoder:decodeQMEArray(_:))
}
func validationPhase() {
  print("validating...")
  //callAI(msg1:valsysMessage,msg2:qmeBuf)
}
func repairPhase(_ userMessage:String) {
  print("repairing... \(userMessage)")
  callAI(msg1:repsysMessage,msg2:qmeBuf,
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
  
  static func perform(_ performPhases:[Bool],jobno:String,msg:String) {
 
    print("\n=========== Job \(jobno) ============")
   if performPhases[0] {pumpPhase(msg)} else {print ("Skipping pumpPhase")}
   if performPhases[1] {validationPhase()} else {print ("Skipping validationPhase")}
   if performPhases[2] {repairPhase(msg)} else {print ("Skipping repairPhase")}
   if performPhases[3] {revalidationPhase()} else {print ("Skipping revalidationPhase")}
  }
}


// Function to call the OpenAI API

fileprivate func decodeQuestionsArray(_ content: String) throws {
  print("\(content)")
  if let data = content.data(using:.utf8) {
    let zz = try JSONDecoder().decode([QuestionsEntry].self,from:data)
    print(">assistant repair response \(zz.count) blocks ok\n")
    qmeBuf = content // stash as string
    // }
  }
}
fileprivate func decodeQMEArray(_ content: String) throws {
  print("\(content)")
  if let data = content.data(using:.utf8) {
    let zz = try JSONDecoder().decode([QuestionsModelEntry].self,from:data)
    print(">assistant primary response \(zz.count) blocks ok\n")
    
    // now convert the blocks into new format
    let zzz = zz.map {QuestionsEntry(from:$0)}
    let ppp = try JSONEncoder().encode(zzz)
    let str = String(data:ppp,encoding: .utf8) ?? ""
    qmeBuf = str // stash as string// }
  }
}
func callAI(msg1:String,msg2:String,
            decoder:@escaping ((String) throws -> Void )){
  let time1 = Date()
  let semaphore = DispatchSemaphore(value: 0)
  
  callOpenAI(APIKey: apiKey,
             semaphore:semaphore,
             decoder: decoder,
             model: gmodel,
             systemMessage:  msg1,
             userMessage: msg2)
  semaphore.wait()
  let elapsed = Date().timeIntervalSince(time1)
  print(">ChatGPT \(gmodel) returned in \(elapsed) secs")
}
