import Foundation

extension HTTPURLResponse {
    var nextLink: String? {
        guard let linkHeaderValue = value(forHTTPHeaderField: "Link") else {
            return nil
        }

        let linkHeaderComponents = linkHeaderValue.components(separatedBy: ",")
        for linkComponent in linkHeaderComponents {
            let components = linkComponent.components(separatedBy: ";")
            guard components.count > 1 else { break }

            if components[1].trimmingCharacters(in: .whitespaces) == "rel=\"next\"" {
                return components[0].trimmingCharacters(in: CharacterSet(charactersIn: "<>"))
            }
        }

        return nil
    }
}
