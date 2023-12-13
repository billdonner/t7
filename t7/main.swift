//
//  main.swift
//  t7
//
//  Created by bill donner on 12/9/23.
//

import Foundation
import q20kshare
import ArgumentParser

let t7_version = "0.3.5"

struct QuestionsModelEntry: Codable {
  let question:String
  let answers:[String]
  let correct:String
  let explanation:String
  let hint:String
}
struct QuestionsEntry: Codable {
  let id:String
  let tod:Date
  let question:String
  let answers:[String]
  let correct:String
  let explanation:String
  let hint:String
  
  init(from:QuestionsModelEntry) {
    id = UUID().uuidString
    tod = Date()
    question = from.question
    answers = from.answers
    correct = from.correct
    explanation = from.explanation
    hint = from.hint
  }
}

var qmeBuf:String = ""
var bufPumpValidate: String = ""
var bufValidateRepair: String = ""
var bufRepairRevalidate: String = ""

var valusrMessage : String = ""
var valsysMessage : String = ""
var repusrMessage : String = ""
var repsysMessage : String = ""
var systemMessage : String = ""
var usrMessage : String = ""

var gmodel:String = ""
var gverbose: Bool = false
var apiKey:String = ""

var skipvalidation: Bool = true
var skiprepair: Bool = false
var skiprevalidation: Bool = true

var pumpHandle: FileHandle?
var repairHandle: FileHandle?

var firstrepaired = false
var firstpumped = false

var phasescount = 4


func showTemplates() {
  print("+========T E M P L A T E S =========+")
  print("<<<<<<<<systemMessage>>>>>>>>>>",systemMessage)
  print("<<<<<<<<usrMessage>>>>>>>>>>","--displayed per api cycle--")
  print("<<<<<<<<valusrMessage>>>>>>>>>>",valusrMessage)
  print("<<<<<<<<valsysMessage>>>>>>>>>>",valsysMessage)
  print("<<<<<<<<repusrMessage>>>>>>>>>>",repusrMessage)
  print("<<<<<<<<repsysMessage>>>>>>>>>>",repsysMessage)
  print("+====== E N D  T E M P L A T E S =====+")
}

func runAICycle (_ userMessage:String,jobno:String) async throws{
  var phases:[Bool] = [true]// [altpump.isEmpty]

  phases += [!skipvalidation]
  phases += [!skiprepair]
  phases += [!skiprevalidation]
  try await Phases.perform(phases, jobno: jobno,msg:userMessage)
}


func bigLoop () {
//  defer {
//    if let pumpedhandle = pumpHandle {
//      // pumpedhandle.write()
//      pumpedhandle.write("]".data(using: .utf8)!)
//      try? pumpedhandle.close()
//    }
//    if let repairedhandle = repairHandle {
//      repairedhandle.write("]".data(using: .utf8)!)
//      try? repairedhandle.close()
//    }
//  }
  let tmsgs = usrMessage.components(separatedBy: "*****")
  let umsgs = tmsgs.compactMap{$0.trimmingCharacters(in: .whitespacesAndNewlines)}
  phasescount = umsgs.count
      Task  {
        for str in umsgs {
        try await   runAICycle(str, jobno: UUID().uuidString)
          phasescount -= 1
      }
    }
}

T7.main()

bigLoop()
while phasescount > 0  {
  sleep(10)
  print("|",terminator:"")
}
print("\nExiting, all work completed to the best of our abilities.")
