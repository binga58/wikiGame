//
//  NetworkClass.swift
//  Common
//
//  Created by Abhishek Sharma on 20/09/17.
//

enum ExpectedResponseType:Int {
    case json, data, string, none, count
}

//MARK:- base urls and keys
let kBaseUrl = ""


typealias CompletionHandler = (_ status:Bool, _ responseObj:Any?,_ error: Error?, _ statusCode:Int?) -> Void
typealias ProgressHandler = (_ fractionCompleted:Double)-> Void
typealias JSONDictionary = [String:AnyObject]

import Alamofire

//MARK:- Private Methods
class NetworkClass:NSObject  {
    
    fileprivate static func processResponse(request:DataRequest, responseType:ExpectedResponseType, completion:CompletionHandler?) {
        
        switch responseType {
        case .json:
            parseJSON(request: request, completion: completion)
        case .data:
            parseDATA(request: request, completion: completion)
        case .string:
            parseSTRING(request: request, completion: completion)
        case .none:
            parseNONE(request: request, completion: completion)
            
        default:
            break
        }
    }
    
    fileprivate static func parseJSON(request:DataRequest, completion:CompletionHandler?){
        
        request.responseJSON{ response in
            processCompletionWithStatus(response: response, completion: completion)
        }
    }
    
    fileprivate static func parseDATA(request:DataRequest, completion:CompletionHandler?){
        request.responseData{ response in
            processCompletionWithStatus(response: response, completion: completion)
        }
    }
    
    fileprivate static func parseSTRING(request:DataRequest, completion:CompletionHandler?){
        request.responseString{ response in
            processCompletionWithStatus(response: response, completion: completion)
        }
    }
    
    fileprivate static func parseNONE(request:DataRequest, completion:CompletionHandler?){
        request.response{ response in
            processCompletionWithStatus(response: response, completion: completion)
        }
    }
    
    fileprivate static func processEncodingResult(encodingResult:SessionManager.MultipartFormDataEncodingResult, responseType:ExpectedResponseType, progress:ProgressHandler?, completion:CompletionHandler?) {
        
        switch encodingResult {
        case .success(let upload, _, _):
            upload.uploadProgress(closure: { (Progress) in
                progress?(Progress.fractionCompleted)
            })
            processResponse(request: upload, responseType: responseType, completion: completion)
        case .failure:
            processCompletionWithStatus(response: nil, completion: completion)
        }
    }
    
    fileprivate static func processCompletionWithStatus(response:Any?, completion:CompletionHandler?) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        if let completion = completion{
            
            var responseObj:Any?
            var error:Error?
            var statusCode:Int?
            var status = false
            if let temp = response as? Alamofire.DataResponse<Any> {
                responseObj = temp.result.value
                error = temp.result.error
                statusCode = temp.response?.statusCode
            }else if let temp = response as? Alamofire.DataResponse<Data> {
                responseObj = temp.result.value
                error = temp.result.error
                statusCode = temp.response?.statusCode
            }else if let temp = response as? Alamofire.DataResponse<String> {
                responseObj = temp.result.value
                error = temp.result.error
                statusCode = temp.response?.statusCode
            }else if let temp = response as? DefaultDataResponse {
                responseObj = temp.data
                error = temp.error
                statusCode = temp.response?.statusCode
            }
            
            if let statusCode = statusCode {
                if 200 ... 299 ~= statusCode {
                    status = true
                }
            }
            
            completion(status, responseObj, error, statusCode)
            
        }
    }
    
    //MARK:- logout check
    static func isUserToBeLoggedOut(responseObj : Any?) -> Bool{
        if let dicArray = (responseObj as? [String : Any])?["errors"] as? [[String : Any]]{
           if let message = dicArray.first?["message"] as? String {
                if message == "Invalid Access Token " {
                    return true
                }
            }
        }
        return false
    }
    
    
}

//MARK:- Request Methods
extension NetworkClass{
    
    @discardableResult
    static func sendRequest(url:String, incluedBaseURl : Bool = true, requestType:Alamofire.HTTPMethod, responseType:ExpectedResponseType = .json , parameters: Any?, headers: [String: String]? = nil, completion:CompletionHandler?) -> DataRequest?{
        
        if self.isConnected() {
            
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            }
            var urlString = url
            if incluedBaseURl  {
                urlString = "\(kBaseUrl)\(urlString)"
            }
            
            if let request = getRequest(method: requestType, responseType: responseType, URLString: urlString, headers: headers, parameters: parameters){
                let afRequest = Alamofire.request(request)
                processResponse(request: afRequest, responseType: responseType, completion: completion)
                return afRequest
            }else{
                processCompletionWithStatus(response: nil, completion: completion)
                return nil
            }
            
        }else{
            completion?(false,nil,nil,nil)
            return nil
        }
    }
    
    static func getRequest(
        method: Alamofire.HTTPMethod,
        responseType:ExpectedResponseType,
        URLString: URLConvertible,
        headers: [String: String]?,
        parameters:Any?)
        -> URLRequest?{
            
            do{
                var mutableURLRequest = try URLRequest(url: URLString, method: method, headers: getUpdatedHeader(header: headers, responseType: responseType, requestType: method))
                if let parameters = parameters {
                    do{
                        if JSONSerialization.isValidJSONObject(parameters) {
                            mutableURLRequest.httpBody =  try JSONSerialization.data(withJSONObject: parameters, options: [])
                        }else{ debugPrint("Problem in Parameters") }
                    }catch{
                        debugPrint("Problem in Parameters: \(error)")
                    }
                }
                mutableURLRequest.timeoutInterval = 360
                return try mutableURLRequest.asURLRequest()
            }catch{ debugPrint(error) }
            
            return nil
    }
}

