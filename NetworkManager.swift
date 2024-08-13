import Foundation

struct LoginResponse: Codable {
    var userId: Int
    var userName: String
    var userNickName: String
    var userPassword: String
    var email: String
}

class NetworkManager {
    func fetchUserData(email: String, password: String, completion: @escaping (LoginResponse?) -> Void) {
        // Construct the URL with query parameters
        let urlString = "https://a91d-174-89-159-68.ngrok-free.app/api/v1/users/?email=\(email)&userPassword=\(password)"
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)") // Log status code
                print("Response Headers: \(httpResponse.allHeaderFields)") // Log headers
            }

            guard let data = data else {
                if let error = error {
                    print("HTTP Request Failed: \(error)")
                } else {
                    print("No data received from the server.")
                }
                completion(nil)
                return
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("Raw response: \(responseString)")  // Log the raw response body
            }
            
            do {
                let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                completion(loginResponse)
            } catch {
                print("Failed to decode JSON: \(error)")
                completion(nil)
            }
        }.resume()
    }
}
