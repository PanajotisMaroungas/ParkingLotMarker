//
//  Communication.swift
//  ParkingLotMarker
//
//  Created by Panajotis Maroungas on 17/08/15.
//  Copyright (c) 2015 Panajotis Maroungas. All rights reserved.
//

import UIKit

private var _singletonInstanceCommunication = Communication()


class Communication: NSObject {
    
    class var sharedInstance: Communication{
        return _singletonInstanceCommunication
    }

    func sendToServer(parameters: Dictionary<String, AnyObject>,completionHandler:(JSON!, NSError!) -> Void) -> NSURLSessionDataTask!{
        
        //declare parameter as a dictionary which contains string as key and value combination.
        var error:NSError?
        let jsonData: NSData?
        do {
            jsonData = try NSJSONSerialization.dataWithJSONObject(parameters, options: [])
        } catch let error1 as NSError {
            error = error1
            jsonData = nil
        }
        var jsonString: NSString!
        if error != nil {
            print("Invalid json ")
            return nil
        } else {
            jsonString = NSString(data: jsonData!, encoding: NSUTF8StringEncoding)
        }
        
        print("jsonString : \(jsonString)")
        
        
        //create the url with NSURL
        let url = NSURL(string: URL) //change the url
        
        //create the session object
        let session = NSURLSession.sharedSession()
        
        //now create the NSMutableRequest object using the url object
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST" //set http method as POST
        
        var err: NSError?
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(parameters, options: [])
        } catch let error as NSError {
            err = error
            request.HTTPBody = nil
            completionHandler(nil,err)
        }
        // pass dictionary to nsdata object and set it as request body
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        //create dataTask using the session object to send data to the server
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            print("Response: \(response)")
            let strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("Body: \(strData)")
            
            var json: NSDictionary = NSDictionary()
            do {
                json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as! NSDictionary
            }catch let error as NSError{
                completionHandler(nil,error)
            }
            //let json = NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as? NSDictionary
            
            // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
            if(err != nil) {
                print(err!.localizedDescription)
                let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("A: Error could not parse JSON: '\(jsonStr)'")
                completionHandler(nil, err)
            }
            else {
                // The JSONObjectWithData constructor didn't return an error. But, we should still
                // check and make sure that json has a value using optional binding.
                
                
                if json.count > 0 {
                    // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                    //var success = parseJSON["success"] as? Int
                    let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)

                    let jsonReturn = JSON(data: jsonStr!.dataUsingEncoding(NSUTF8StringEncoding)!)

                    completionHandler(jsonReturn, nil)
                }
                else {
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print("B: Error could not parse JSON: \(jsonStr)")

                }
            }
        })
        
        task.resume()
        return task
    }
}