//MARK:- Image Uploading Methods
extension NetworkClass{
    static func sendImageRequest(url:String, incluedBaseURl : Bool = true, requestType:Alamofire.HTTPMethod, responseType:ExpectedResponseType = .json, parameters: Any? = nil, headers: [String: String]? = [:], imageData:Data?, progress:ProgressHandler?, completion:CompletionHandler?){
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        var urlString = url
        if incluedBaseURl  {
            urlString = "\(kBaseUrl)\(urlString)"
        }
        
        if let request = getRequest(method: requestType, responseType: responseType, URLString: urlString, headers:  headers, parameters: parameters){
         
//            let afRequest = Alamofire.request(request)
//            processResponse(request: afRequest, responseType: responseType, completion: completion)
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                if let imageData = imageData{
                    multipartFormData.append(imageData,
                                             withName: "image",
                                             fileName: "image",
                                             mimeType: "image/jpeg")
                }
                    if let parameters = parameters as? [String : String]
                    {
                        for (key, value) in parameters {
                        multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                        }
                    }
            }, with: request, encodingCompletion: { (processEncodingResult) in
                self.processEncodingResult(encodingResult: processEncodingResult, responseType: responseType, progress: progress, completion: completion)
            })
        }else{
            processCompletionWithStatus(response: nil, completion: completion)
        }
    }
    
    //For uploading report images
    static func uploadImageRequest(url:String, incluedBaseURl : Bool = true, requestType:Alamofire.HTTPMethod, responseType:ExpectedResponseType = .json, parameters: Any? = nil, headers: [String: String]? = [:], imageData:Any?, progress:ProgressHandler?, completion:CompletionHandler?){
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        
        var urlString = url
        if incluedBaseURl  {
            urlString = "\(kBaseUrl)\(urlString)"
        }
        
        if let request = getRequest(method: requestType, responseType: responseType, URLString: urlString, headers:  headers, parameters: parameters){
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                if let imageDictionary = imageData as? [String : Any]{
                    let imageKeyArray = imageDictionary.keys
                    for attributeID in imageKeyArray {
                        if let imageArray = imageDictionary[attributeID] as? [UIImage] {
                            for image in imageArray {
                                if let imageDataObj = UIImageJPEGRepresentation(image, 1.0){
                                let keyString = "\(arc4random())\(arc4random())"
                                multipartFormData.append(imageDataObj, withName: keyString, fileName: attributeID, mimeType: "image/jpeg")
                                }
                            }
                        }
                    }
                }
                
                //for parameters
                if let parameters = parameters as? [String : Any]
                {
                    for (key, value) in parameters {
                        
                        if let obj = value as? String{
                            multipartFormData.append(obj.data(using: String.Encoding.utf8)!, withName: key)
                        }
                        if let obj = value as? [String]{
                            for stringObj in obj{
                                multipartFormData.append(stringObj.data(using: String.Encoding.utf8)!, withName: "\(key)[]")
                            }
                        }
                        
                    }
                }
            }, with: request, encodingCompletion: { (processEncodingResult) in
                self.processEncodingResult(encodingResult: processEncodingResult, responseType: responseType, progress: progress, completion: completion)
            })
        }else{
            processCompletionWithStatus(response: nil, completion: completion)
        }
    }
}

//MARK:- Video Uploading Methods
extension NetworkClass{
    static func sendVideoRequest(url:String, requestType:Alamofire.HTTPMethod, responseType:ExpectedResponseType = .json, parameters: Any? = nil, headers: [String: String]? = nil, videoUrl:URL, progress:ProgressHandler?, completion:CompletionHandler?){
        
        do{
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            let videoData = try Data(contentsOf: videoUrl)
            if let request = getRequest(method: requestType, responseType: responseType, URLString: url, headers: headers, parameters: parameters){
                
                Alamofire.upload(multipartFormData: { (multipartFormData) in
                    multipartFormData.append(videoData,
                                             withName: "defaultVideo",
                                             fileName: "defaultVideo.mov",
                                             mimeType: "video/quicktime")
                }, with: request, encodingCompletion: { (processEncodingResult) in
                    self.processEncodingResult(encodingResult: processEncodingResult, responseType: responseType, progress: progress, completion: completion)
                })
            }else{
                processCompletionWithStatus(response: nil, completion: completion)
            }
        }catch{
            print(error)
            processCompletionWithStatus(response: nil, completion: completion)
        }
        
    }
}

//MARK:- Reachablity Methods
extension NetworkClass{
    static func isConnected()->Bool{
        var val = false
        if let reachability = Reachability(){
            switch reachability.connection {
            case .none:
                val = false
            default:
                val = true
            }
        }
        return val
    }
}

//MARK:- Additional Methods
extension NetworkClass{
    static func getUpdatedHeader(header: [String: String]?, responseType:ExpectedResponseType, requestType:Alamofire.HTTPMethod) -> [String: String] {
        
        var updatedHeader:[String:String] = [:]
        
        updatedHeader["Content-Type"] = "application/json"
        updatedHeader["User-Agent"] = Constants.emailId
        
        
        //header token
        if let arr = header?.keys {
            for key in arr {
                updatedHeader[key] = header![key]
            }
        }
        return updatedHeader
    }
}

//MARK:- Parameters to String
extension NetworkClass{
    
    static func stringFromQueryParameters(_ queryParameters : Dictionary<String, String>) -> String {
        var parts: [String] = []
        
        for (name, value) in queryParameters {
            let escapedName = name.urlEncoded()
            let escapedValue = value.urlEncoded()
            let part = "\(escapedName)=\(escapedValue)"
            
            parts.append(part as String)
        }
        
        return parts.joined(separator: "&")
    }
    
    
}


