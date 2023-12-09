//
//  main.swift
//  t7
//
//  Created by bill donner on 12/9/23.
//

import Foundation
import q20kshare
import ArgumentParser

let t7_version = "0.3.4"
var valusrMessage : String = ""
var valsysMessage : String = ""
var repusrMessage : String = ""
var repsysMessage : String = ""
var systemMessage : String = ""
var usrMessage : String = ""

func showTemplates() {
  print("+========T E M P L A T E S =========+")
  print("<<<<<<<<systemMessage>>>>>>>>>>",systemMessage)
  print("<<<<<<<<usrMessage>>>>>>>>>>",usrMessage)
  print("<<<<<<<<valusrMessage>>>>>>>>>>",valusrMessage)
  print("<<<<<<<<valsysMessage>>>>>>>>>>",valsysMessage)
  print("<<<<<<<<repusrMessage>>>>>>>>>>",repusrMessage)
  print("<<<<<<<<repsysMessage>>>>>>>>>>",repsysMessage)
  print("+====== E N D  T E M P L A T E S =====+")
}

  T7.main()

//      guard listmodels == false  else {
//        listModels(apiKey: apiKey)
//        return
//      }
  
  

  
  
  
  
  /**
   print(">Calling ChatGPT \(model)")
   print("system: ",systemMessage)
   let time1 = Date()
   var i = 0
   let tmsgs = usrMessage.components(separatedBy: "*****")
   let umsgs = tmsgs.compactMap{$0.trimmingCharacters(in: .whitespacesAndNewlines)}
   umsgs.forEach { umsg in
   i += 1
   print("\n=========== Task \(i) ============")
   print("\n>user: ",umsg)
   
   let semaphore = DispatchSemaphore(value: 0)
   callOpenAI(APIKey: apiKey,
   semaphore:semaphore,
   model: model,
   systemMessage:  systemMessage,
   userMessage: umsg,
   ldmode: ldmode)
   
   semaphore.wait()
   let elapsed = Date().timeIntervalSince(time1)
   print(">ChatGPT \(model) returned in \(elapsed) secs")
   }
   */

