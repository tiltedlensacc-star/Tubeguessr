import Foundation

class StationsData: ObservableObject {
    static let shared = StationsData()

    let tubeLines = [
        TubeLine(name: "Bakerloo", colorCode: "#996633"),
        TubeLine(name: "Central", colorCode: "#DC241F"),
        TubeLine(name: "Circle", colorCode: "#FFD320"),
        TubeLine(name: "District", colorCode: "#007D32"),
        TubeLine(name: "Hammersmith & City", colorCode: "#D799AF"),
        TubeLine(name: "Jubilee", colorCode: "#6A7278"),
        TubeLine(name: "Metropolitan", colorCode: "#751056"),
        TubeLine(name: "Northern", colorCode: "#000000"),
        TubeLine(name: "Piccadilly", colorCode: "#2E7DF6"),
        TubeLine(name: "Victoria", colorCode: "#00A0E2"),
        TubeLine(name: "Elizabeth", colorCode: "#6950A1"),
        TubeLine(name: "DLR", colorCode: "#00AFAD"),
        TubeLine(name: "Overground", colorCode: "#E86A10"),
        TubeLine(name: "Waterloo & City", colorCode: "#76D0BD"),
        TubeLine(name: "Tram", colorCode: "#84B817"),
        TubeLine(name: "National Rail", colorCode: "#000080")
    ]

