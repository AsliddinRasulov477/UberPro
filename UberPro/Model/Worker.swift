struct Location {
    var coordinate: [Double]
}

class Worker {
    var _id: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var phone: String = ""
    var distance: Double = 0
    var balance: Double = 0
    var jobs: [String] = []
    var images: [String] = []
    var description: String = ""
    var avatar: String = ""
    var location: Location = Location(coordinate: [0, 0])
}
