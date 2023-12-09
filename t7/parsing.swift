//
//  parsing.swift
//  t7
//
//  Created by bill donner on 12/9/23.
//

import Foundation
import q20kshare
import ArgumentParser

struct T7: ParsableCommand   {
  
  static var configuration = CommandConfiguration(
    abstract: "Chat With AI To Generate Data for Q20K (IOS) App",
    discussion: "Step 1 - ask the AI to generate question blocks\nStep 2 - ask the AI to identify problems in generated data\nStep 3 - ask the AI to repair the data\nStep 4 - ask the AI to again identify problems in generated data",
    version: t7_version )
  
  @Argument(help: "pumper system template")
  var pumpsys: String
  
  @Argument( help:"pumper user template")
  var pumpusr: String
  
  @Option(help: "validation system template, default is \"\"")
  var valsys: String = ""
  
  @Option( help:"validation user template, default is \"\"")
  var valusr: String = ""
  
  @Option(help: "repair system template, default is \"\"")
  var repsys: String = ""
  
  @Option( help:"repair user template, default is \"\"")
  var repusr: String = ""
  
  @Option( help:"alternate pumper input file, default is \"\"")
  var altpumpurl: String = ""
  
  @Option( help:"model")
  var model: String = "gpt-4"
  
  @Flag(help:"don't run validation step")
  var skipvalidation: Bool = false
  
  @Flag(help:"don't run repair step")
  var skiprepair: Bool = false
  
  @Flag(help:"don't run re-validation step")
  var skiprevalidation: Bool = false
  
  
  
  mutating func process_cli() throws {
    // get required template data, no defaults
    guard let sys = URL(string:pumpsys) else {
      fatalError("Invalid system template URL")
    }
    guard let usr = URL(string:pumpusr) else {
      fatalError("Invalid user template URL")
    }
    let sysMessage = try String(data:Data(contentsOf:sys),encoding: .utf8)
    guard let sysMessage = sysMessage else { fatalError("Cant decode system template")
    }
    systemMessage = sysMessage
    
    let userMessage = try String(data:Data(contentsOf:usr),encoding: .utf8)
    guard let userMessage = userMessage else {
      fatalError("Cant decode user template")
    }
    usrMessage = userMessage
    // if these are missing they default
    
    if valusr == "" {
      valusrMessage = ""
    } else {
      guard let valusr = URL(string:valusr) else {
        fatalError("Invalid validation user template URL")
      }
      valusrMessage = try String(data:Data(contentsOf:valusr),encoding: .utf8) ?? ""
    }
    
    if valsys == "" {
      valsysMessage = ""
    } else {
      guard let valsys = URL(string:valsys) else {
        fatalError("Invalid validation system template URL")
      }
      valsysMessage = try String(data:Data(contentsOf:valsys),encoding: .utf8) ?? ""
    }
    if repusr == "" {
      repusrMessage = ""
    } else {
      guard let repusr = URL(string:repusr) else {
        fatalError("Invalid repair user template URL")
      }
      repusrMessage = try String(data:Data(contentsOf:repusr),encoding: .utf8) ?? ""
    }
    if repsys == "" {
      repsysMessage = ""
    } else {
      guard let repsys = URL(string:repsys) else {
        fatalError("Invalid repair system template URL")
      }
      repsysMessage = try String(data:Data(contentsOf:repsys),encoding: .utf8) ?? ""
    }
  }
  func runAICycle () {
    var phases:[Bool] = [true]
    phases += [!skipvalidation]
    phases += [!skiprepair]
    phases += [!skiprevalidation]
    Phases.perform(phases)
    
  }
  
  mutating func run() throws {
    do {
      try process_cli()
    }
    catch {
      print("Error -> \(error)")
      print("command line processing failed ")
    }
    
    showTemplates()
    
    let apiKey = try getAPIKey()
    
    runAICycle()
    
  }
}
 
