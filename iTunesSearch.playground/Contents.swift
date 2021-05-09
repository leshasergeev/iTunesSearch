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
        name        = try values.decode(String.self, forKey: .name)
        artist      = try values.decode(String.self, forKey: .artist)
        kind        = try values.decode(String.self, forKey: .kind)
        artworkURL  = try values.decode(URL.self, forKey: .artworkURL)
        
        // пытаемся получить данные из контейнера декодера по ключу из Coding Keys
        // если не получается, создаем второй контейнер из additional keys и достаем данные
        if let description = try? values.decode(String.self, forKey: .description) {
            self.description = description
        } else {
            let additionalValues = try decoder.container(keyedBy: AdditionalKeys.self)
            description = (try? additionalValues.decode(String.self, forKey: .longDescription)) ?? ""
        }
    }
}



struct SearchRespounce: Codable {
    let result: [StoreItem]
}



let iTunesURLString = "https://itunes.apple.com/search"
let url = URL(string: iTunesURLString)
let queryItems = [
    "term": "Apple",
    "media": "ebook",
    "attribute": "authorTerm",
    "lang": "en_us",
    "limit": "10"
]


var urlComponents = URLComponents(string: iTunesURLString)!
urlComponents.queryItems = queryItems.map{URLQueryItem(name: $0.key, value: $0.value)}

let dataTask = URLSession.shared.dataTask(with: urlComponents.url!) { (data, respounce, error) in
    if let rData = data{
        if let string = String(data: rData, encoding: .utf8){
            print(string)
        } else {
            print("Could not decode data by \".utf8\".")
        }
    } else {
        print("Data was not recived.")
    }
    PlaygroundPage.current.finishExecution()
}

dataTask.resume()










