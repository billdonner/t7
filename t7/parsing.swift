//
//  parsing.swift
//  t7
//
//  Created by bill donner on 12/9/23.
//

import Foundation
import q20kshare
import ArgumentParser
func prep(_ x:String, initial:String) throws  -> FileHandle? {
  if (FileManager.default.createFile(atPath: x, contents: nil, attributes: nil)) {
    print(">Pumper created \(x)")
  } else {
    print("\(x) not created."); throw PumpingErrors.badOutputURL
  }
  guard let  newurl = URL(string:x)  else {
    print("\(x) is a bad url"); throw PumpingErrors.badOutputURL
  }
  do {
    let  fh = try FileHandle(forWritingTo: newurl)
    fh.write(initial.data(using: .utf8)!)
    return fh
  } catch {
    print("Cant write to \(newurl), \(error)"); throw PumpingErrors.cantWrite
  }
}

struct T7: ParsableCommand   {
  
  static var configuration = CommandConfiguration(
    abstract: "Chat With AI To Generate Data for Q20K (IOS) App",
    discussion: "Step 1 - ask the AI to generate question blocks\nStep 2 - ask the AI to identify problems in generated data\nStep 3 - ask the AI to repair the data\nStep 4 - ask the AI to again identify problems in generated data",
    version: t7_version )
  
  @Argument(help: "pumper system template URL")
  var pumpsys: String
  
  @Argument( help:"pumper user template URL")
  var pumpusr: String
  
  @Option(help: "validation system template URL, default is no validation")
  var valsys: String = ""
  
  @Option( help:"validation user template URL, default is \"\"")
  var valusr: String = ""
  
  @Option(help: "repair system template URL, default is no repair")
  var repsys: String = ""
  
  @Option( help:"repair user template URL, default is \"\"")
  var repusr: String = ""
  
  @Option( help:"alternate pumper input URL, default is \"\"")
  var altpump: String = ""
  
  @Option( help:"pumpedoutput json stream file")
  var pumpedoutstreamfile: String = ""
  
  @Option( help:"reapired json stream file")
  var repairedoutstreamfile: String = ""
  
  @Option( help:"model")
  var model: String = "gpt-4"
  



  
  mutating func process_cli() throws {
    
    defer {
      if pumpedhandle != nil {
       // pumpedhandle.write()
        
      }
      if repairedhandle != nil {
        
      }
    }
    
    
    
     gmodel = model
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
      skipvalidation = true
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
      skiprepair = true
    } else {
      guard let repsys = URL(string:repsys) else {
        fatalError("Invalid repair system template URL")
      }
      repsysMessage = try String(data:Data(contentsOf:repsys),encoding: .utf8) ?? ""
    }
    
    // output files get opened for writing incrmentally
 
    if pumpedoutstreamfile != "" {
        pumpedhandle =  try? prep(pumpedoutstreamfile,initial: "[\n")
    }
    if repairedoutstreamfile != "" {
      repairedhandle = try?
      prep(repairedoutstreamfile,initial: "[\n")
    }
  }
  func runAICycle (_ userMessage:String,jobno:String) {
    var phases:[Bool] =  [altpump.isEmpty]
  
    phases += [!skipvalidation]
    phases += [!skiprepair]
    phases += [!skiprevalidation]
    Phases.perform(phases, jobno: jobno,msg:userMessage)
  }
  
  mutating func run() throws {
    do {
      try process_cli()
    }
    catch {
      print("Error -> \(error)")
      print("command line processing failed ")
      return
    }
    
    showTemplates()
    
    apiKey = try getAPIKey()
    
    let tmsgs = usrMessage.components(separatedBy: "*****")
    let umsgs = tmsgs.compactMap{$0.trimmingCharacters(in: .whitespacesAndNewlines)}
    umsgs.forEach { umsg in
      runAICycle(umsg, jobno: UUID().uuidString)
    }
    
  }
}
 
