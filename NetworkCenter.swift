import Foundation
import CommonCrypto

struct User: Codable {
    var userId: Int
    var userName: String
    var userNickName: String
    var userPassword: String
    var email: String
    var token: String?  // JWT token included in the response, optional
}

class NetworkManager {
    let baseURL = "https://1072-174-89-159-68.ngrok-free.app/api/v1/users"
    let secretKey = "your_secret_key"  // Replace with your actual secret key
    
    // Function to generate a JWT token based on email and password
    private func generateJWTToken(for email: String, password: String) -> String? {
        let header = ["alg": "HS256", "typ": "JWT"]
        let payload = ["email": email, "password": password]
        
        guard let headerData = try? JSONSerialization.data(withJSONObject: header, options: []),
              let payloadData = try? JSONSerialization.data(withJSONObject: payload, options: []) else {
            return nil
        }
        
        let headerBase64 = headerData.base64EncodedString()
        let payloadBase64 = payloadData.base64EncodedString()
        let toSign = "\(headerBase64).\(payloadBase64)"
        
        guard let signature = signData(toSign, withKey: secretKey) else {
            return nil
        }
        
        return "\(toSign).\(signature)"
    }
    
    // Function to sign data with a secret key
    private func signData(_ data: String, withKey key: String) -> String? {
        guard let keyData = key.data(using: .utf8),
              let dataToSign = data.data(using: .utf8) else {
            return nil
        }
        
        var hmac = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        dataToSign.withUnsafeBytes { dataBytes in
            keyData.withUnsafeBytes { keyBytes in
                CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), keyBytes.baseAddress, keyData.count, dataBytes.baseAddress, dataToSign.count, &hmac)
            }
        }
        
        let hmacData = Data(hmac)
        return hmacData.base64EncodedString()
    }
    
    // Function to login a user
    func loginUser(email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let url = URL(string: "\(baseURL)?email=\(email)&password=\(password)") else {
            completion(false, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Login Error: \(error.localizedDescription)")
                completion(false, error)
                return
            }

            guard let data = data else {
                print("Login Error: No data received")
                completion(false, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received from the server."]))
                return
            }
            
            do {
                var users = try JSONDecoder().decode([User].self, from: data)
                
                if var matchedUser = users.first(where: { $0.email == email && $0.userPassword == password }) {
                    print("Login successful for user: \(matchedUser.userName)")
                    
                    // Generate JWT token for the user based on email and password
                    if let token = self.generateJWTToken(for: matchedUser.email, password: matchedUser.userPassword) {
                        matchedUser.token = token
                        print("Generated JWT Token: \(token)")
                        // Store token and email in UserDefaults
                        UserDefaults.standard.set(token, forKey: "userToken")
                        UserDefaults.standard.set(matchedUser.email, forKey: "loggedInUserEmail")
                        print("Logged in with email: \(matchedUser.email), JWT Token: \(token)")
                        completion(true, nil)
                    } else {
                        print("Login Error: Could not generate JWT token")
                        completion(false, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not generate JWT token"]))
                    }
                } else {
                    print("Login Error: Invalid credentials")
                    completion(false, NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid credentials"]))
                }
            } catch {
                print("Login Error: \(error.localizedDescription)")
                completion(false, error)
            }
        }.resume()
    }
    
    // Function to create a new account
    func createAccount(userName: String, userNickName: String, email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let url = URL(string: baseURL) else {
            completion(false, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "userName": userName,
            "userNickName": userNickName,
            "email": email,
            "userPassword": password  // Ensure this matches the expected key in your backend
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Create Account Error: \(error.localizedDescription)")
                completion(false, error)
                return
            }

            guard let data = data else {
                print("Create Account Error: No data received")
                completion(false, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received from the server."]))
                return
            }

            // Print the raw data as a string to debug the format
            if let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw Server Response: \(rawResponse)")
            }

            do {
                let createdUser = try JSONDecoder().decode(User.self, from: data)
                if createdUser.email == email {
                    print("Account created successfully for user: \(createdUser.userName)")
                    completion(true, nil)
                } else {
                    print("Create Account Error: Account creation failed")
                    completion(false, NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Account creation failed"]))
                }
            } catch {
                print("Create Account Error: \(error.localizedDescription)")
                completion(false, error)
            }
        }.resume()
    }

    // Function to get user profile
    func getUserProfile(completion: @escaping (String?, String?) -> Void) {
        // Retrieve email and token from UserDefaults
        guard let email = UserDefaults.standard.string(forKey: "loggedInUserEmail"),
              let token = UserDefaults.standard.string(forKey: "userToken") else {
            print("Profile Error: loggedInUserEmail or userToken is nil when trying to fetch profile")
            completion(nil, nil)
            return
        }

        print("Fetching profile for email: \(email)")

        guard let url = URL(string: "\(baseURL)?email=\(email)") else {
            print("Profile Error: Invalid URL")
            completion(nil, nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")  // Add the token to the header

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Profile Error: \(error.localizedDescription)")
                completion(nil, nil)
                return
            }

            guard let data = data else {
                print("Profile Error: No data received")
                completion(nil, nil)
                return
            }

            do {
                let users = try JSONDecoder().decode([User].self, from: data)
                if let matchedUser = users.first(where: { $0.email == email }) {
                    print("Profile fetched for user: \(matchedUser.userName), Nickname: \(matchedUser.userNickName)")
                    completion(matchedUser.userName, matchedUser.userNickName)
                } else {
                    print("Profile Error: User not found")
                    completion(nil, nil)
                }
            } catch {
                print("Profile Error: \(error.localizedDescription)")
                completion(nil, nil)
            }
        }.resume()
    }
}
