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
var apiKey:String = ""

var skipvalidation: Bool = false
var skiprepair: Bool = false
var skiprevalidation: Bool = false

var pumpedhandle: FileHandle?
var repairedhandle: FileHandle?

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
  T7.main()