    lazy var stations: [Station] = {
        let linesByName = Dictionary(uniqueKeysWithValues: tubeLines.map { ($0.name, $0) })

        let bakerloo = linesByName["Bakerloo"]!
        let central = linesByName["Central"]!
        let circle = linesByName["Circle"]!
        let district = linesByName["District"]!
        let hammersmithCity = linesByName["Hammersmith & City"]!
        let jubilee = linesByName["Jubilee"]!
        let metropolitan = linesByName["Metropolitan"]!
        let northern = linesByName["Northern"]!
        let piccadilly = linesByName["Piccadilly"]!
        let victoria = linesByName["Victoria"]!
        let elizabeth = linesByName["Elizabeth"]!
        let dlr = linesByName["DLR"]!
        let overground = linesByName["Overground"]!
        let waterlooCity = linesByName["Waterloo & City"]!
        let tram = linesByName["Tram"]!
        let nationalRail = linesByName["National Rail"]!

        return [
            Station(name: "King's Cross St. Pancras", lines: [circle, hammersmithCity, metropolitan, northern, piccadilly, victoria, nationalRail], trivia: "here you can find platforms for both the Eurostar and the Hogwarts Express.", location: "North London"),

            Station(name: "Liverpool Street", lines: [circle, hammersmithCity, central, metropolitan], trivia: "situated near a famously historic market, containing a herd of metal elephants.", location: "Central London"),

            Station(name: "Oxford Circus", lines: [bakerloo, central, victoria], trivia: "located at the intersection of one of the busiest shopping areas in Europe.", location: "Central London"),

            Station(name: "Bond Street", lines: [central, jubilee], trivia: "one of the world's most famous luxury shopping destinations, home to brands like Chanel, Louis Vuitton, Cartier, and Sotheby's auction house.", location: "Central London"),

            Station(name: "Green Park", lines: [jubilee, piccadilly, victoria], trivia: "near a park that is unusual in that it has no permanent statues or buildings, just memorials.", location: "Central London"),

            Station(name: "Leicester Square", lines: [northern, piccadilly], trivia: "alight here for cinemas and restaurants in the heart of London's West End theatre district.", location: "Central London"),

            Station(name: "Piccadilly Circus", lines: [bakerloo, piccadilly], trivia: "famous for its neon signs and the Shaftesbury Memorial Fountain with its statue of Anteros, often mistaken for Eros.", location: "Central London"),

            Station(name: "Victoria", lines: [circle, district, victoria, nationalRail], trivia: "contrary to popular belief, this station was not named after a famous monarch.", location: "Central London"),

            Station(name: "Waterloo", lines: [bakerloo, jubilee, northern, waterlooCity, nationalRail], trivia: "the UK's busiest railway station by passenger usage.", location: "South London"),

            Station(name: "London Bridge", lines: [jubilee, northern, nationalRail], trivia: "the oldest railway terminus in London, opened in 1836.", location: "South London"),

            Station(name: "Bank", lines: [central, northern, waterlooCity], trivia: "this forms a complex with Monument station and serves the City of London.", location: "Central London"),

            Station(name: "Westminster", lines: [circle, district, jubilee], trivia: "alight here for Big Ben and the Houses of Parliament", location: "Central London"),

            Station(name: "Embankment", lines: [bakerloo, circle, district, northern], trivia: "The only place on the Underground where you can still hear \"Mind the Gap\" announced by Oswald Laurence", location: "Central London"),

            Station(name: "Charing Cross", lines: [bakerloo, northern], trivia: "traditionally considered the center of London for distance measurements.", location: "Central London"),

            Station(name: "Tottenham Court Road", lines: [central, northern, elizabeth], trivia: "its name has nothing to do with a famous north London football club.", location: "Central London"),

            Station(name: "Holborn", lines: [central, piccadilly], trivia: "named after the nearby River Fleet, it serves the legal district of London.", location: "Central London"),

            Station(name: "Euston", lines: [northern, victoria, overground], trivia: "The main London terminus for trains to the midlands, North West and Scotland.", location: "North London"),

            Station(name: "Earl's Court", lines: [district, piccadilly], trivia: "once home to a famous exhibition center, it's a major interchange station serving West London.", location: "West London"),

            Station(name: "South Kensington", lines: [circle, district, piccadilly], trivia: "alight here for Museum Row.", location: "West London"),

            Station(name: "Notting Hill Gate", lines: [central, circle, district], trivia: "alight here for row of colourful houses and Portobello Road Market.", location: "West London"),

            Station(name: "Baker Street", lines: [bakerloo, circle, hammersmithCity, jubilee, metropolitan], trivia: "alight here for the fictional home of Sherlock Holmes.", location: "Central London"),

            Station(name: "Paddington", lines: [bakerloo, circle, district, hammersmithCity, elizabeth, nationalRail], trivia: "a famous fictional bear is named after this station.", location: "West London"),

            Station(name: "Edgware Road", lines: [bakerloo, circle, district, hammersmithCity], trivia: "actually two physically separate stations amidst a large middle eastern community.", location: "West London"),

            Station(name: "Mile End", lines: [central, district, hammersmithCity], trivia: "named after its location, it's one mile from the old City of London boundary at Aldgate.", location: "East London"),

            Station(name: "Finchley Road", lines: [jubilee, metropolitan], trivia: "serves the affluent areas of Swiss Cottage, St. John's Wood and Hampstead.", location: "North London"),

            Station(name: "Hammersmith", lines: [circle, district, hammersmithCity, piccadilly], trivia: "near a famous suspension bridge that was deemed too weak to support cars and pedestrianised.", location: "West London"),

            Station(name: "Stockwell", lines: [northern, victoria], trivia: "serves as an important interchange between North and South London.", location: "South London"),

            Station(name: "Balham", lines: [northern, nationalRail], trivia: "known as the 'Gateway to the South', this station serves both Underground and National Rail services in South London.", location: "South London"),

            Station(name: "Clapham Junction", lines: [nationalRail], trivia: "Britain's busiest railway station by train movements, handling over 2,000 trains per day with no Underground connection.", location: "South London"),

            Station(name: "Finsbury Park", lines: [piccadilly, victoria], trivia: "serves a major music venue and one of North London's largest green spaces, popular for festivals and events.", location: "North London"),

            Station(name: "Barking", lines: [district, hammersmithCity, overground], trivia: "This East London station was the terminus of the world's first electric tube railway when it opened in 1902.", location: "East London"),

            Station(name: "West Ham", lines: [jubilee, district, dlr, elizabeth], trivia: "Forever Blowing Bubbles", location: "East London"),

            Station(name: "Moorgate", lines: [circle, hammersmithCity, metropolitan, northern, elizabeth], trivia: "Named after one of the ancient gates in the London Wall, this station serves the financial district.", location: "Central London"),

            Station(name: "Acton Town", lines: [district, piccadilly], trivia: "An important junction title meaning Oak Town", location: "West London"),

            Station(name: "Ealing Common", lines: [district, piccadilly], trivia: "This area earned the nickname \"The Queen of the Suburbs\"", location: "West London"),

            // Elizabeth line stations
            Station(name: "Farringdon", lines: [circle, hammersmithCity, metropolitan, elizabeth, nationalRail], trivia: "a major Elizabeth line hub connecting to Thameslink services, serving the historic Smithfield Market area.", location: "Central London"),

            Station(name: "Whitechapel", lines: [district, hammersmithCity, elizabeth], trivia: "historic East London station famous for its connection to Jack the Ripper.", location: "East London"),

            Station(name: "Canary Wharf", lines: [jubilee, elizabeth, dlr], trivia: "London's financial district skyscraper hub surrounded by waterways.", location: "East London"),

            Station(name: "Stratford", lines: [central, jubilee, elizabeth, dlr], trivia: "received a massive upgrade for the 2012 Olympic Games.", location: "East London"),

            // DLR-focused stations

            Station(name: "Tower Gateway", lines: [dlr, circle, district], trivia: "a lesser known station, it serves the iconic Tower of London and Tower Bridge.", location: "Central London"),


            // Additional Elizabeth line connections
            Station(name: "Custom House", lines: [elizabeth, dlr], trivia: "modern interchange station serving the ExCeL London exhibition center and London City Airport area.", location: "East London"),

            // Overground stations
            Station(name: "Highbury & Islington", lines: [northern, victoria, overground], trivia: "named after the two main areas it serves.", location: "North London"),

            Station(name: "Canada Water", lines: [jubilee, overground], trivia: "one of two stations with another country in its name.", location: "South East London"),

            Station(name: "Richmond", lines: [district, overground], trivia: "alight here if you want to go deer-spotting.", location: "South West London"),

            Station(name: "Wimbledon", lines: [district, tram], trivia: "Famous worldwide for its tennis championships", location: "South West London"),

            Station(name: "Willesden Junction", lines: [bakerloo, overground], trivia: "originally known as \"The Wilderness\" due to its complex network of entrances and passages", location: "North West London"),

            Station(name: "West Brompton", lines: [district, overground], trivia: "It's got a compass direction in the name.", location: "West London"),

            Station(name: "Kensington Olympia", lines: [district, overground], trivia: "once home to a major exhibition center and events venue, now serves residential West London with connections to both Underground and Overground services.", location: "West London"),

            Station(name: "Shepherd's Bush", lines: [central, overground], trivia: "a major West London transport hub serving the shopping and entertainment district, including the famous Westfield shopping center.", location: "West London"),

            Station(name: "Ealing Broadway", lines: [central, elizabeth], trivia: "The western terminus of the Central line and a major Elizabeth line station, serving as a key transport hub for West London and beyond.", location: "West London"),

            Station(name: "Shadwell", lines: [dlr, overground], trivia: "historic East London station in the heart of the former docklands.", location: "East London"),

            Station(name: "Warren Street", lines: [northern, victoria], trivia: "named after a developer who built houses in the area, it serves the bustling Fitzrovia district near the BBC Broadcasting House.", location: "Central London")

        ]
    }()

    var multiLineStations: [Station] {
        stations.filter { $0.lines.count >= 2 }
    }

    private init() {}
}