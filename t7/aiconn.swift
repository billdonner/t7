//
//  aiconn.swift
//  t7
//
//  Created by bill donner on 12/10/23.
//

import Foundation

func callOpenAI(APIKey: String, 
                decoder:@escaping ((String,Date) throws -> Void),
                model:String,
                systemMessage: String,
                userMessage: String) async throws {
  let starttime = Date()
  let baseURL = "https://api.openai.com/v1/chat/completions"
  let headers = ["Authorization": "Bearer \(APIKey)","Content-Type":"application/json"]
  let parameters = [
    "model":model,
    "max_tokens": 4000,
   // "time_out":180,// 3 minutes
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
    throw T7Errors.badResponseFromAI
  }
      
  try decoder(content,starttime)
}


