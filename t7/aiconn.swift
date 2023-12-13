//
//  aiconn.swift
//  t7
//
//  Created by bill donner on 12/10/23.
//

import Foundation

func callOpenAI(APIKey: String, 
                decoder:@escaping ((String) throws -> Void),
                model:String,
                systemMessage: String,
                userMessage: String) async throws {
  let baseURL = "https://api.openai.com/v1/chat/completions"
  let headers = ["Authorization": "Bearer \(APIKey)","Content-Type":"application/json"]
  let parameters = [
    "model":model,
    "max_tokens": 4000,
    "temperature": 1,
    "messages": [
      ["role": "system", "content": systemMessage],
      ["role": "user", "content": userMessage]
    ]
  ] as [String : Any]
  
  let jsonData = try JSONSerialization.data(withJSONObject: parameters)
  
  var request = URLRequest(url: URL(string: baseURL)!)
  request.httpMethod = "POST"
  request.allHTTPHeaderFields = headers
  request.httpBody = jsonData
  
  let (data, _) = try await URLSession.shared.data(for:request)
  
  let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
  guard let choices = json?["choices"] as? [[String: Any]], let firstChoice = choices.first,
        let message = firstChoice["message"] as? [String: Any], let content = message["content"] as? String
  else {
    fatalError("Unexpected response format")
  }
      
  try decoder(content)
}


func xcallOpenAI(APIKey: String,semaphore:DispatchSemaphore, decoder:@escaping ((String)throws -> Void), model:String, systemMessage: String, userMessage: String) {
  // Construct the API request payload

  let baseURL = "https://api.openai.com/v1/chat/completions"
  let headers = ["Authorization": "Bearer \(APIKey)","Content-Type":"application/json"]
  let parameters = [
    "model":model,
    "max_tokens": 4000,
    //        "top_p": 1,
    //        "frequency_penalty": 0,
    //        "presence_penalty": 0,
    "temperature": 1,
    "messages": [
      ["role": "system", "content": systemMessage],
      ["role": "user", "content": userMessage]
    ]
  ] as [String : Any]
  var jsonData:Data
  do {
    // Convert the parameters to JSON data
    jsonData = try JSONSerialization.data(withJSONObject: parameters)
  } catch {
    fatalError("Could not serialize")
  }
  // print("sending ... ", String(data:jsonData,encoding: .utf8) ?? "")
  
  // Make the API request
  var request = URLRequest(url: URL(string: baseURL)!)
  request.httpMethod = "POST"
  request.allHTTPHeaderFields = headers
  request.httpBody = jsonData
  
  
  URLSession.shared.dataTask(with: request) { (data, response, error) in
   
    
    if let error = error {
      print("API request error: \(error)")
      return
    }
    
    guard let data = data else {
      print("API response data is empty")
      return
    }
    
    // Parse the API response JSON
    do {
      let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
      guard let json = json  else { fatalError("jsonjson")}
      guard let choices = json["choices"] as? [Any]  else { print(json); fatalError("choiceschoices")}
      guard let firstChoice = choices.first as? [String: Any] else {fatalError("firstfirst")}
      guard let reply = firstChoice["message"] as? [String: Any] else {fatalError("replyreply")}
      guard let content = reply["content"] as? String else {fatalError("contentcontent")}
      if gverbose {print(">assistant:\n")}
      try decoder(content)
    }
    catch {
      print("response serialization thrown with error \(error)")
    }
    semaphore.signal()
  }.resume()
}


func useAPIRepeatedly() async {
    for i in 1...10 {
        do {
            try await callOpenAI(APIKey: "ApiKey1", decoder: { print($0) }, model: "Model1", systemMessage: "SystemMessage1", userMessage: "UserMessage1")
            try await callOpenAI(APIKey: "ApiKey2", decoder: { print($0) }, model: "Model2", systemMessage: "SystemMessage2", userMessage: "UserMessage2")
            try await callOpenAI(APIKey: "ApiKey3", decoder: { print($0) }, model: "Model3", systemMessage: "SystemMessage3", userMessage: "UserMessage3")
        } catch {
            print("API call \(i) failed with error: \(error)")
            return
        }
    }
}
