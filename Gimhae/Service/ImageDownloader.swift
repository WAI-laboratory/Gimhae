import UIKit

actor ImageDownloader {
    static let shared = ImageDownloader()
    private init() { }

    private var cache: [URL: UIImage] = [:]

    func image(from url: URL) async throws -> UIImage? {

        if let cached = cache[url] {
            return cached
        }

        let image = try await downloadImage(from: url)

        cache[url] = cache[url, default: image]


        return cache[url]
    }

    private func downloadImage(from url: URL) async throws -> UIImage {
        let imageFetchProvider = ImageFetchProvider.shared
        return try await imageFetchProvider.fetchImage(with: url)
    }
}
import UIKit

 extension UIImage {
     var thumbnail: UIImage? {
         get async {
             let size = CGSize(width: 100, height: 140)
             return await self.byPreparingThumbnail(ofSize: size)
         }
     }
 }

class ImageFetchProvider {
    static let shared = ImageFetchProvider()
    private init() {}
    
    private let session = URLSession.shared
    
    func fetchImage(with url: URL) async throws -> UIImage {
        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "\(Self.self)", code: 0)
        }
        guard let image = UIImage(data: data) else {
            throw NSError(domain: "\(Self.self)", code: 1)
        }
        return image
    }
}
