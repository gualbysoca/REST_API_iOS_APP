//
//  ViewController.swift
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var ipLabel: UILabel!
    
    @IBOutlet weak var postResultLabel: UILabel!

//MARK: - Metodos del viewcontroller
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Llamadas a nuestros servicios Web REST
        updateIP() //Consumimos el servicio REST
        postDataToURL(msj: "Mensaje recibido!!!") //Respondemos al servicio con un mensaje de confirmación
    }

    
//MARK: - REST Calls

    // Esta funcion hace la llamada GET al postEndpoint para obtener su propia direccion IP y mostrarla en la pantalla.
    func updateIP() {
        
        // Seteamos la sesión para hacer el REST GET call.
        let postEndpoint: String = "https://httpbin.org/ip"
        let session = URLSession.shared
        let url = URL(string: postEndpoint)!
        
        // Hacemos el POST call y lo manejamos con el completion handler
        session.dataTask(with: url, completionHandler: { ( data: Data?, response: URLResponse?, error: Error?) -> Void in
            // Nos aseguramos de haber recibido una respuesta OK
            guard let realResponse = response as? HTTPURLResponse, realResponse.statusCode == 200 else {
                print("Ocurrio algún error al consumir el Web Service")
                return
            }
            
            // Leemos el JSON
            do {
                if let ipString = NSString(data:data!, encoding: String.Encoding.utf8.rawValue) {
                    // Inprimimos todo lo leido en la llamada GET
                    print(ipString)
                
                    // Parseamos el JSON para obtener sólo la IP
                    let jsonDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    let origin = jsonDictionary["origin"] as! String
                   
                    // Hacemos el update del label en el View
                    self.performSelector(onMainThread: #selector(ViewController.updateIPLabel(_:)), with: origin, waitUntilDone: false)
                }
            } catch {
                print("Ocurrio algun error al leer el JSON")
            }
        } ).resume()
    }
    
    
    func postDataToURL(msj: String) {
        
        // Seteamos la sesión para hacer la llamada al REST POST.
        // NOTA: debe ingresar a https://requestb.in/105wye51?inspect para ver el mensaje de respuesta que enviamos al Web Service desde esta funcion.
        let postEndpoint: String = "https://requestb.in/105wye51"
        let url = URL(string: postEndpoint)!
        let session = URLSession.shared
        let postParams : [String: AnyObject] = ["Respuesta": msj as AnyObject]
        
        // Creamos el request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: postParams, options: JSONSerialization.WritingOptions())
            print(postParams)
        } catch {
            print("Ocurrió algún error al tratar de enviar la respuesta al Web Service.")
        }
        
        // Hacemos el POST call y lo manejamos con el completion handler
        session.dataTask(with: request, completionHandler: { ( data: Data?, response: URLResponse?, error: Error?) -> Void in
            // Nos aseguramos de haber recibido una respuesta OK
            guard let realResponse = response as? HTTPURLResponse,
                realResponse.statusCode == 200 else {
                    print("Ocurrio algún error al consumir el Web Service")
                    return
            }
            
            // Leemos el JSON
            if let postString = NSString(data:data!, encoding: String.Encoding.utf8.rawValue) as String? {
                    // Imprimimos en consola la respuesta al Call
                    print("POST: " + postString)
                    self.performSelector(onMainThread: #selector(ViewController.updatePostLabel(_:)), with: postString, waitUntilDone: false)
            }

        }).resume()
    }
    
//MARK: - Metodo para actualizar la UI en tiempo real
    func updateIPLabel(_ text: String) {
        self.ipLabel.text = "Tu IP es: " + text
    }
    
    func updatePostLabel(_ text: String) {
        self.postResultLabel.text = "Respuesta recibida: " + text
    }
}

