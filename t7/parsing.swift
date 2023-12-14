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
    print("Cant write to \(newurl), \(error)")
    throw PumpingErrors.cantWrite
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
  
  @Option(help: "re-validation system template URL, default is no revalidation")
  var revalsys: String = ""
  
  @Option( help:"re-validation user template URL, default is \"\"")
  var revalusr: String = ""
  
  @Option( help:"alternate pumper input URL, default is \"\"")
  var altpump: String = ""
  
  @Option( help:"pumpedoutput json stream file")
  var pumpedfile: String = ""
  
  @Option( help:"repaired json stream file")
  var repairedfile: String = ""
  
  @Option( help:"validated json stream file")
  var validatedfile: String = ""
  
  @Option( help:"revalidated json stream file")
  var revalidatedfile: String = ""
  
  @Option( help:"model")
  var model: String = "gpt-4"
  
  @Flag (help:"verbose")
  var verbose : Bool = false 



  
  mutating func process_cli() throws {
    

gverbose = verbose 
     gmodel = model
    // get required template data, no defaults
    guard let sys = URL(string:pumpsys) else {
      throw T7Errors.badInputURL(url: pumpsys)
    }
    guard let usr = URL(string:pumpusr) else {
      throw T7Errors.badInputURL(url: pumpusr)
    }
    let sysMessage = try String(data:Data(contentsOf:sys),encoding: .utf8)
    guard let sysMessage = sysMessage else {throw T7Errors.cantDecode(url: pumpsys)}
    systemMessage = sysMessage
    
    let userMessage = try String(data:Data(contentsOf:usr),encoding: .utf8)
    guard let userMessage = userMessage else {throw T7Errors.cantDecode(url: pumpusr)}
    usrMessage = userMessage
    
    
    // validation
    
    if valusr == "" {
      valusrMessage = ""
    } else {
      guard let valusr = URL(string:valusr) else {
        throw T7Errors.badInputURL(url: valusr)
      }
      valusrMessage = try String(data:Data(contentsOf:valusr),encoding: .utf8) ?? ""
    }
    
    if valsys == "" {
      valsysMessage = ""
    } else {
      guard let valsys = URL(string:valsys) else {
        throw T7Errors.badInputURL(url: valsys)
      }
      valsysMessage = try String(data:Data(contentsOf:valsys),encoding: .utf8) ?? ""
      
      skipvalidation = false
    }
    
    // repair
    if repusr == "" {
      repusrMessage = ""
    } else {
      guard let repusr = URL(string:repusr) else {
        throw T7Errors.badInputURL(url: repusr)
      }
      repusrMessage = try String(data:Data(contentsOf:repusr),encoding: .utf8) ?? ""
    }
    if repsys == "" {
      repsysMessage = ""
      skiprepair = true
    } else {
      guard let repsys = URL(string:repsys) else {
          throw T7Errors.badInputURL(url: repsys)
      }
      repsysMessage = try String(data:Data(contentsOf:repsys),encoding: .utf8) ?? ""
    }
    
    // validation
    
    if revalusr == "" {
      revalusrMessage = ""
    } else {
      guard let revalusr = URL(string:revalusr) else {
        throw T7Errors.badInputURL(url: revalusr)
      }
      revalusrMessage = try String(data:Data(contentsOf:revalusr),encoding: .utf8) ?? ""
    }
    
    if revalsys == "" {
      revalsysMessage = "" 
    } else {
      guard let revalsys = URL(string:revalsys) else {
        throw T7Errors.badInputURL(url: revalsys)
      }
      revalsysMessage = try String(data:Data(contentsOf:revalsys),encoding: .utf8) ?? ""
      skiprevalidation = false
    }
    
    // output files get opened for writing incrmentally
 
    if pumpedfile != "" {
        pumpHandle =  try? prep(pumpedfile,initial:"")// "[\n")
    }
    if validatedfile != "" {
    validatedHandle = try?  prep(validatedfile,initial:"")// "[\n")
    }
    if repairedfile != "" {
      repairHandle = try?  prep(repairedfile,initial:"")// "[\n")
    }
    if revalidatedfile != "" {
     revalidatedHandle = try?  prep(revalidatedfile,initial:"")// "[\n")
    }
  }

  
  mutating func run()   throws {
    do {
      try process_cli()
    }
    catch {
      print("Error -> \(error)")
      throw T7Errors.commandLineError
    }
    showTemplates()
    apiKey = try getAPIKey()
    
  }
}
 
