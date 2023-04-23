import Foundation

struct DomainModel {
    var text = "Hello, World!"
        // Leave this here; this value is also tested in the tests,
        // and serves to make sure that everything is working correctly
        // in the testing harness and framework.
}

////////////////////////////////////
// Money
//
public struct Money {
    var amount:Int
    var currency:String
    init(amount:Int, currency:String) {
        self.amount = amount
        self.currency = currency
    }
    func convert(_ newCurrency:String) -> Money {
        let amountInUSD: Double
        switch self.currency {
            case "GBP":
                amountInUSD = Double(self.amount) / 0.5
            case "EUR":
                amountInUSD = Double(self.amount) / 1.5
            case "CAN":
                amountInUSD = Double(self.amount) / 1.25
            case "USD":
                amountInUSD = Double(self.amount)
            default:
                fatalError("Unsupported currency")
        }
        let finalAmount: Double
        switch newCurrency {
            case "GBP":
                finalAmount = amountInUSD * 0.5
            case "EUR":
                finalAmount = amountInUSD * 1.5
            case "CAN":
                finalAmount = amountInUSD * 1.25
            case "USD":
                finalAmount = amountInUSD
            default:
                fatalError("Unsupported currency")
        }
        return Money(amount: Int(round(finalAmount)), currency: newCurrency)
    }
    func add(_ addMoney:Money) -> Money {
        let currentMoneyConverted = Money(amount: self.amount, currency: self.currency).convert("USD")
        let incomingMoneyConverted = addMoney.convert("USD")
        let newAmountUSD = currentMoneyConverted.amount + incomingMoneyConverted.amount
        return Money(amount: newAmountUSD, currency: "USD").convert(addMoney.currency)
    }
    func substract(_ substractMoney:Money) -> Money {
        let currentMoneyConverted = Money(amount: self.amount, currency: self.currency).convert("USD")
        let substractMoneyConverted = substractMoney.convert("USD")
        let newAmountUSD = currentMoneyConverted.amount - substractMoneyConverted.amount
        return Money(amount: newAmountUSD, currency: "USD").convert(substractMoney.currency)
    }
}

////////////////////////////////////
// Job
//
public class Job {
    public enum JobType {
        case Hourly(Double)
        case Salary(UInt)
    }
    var title: String
    var type: JobType
    init(title: String, type: JobType) {
        self.title = title
        self.type = type
    }
    func calculateIncome(_ hours:Int) -> Int {
        switch type {
            case .Hourly(let income):
                return Int(income * Double(hours))
            case .Salary(let income):
                return Int(income)
        }
    }
    func raise(byAmount amount:Double) {
        switch type {
            case .Hourly(let income):
                type = .Hourly(income + amount)
            case .Salary(let income):
                type = .Salary(income + UInt(amount))
        }
    }
    func raise(byPercent percentage:Double) {
        switch type {
        case .Hourly(let income):
            type = .Hourly(income * (1 + percentage))
        case .Salary(let income):
            let newIncome = Double(income) * (1 + percentage)
            type = .Salary(UInt(newIncome))
        }
    }
}

////////////////////////////////////
// Person
//
public class Person {
    var firstName:String
    var lastName:String
    var age:Int
    private var _job: Job?
    var job: Job? {
        get {return _job}
        set {
            if age >= 16 {
                _job = newValue
            } else {
                _job = nil
            }
        }
    }
    private var _spouse: Person?
    var spouse:Person? {
        get {return _spouse}
        set {
            if age >= 16 {
                _spouse = newValue
            } else {
                _spouse = nil
            }
        }
    }
    init(firstName: String, lastName: String, age: Int, job: Job? = nil, spouse: Person? = nil) {
        self.firstName = firstName
        self.lastName = lastName
        self.age = age
        self.job = job
        self.spouse = spouse
    }
    
    func toString() -> String {
        return "[Person: firstName:\(String(describing: firstName)) lastName:\(String(describing: lastName)) age:\(String(describing: age)) job:\(String(describing: job)) spouse:\(String(describing: spouse))]"
    }
}

////////////////////////////////////
// Family
//
public class Family {
    var members: [Person]
    init(spouse1: Person, spouse2: Person) {
        self.members = [spouse1, spouse2]
        spouse1.spouse = spouse2
        spouse2.spouse = spouse1
    }
    func haveChild(_ child: Person) -> Bool {
        if (members[0].age > 21 || members[1].age > 21)  {
            members.append(child)
            return true
        }
        return false
    }
    func householdIncome() -> Int {
        var totalIncome = 0
        for person in members {
            if let job = person.job {
                switch job.type {
                    case .Hourly(let wage):
                        totalIncome += Int(wage * 2000)
                    case .Salary(let salary):
                        totalIncome += Int(salary)
                }
            }
        }
        return totalIncome
    }
}
