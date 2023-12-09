//
//  phases.swift
//  t7
//
//  Created by bill donner on 12/9/23.
//

import Foundation

func pumpPhase() {
  print ("pumping")
}
func validationPhase() {
  print("validating")
}
func repairPhase() {
  print("repairing")
}
func revalidationPhase() {
  print("revalidating")
}

enum Phases:Int {
  case pumping
  case validating
  case repairing
  case revalidating
  
 static func perform(_ performPhases:[Bool]) {
   if performPhases[0] {pumpPhase()} else {print ("Skipping pumpPhase")}
   if performPhases[1] {validationPhase()} else {print ("Skipping validationPhase")}
   if performPhases[2] {repairPhase()} else {print ("Skipping repairPhase")}
   if performPhases[3] {revalidationPhase()} else {print ("Skipping revalidationPhase")}
  }
}



