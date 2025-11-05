import Foundation

class StationExporter {
    static func exportStationsToCSV() -> String {
        let stations = StationsData.shared.stations
        var csvContent = "Station Name,Lines,Location,Trivia\n"

        for station in stations {
            let linesString = station.lines.map { $0.name }.joined(separator: "; ")
            let escapedTrivia = station.trivia.replacingOccurrences(of: "\"", with: "\"\"")

            csvContent += "\"\(station.name)\",\"\(linesString)\",\"\(station.location)\",\"\(escapedTrivia)\"\n"
        }

        return csvContent
    }

    static func exportStationsToJSON() -> String? {
        let stations = StationsData.shared.stations

        let stationData = stations.map { station in
            return [
                "name": station.name,
                "lines": station.lines.map { ["name": $0.name, "color": $0.colorCode] },
                "location": station.location,
                "trivia": station.trivia
            ]
        }

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: stationData, options: .prettyPrinted)
            return String(data: jsonData, encoding: .utf8)
        } catch {
            print("Error creating JSON: \(error)")
            return nil
        }
    }

    static func saveStationsToFile() {
        let csvContent = exportStationsToCSV()
        let jsonContent = exportStationsToJSON() ?? ""

        // Get desktop path
        let desktopPath = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!

        // Save CSV
        let csvURL = desktopPath.appendingPathComponent("TubeGuesser_Stations.csv")
        do {
            try csvContent.write(to: csvURL, atomically: true, encoding: .utf8)
            print("✅ CSV exported to: \(csvURL.path)")
        } catch {
            print("❌ Error saving CSV: \(error)")
        }

        // Save JSON
        let jsonURL = desktopPath.appendingPathComponent("TubeGuesser_Stations.json")
        do {
            try jsonContent.write(to: jsonURL, atomically: true, encoding: .utf8)
            print("✅ JSON exported to: \(jsonURL.path)")
        } catch {
            print("❌ Error saving JSON: \(error)")
        }
    }

    static func printAllStations() {
        let stations = StationsData.shared.stations

        print("=== TUBEGUESSR STATIONS DATABASE ===")
        print("Total stations: \(stations.count)")
        print("Multi-line stations: \(StationsData.shared.multiLineStations.count)")
        print("\n")

        for (index, station) in stations.enumerated() {
            print("[\(index + 1)] \(station.name)")
            print("Lines: \(station.lines.map { $0.name }.joined(separator: ", "))")
            print("Location: \(station.location)")
            print("Trivia: \(station.trivia)")
            print("---")
        }
    }
}