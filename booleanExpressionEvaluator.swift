/*
Made with the help of ChatGPT
*/

import Foundation

class BooleanEvaluator {
    
    private var variables = Set<String>()
    
    func buildParseTree(expression: String) -> BoolNode? {
        let cleanedExpression = expression.replacingOccurrences(of: " ", with: "")
        let tokens = Array(cleanedExpression)
        
        var index = 0
        return parseExpression(tokens: tokens, index: &index)
    }
    
    private func parseExpression(tokens: [Character], index: inout Int) -> BoolNode? {
        var leftNode = parseTerm(tokens: tokens, index: &index)
        
        while index < tokens.count {
            let operatorToken = tokens[index]
            if operatorToken == "&" {
                index += 1
                if let rightNode = parseTerm(tokens: tokens, index: &index) {
                    leftNode = BoolNode(operatorToken, leftNode!, rightNode)
                } else {
                    return nil
                }
            } else {
                break
            }
        }
        
        return leftNode
    }
    
    private func parseTerm(tokens: [Character], index: inout Int) -> BoolNode? {
        var leftNode = parseFactor(tokens: tokens, index: &index)
        
        while index < tokens.count {
            let operatorToken = tokens[index]
            if operatorToken == "|" {
                index += 1
                if let rightNode = parseFactor(tokens: tokens, index: &index) {
                    leftNode = BoolNode(operatorToken, leftNode!, rightNode)
                } else {
                    return nil
                }
            } else {
                break
            }
        }
        
        return leftNode
    }
    
    private func parseFactor(tokens: [Character], index: inout Int) -> BoolNode? {
        let token = tokens[index]
        if token == "!" {
            index += 1
            if let innerNode = parseFactor(tokens: tokens, index: &index) {
                return BoolNode("!", innerNode: innerNode)
            } else {
                return nil
            }
        } else if token == "(" {
            index += 1
            if let expressionNode = parseExpression(tokens: tokens, index: &index), tokens[index] == ")" {
                index += 1
                return expressionNode
            } else {
                return nil
            }
        } else if token.isLetter {
            index += 1
            variables.insert(String(token))
            return BoolNode(variable: String(token))
        }
        return nil
    }
    
    func generateTruthTable(parseTree: BoolNode) {
        let variableList = Array(variables)
        let header = variableList.joined(separator: "\t") + "\tResult"
        print(header)
        
        let truthValues = generateTruthValues(variables: variableList)
        for values in truthValues {
            var row = ""
            for (index, variable) in variableList.enumerated() {
                row += "\(variable)=\(values[index])\t"
            }
            row += "Result=\(parseTree.evaluate(variables: values))"
            print(row)
        }
    }
    
    private func generateTruthValues(variables: [String]) -> [[Bool]] {
        let rowCount = Int(pow(2.0, Double(variables.count)))
        var truthValues: [[Bool]] = []
        
        for i in 0..<rowCount {
            var binaryString = String(i, radix: 2)
            while binaryString.count < variables.count {
                binaryString = "0" + binaryString
            }
            let values = binaryString.map { $0 == "1" }
            truthValues.append(values)
        }
        
        return truthValues
    }
}

class BoolNode {
    let variable: String?
    let operation: Character?
    let innerNode: BoolNode?
    let left: BoolNode?
    let right: BoolNode?
    
    init(variable: String) {
        self.variable = variable
        self.operation = nil
        self.innerNode = nil
        self.left = nil
        self.right = nil
    }
    
    init(_ operation: Character, innerNode: BoolNode) {
        self.variable = nil
        self.operation = operation
        self.innerNode = innerNode
        self.left = nil
        self.right = nil
    }
    
    init(_ operation: Character, _ left: BoolNode, _ right: BoolNode) {
        self.variable = nil
        self.operation = operation
        self.innerNode = nil
        self.left = left
        self.right = right
    }
    
    func evaluate(variables: [Bool]) -> Bool {
        if let variable = variable {
            guard let index = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ").firstIndex(of: Character(variable)) else {
                return false
            }
            return variables[index]
        } else if let operation = operation, let innerNode = innerNode {
            switch operation {
            case "!":
                return !innerNode.evaluate(variables: variables)
            default:
                return false
            }
        } else if let operation = operation, let left = left, let right = right {
            switch operation {
            case "&":
                return left.evaluate(variables: variables) && right.evaluate(variables: variables)
            case "|":
                return left.evaluate(variables: variables) || right.evaluate(variables: variables)
            default:
                return false
            }
        } else {
            return false
        }
    }
}

// User input
print("Enter a boolean expression:")
if let expression = readLine() {
    let booleanEvaluator = BooleanEvaluator()
    if let parseTree = booleanEvaluator.buildParseTree(expression: expression) {
        booleanEvaluator.generateTruthTable(parseTree: parseTree)
    } else {
        print("Invalid boolean expression.")
    }
} else {
    print("Failed to read user input.")
}



