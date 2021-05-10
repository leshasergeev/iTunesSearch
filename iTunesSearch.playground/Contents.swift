// create HTTP request to iTunes through iTunes API


import UIKit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

struct StoreItem: Codable {
    let name: String
    let artist: String
    var kind: String
    var description: String
    var artworkURL: URL
    
    enum CodingKeys: String, CodingKey {
        case name = "trackName"
        case artist = "artistName"
        case kind
        case description = "longDescription"
        case artworkURL = "artworkUrl100"
    }
    
    enum AdditionalKeys: String, CodingKey {
        case longDescription
    }
    
    init(from decoder: Decoder) throws {
        // создаем контейнер для декодера Coding Keys
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        // из контейнера достаём значеня и присваеваем значениям в структуре
        name        = try values.decode(String.self, forKey: CodingKeys.name)
        artist      = try values.decode(String.self, forKey: CodingKeys.artist)
        kind        = try values.decode(String.self, forKey: CodingKeys.kind)
        artworkURL  = try values.decode(URL.self, forKey: CodingKeys.artworkURL)
        
        // пытаемся получить данные из контейнера декодера по ключу из Coding Keys
        // если не получается, создаем второй контейнер из additional keys и достаем данные
        if let description = try? values.decode(String.self, forKey: .description) {
            self.description = description
        } else {
            let additionalValues = try decoder.container(keyedBy: AdditionalKeys.self)
            description = (try? additionalValues.decode(String.self, forKey: AdditionalKeys.longDescription)) ?? ""
        }
    }
}



struct SearchRespounce: Codable {
    let result: [StoreItem]
}


//_____________________________________________________________________________________________________________________
/// взято из Apple Books: Collections
extension Data {
    func prettyPrintedJSONString() {
        guard
            let jsonObject = try? JSONSerialization.jsonObject(with: self, options: []),
            let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
            let prettyJSONString = String(data: jsonData, encoding: .utf8) else {
                print("Failed to read JSON Object.")
                return
        }
        print(prettyJSONString)
    }
}
//______________________________________________________________________________________________________________________

let iTunesURLString = "https://itunes.apple.com/search"
let url = URL(string: iTunesURLString)
let queryItems = [
    "term": "Apple",
    "media": "ebook",
    "attribute": "authorTerm",
    "lang": "en_us",
    "limit": "10"
]


//var urlComponents = URLComponents(string: iTunesURLString)!
//urlComponents.queryItems = queryItems.map{URLQueryItem(name: $0.key, value: $0.value)}
//
//let dataTask = URLSession.shared.dataTask(with: urlComponents.url!) { (data, respounce, error) in
//    if let rData = data{
//        if let string = String(data: rData, encoding: .utf8){
//            print(string)
//        } else {
//            print("Could not decode data by \".utf8\".")
//        }
//    } else {
//        print("Data was not recived.")
//    }
//    PlaygroundPage.current.finishExecution()
//}
//
//dataTask.resume()


func fetchItems(mathcing query: [String: String], completion: @escaping (Result<[StoreItem], Error>) -> Void) {
    
    var urlComponents = URLComponents(string: "https://itunes.apple.com/search")!
    urlComponents.queryItems = query.map{ URLQueryItem(name: $0.key, value: $0.value) }
    
    let dataTask = URLSession.shared.dataTask(with: urlComponents.url!) { (data, urlRespounce, error) in
        // проверка на ошибки
        if let error = error {
            completion(.failure(error))
        } else if let data = data {
            // попытка прочитать данные из data, если есть, то двигаем их в SearchRespounce через JSONDecoder
            do {
                let jsonDecoder = JSONDecoder()
                let searchRespounce = try jsonDecoder.decode(SearchRespounce.self, from: data)
                completion(.success(searchRespounce.result))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    dataTask.resume()
}



fetchItems(mathcing: queryItems) { (result) in
    switch result {
    case .success(let storeItems):
        print("Data was succesfully recived: \(storeItems)")
        storeItems.forEach { (item) in
            print("""
                Name:\t\(item.name)
                Artist:\t\(item.artist)
                Kind:\t\(item.kind)
                Description:\t\(item.description)
                Artwork URL:\t\(item.artworkURL)
            """)
        }
    case .failure(let error):
        print("The error was occured when data was being recived: \(error)")
    }
    
    PlaygroundPage.current.finishExecution()
}
