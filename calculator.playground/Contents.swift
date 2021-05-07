import Foundation

enum calcErrors : Error {
    case SyntaxError
    case ZeroDivisionError
    case NonRealNumberError
    case UnknownOperation
}

var operators = ["+", "-", "*", "/", "^", "?"]
let digits = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "."]
let startBrackets = ["(", "{", "["]
let endBrackets = [")", "}", "]"]
var numFound = false

func parseEquation (eq : String) throws -> [String]{
    let nEQ = "+" + eq + "?"
    var character = ""
    var term = ""
    var terms = [String]()
    var num = 0.0
    var swap = 1.0
    var index = 0
    
    
    for char in nEQ {
        character = String(char)
        if operators.contains(character) || endBrackets.contains(character){
            if character == "?" && terms.last == ")" {
                terms.append(character)
                break
            }
            if term != ""{
                num = Double(term)! * swap
                swap = 1.0
                term = ""
                if endBrackets.contains(terms.last!){
                    terms.append("*")
                }
                terms.append(String(num))
            }
            terms.append(character)
        }
        
        else if digits.contains(character) {
            numFound = true
            term += character
        }
        
        else if character == "~" {
            swap *= -1.0
        }
        
        else if startBrackets.contains(character) {
            if index == 0 {
                terms.append("0.0")
                terms.append("+")
            }
            else if term != "" {
                num = Double(term)! * swap
                swap = 1.0
                term = ""
                if terms != [] {
                    if endBrackets.contains(terms.last!) && terms != []{terms.append("*")}
                }
                terms.append(String(num))
                terms.append("*")
            }
            else if endBrackets.contains(terms.last!) {
                terms.append("*")
                terms.append("1.0")
                terms.append("*")
            }
            else if swap == -1.0 {
                if ["+", "-", "*"].contains(terms.last!) {
                    terms.append("-1.0")
                    terms.append("*")
                    swap = 1.0
                }
                else if terms.last! == "^" {
                    terms.append("-1.0")
                    terms.append("^")
                    swap = 1.0
                }
                else if terms.last! == "/" {
                    terms.append("-1.0")
                    terms.append("/")
                    swap = 1.0
                }
            }
            terms.append(character)
        }
        else if character == " " {}
    
        else {throw calcErrors.SyntaxError}
        index += 1
    }
    terms.removeLast()
    return terms
}

func opError (terms: inout [String]) throws -> [String] {
    if !numFound {throw calcErrors.SyntaxError}
    var index = 0
    var term = ""
    var nextTerm = ""
    if terms.count <= 1 {
        return terms
    }
    repeat {
        term = terms[index]
        nextTerm = terms[index + 1]
        if operators.contains(term) && operators.contains(nextTerm) {
            throw calcErrors.SyntaxError
        }
        index += 1
    } while index + 1 < terms.count
    var left = 0
    var right = 0
    for t in terms {
        if startBrackets.contains(t) {left += 1}
        else if endBrackets.contains(t) {right += 1}
    }
    if left != right {throw calcErrors.SyntaxError}
    return terms
}

func solveEquation (terms: inout [String]) throws -> Double {
    if operators.last == "?" {operators.removeLast()}
    if terms.count == 0 {throw calcErrors.SyntaxError}
    var pTerms = [String]()
    var eTerms = [String]()
    var mdTerms = [String]()
    var term = ""
    var computedTerm = 0.0
    var answer = 0.0
    
    // Parenthesis Solve
    repeat {
        term = terms.removeFirst()
        if startBrackets.contains(term) {
            do {
                computedTerm = try solveEquation(terms: &terms)
                terms.insert(String(computedTerm), at: 0)
            }
            catch calcErrors.NonRealNumberError {throw calcErrors.NonRealNumberError}
            catch calcErrors.SyntaxError {throw calcErrors.SyntaxError}
            catch calcErrors.ZeroDivisionError {throw calcErrors.ZeroDivisionError}
            catch calcErrors.UnknownOperation {throw calcErrors.UnknownOperation}
        }
        
        else if endBrackets.contains(term) {
            break
        }
        
        else {pTerms.append(term)}
    } while terms.count > 0
    
    var pre : Double? = 0.0
    var next : Double? = 0.0
    var holder = 0.0
    
    // Exponent Solve
    repeat {
        term = pTerms.removeFirst()
        if term == "^" {
            pre = Double(eTerms.popLast()!) ?? nil
            next = Double(pTerms[0]) ?? nil
            if let n = next, let p = pre{
                pTerms.removeFirst()
                holder = pow(p, n)
                if holder.isNaN {
                    if (1/n).truncatingRemainder(dividingBy: 2) == 1 {
                        holder = -pow(p * -1, n)
                        pTerms.insert(String(holder), at: 0)
                    }
                    else {throw calcErrors.NonRealNumberError}
                }
                else {pTerms.insert(String(holder), at: 0)}
            }
        }
        else {eTerms.append(term)}
    } while pTerms.count > 0
    
//    print(eTerms, "E") Uncomment if you want to debug
    
    // Multiplication and Divison Solve
    repeat {
        term = eTerms.removeFirst()
        if term == "*" || term == "/" {
            pre = Double(mdTerms.popLast()!) ?? nil
            next = Double(eTerms[0]) ?? nil
            if var n = next, let p = pre{
                if term == "/" {
                    guard n != 0 else {
                        throw calcErrors.ZeroDivisionError
                    }
                    n = 1/n
                }
                eTerms.removeFirst()
                eTerms.insert(String(p * n), at: 0)
            }
        }
        else {mdTerms.append(term)}
    } while eTerms.count > 0
    
//    print(mdTerms, "MD") Uncomment if you want to debug
    
    if mdTerms.first != "+" {
        mdTerms.insert("+", at: 0)
    }
    
    // Addition and Subtraction Solve
    var swap = 1.0
    
    repeat {
        term = mdTerms.removeFirst()
        if term == "-" {swap = -1.0}
        if term == "+" || term == "-"{
            pre = Double(mdTerms[0]) ?? nil
            if let p = pre {
                answer += p * swap
                swap = 1.0
            }
        }
    } while mdTerms.count > 0
    
//    print(answer, "AS") Uncomment if you want to debug
    
    return answer
}

func calculate (equation : String) -> String {
    do {
        var parsed = try parseEquation(eq: equation)
        do {
            var opChecked = try opError(terms: &parsed)
            do {
                let answer = try solveEquation(terms: &opChecked)
                return String(answer)
            }catch calcErrors.NonRealNumberError {return "A Non-Real Number Found"}
            catch calcErrors.SyntaxError {return "Invalid Syntax"}
            catch calcErrors.ZeroDivisionError {return "Cannot Divide By 0"}
            catch calcErrors.UnknownOperation {return "Unknown Error Has Occured."}
            catch {return "Unknown Error Has Occured"}
        } catch calcErrors.SyntaxError {return "Invalid Syntax"}
        
    }
    catch calcErrors.SyntaxError{return "Invalid Syntax!"}
    catch {return "Unknown Error Has Occured"}
}

var equation = "3+3" // Sample Equation Please Edit the Variable
print("Answer:", calculate(equation: equation))


