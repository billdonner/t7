//
//  aiconn.swift
//  t7
//
//  Created by bill donner on 12/10/23.
//

import Foundation



func callOpenAI(APIKey: String,semaphore:DispatchSemaphore, decoder:@escaping ((String)throws -> Void), model:String, systemMessage: String, userMessage: String) {
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
      print(">assistant:\n")
      try decoder(content)
    }
    catch {
      print("response serialization thrown with error \(error)")
    }
    semaphore.signal()
  }.resume()
}
