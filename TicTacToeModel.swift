//
//  TicTacToeModel.swift
//  TicTacToe
//
//  Created by Daria Shevchenko on 11.12.2022.
//

import Foundation
import SwiftUI

public enum SquareStatus {
    case empty
    case gamer1
    case gamer2
}

public enum GameTime: Int {
    case m5 = 5
    case m10 = 10
    case m15 = 15
    case without = 10000
}

public enum GamerTime: Int {
    case m10 = 10
    case m15 = 15
    case m60 = 60
    case without = 10000
}

public class TicTacToeModel: ObservableObject {
    // MARK: - Properties

    @Published public var squares = [Square]()

    private var moves: [Int] = []
    private var lastElem: (Int, Square)? = (0, Square(status: .empty))

    private var gamerTime: Int = 0
    private var gameTime: Int = 0

    private var gamerTimer = TimerManager()

    // MARK: - Init

    public init(gameTime: GameTime, gamerTime: GamerTime) {
        self.gameTime = gameTime.rawValue
        self.gamerTime = gamerTime.rawValue
        gamerTimer.start()
        for _ in 0...8 {
            squares.append(Square(status: .empty))
        }
    }

    // MARK: - Actions

    public func resetGame() {
        for i in 0...8 {
            squares[i].squareStatus = .empty
        }
        moves = []
        gamerTimer.stop()
        gamerTimer.start()
    }

    public func resign() {
        for i in 0...8 {
            squares[i].squareStatus = .empty
        }
        moves = []
    }

    public var gameOver: (SquareStatus, Bool) {
        if thereIsAWinner != .empty {
            return (thereIsAWinner, true)
        } else {
            for i in 0...8 {
                if squares[i].squareStatus == .empty {
                    return (.empty, false)
                }
            }
            return (.empty, true)
        }
    }

    private var thereIsAWinner: SquareStatus {
        if let check = checkIndexes([0, 1, 2]) {
            return check
        } else if let check = checkIndexes([3, 4, 5]) {
            return check
        } else if let check = checkIndexes([6, 7, 8]) {
            return check
        } else if let check = checkIndexes([0, 3, 6]) {
            return check
        } else if let check = checkIndexes([1, 4, 7]) {
            return check
        } else if let check = checkIndexes([2, 5, 8]) {
            return check
        } else if let check = checkIndexes([0, 4, 8]) {
            return check
        } else if let check = checkIndexes([2, 4, 6]) {
            return check
        }
        return .empty
    }

    private func checkIndexes(_ indexes: [Int]) -> SquareStatus? {
        var homeCounter = 0
        var visitorCounter = 0
        for index in indexes {
            let square = squares[index]
            if square.squareStatus == .gamer1 {
                homeCounter += 1
            } else if square.squareStatus == .gamer2 {
                visitorCounter += 1
            }
        }
        if homeCounter == 3 {
            return .gamer1
        } else if visitorCounter == 3 {
            return .gamer2
        }
        return nil
    }

    func moveAI() {
        var index = Int.random(in: 0...8)
        while makeMove(index: index, player: .gamer2) == false, gameOver.1 == false {
            index = Int.random(in: 0...8)
        }
    }

    public func makeMove(index: Int, player: SquareStatus) -> Bool {
        if squares[index].squareStatus == .empty {
            squares[index].squareStatus = player
            if player == .gamer1 {
                moveAI()
            }
            moves.append(index)
            return true
        }
        return false
    }

    public func rollBack() {
        guard let index = moves.last else { return }
        lastElem = (index, squares[index])
        squares[index].squareStatus = .empty
        moves.remove(at: index)
    }

    public func rollForward() {
        guard let elem = lastElem else { return }
        squares[elem.0] = elem.1
        lastElem = nil
        moves.append(elem.0)
    }

    public func gameHistory() -> [(SquareStatus, Int)] {
        var info: [(SquareStatus, Int)] = []
        for move in moves {
            print("Gamer \(squares[move].squareStatus) have move on \(move) index")
            info.append((squares[move].squareStatus, move))
        }
        return info
    }

    public func rollBackActionFeedback() -> [(SquareStatus, Int)] {
        var info: [(SquareStatus, Int)] = []
        for move in moves {
            print("Gamer \(squares[move].squareStatus), on \(move) index")
            info.append((squares[move].squareStatus, move))
        }
        return info
    }

    public func rollForwardActionFeedback() -> [(SquareStatus, Int)] {
        var info: [(SquareStatus, Int)] = []
        for move in moves {
            print("Gamer \(squares[move].squareStatus), on \(move) index")
            info.append((squares[move].squareStatus, move))
        }
        return info
    }

    public func getAvailablePositions() -> [Int] {
        var positions: [Int] = []
        for index in 0...8 {
            if !moves.contains(where: { $0 == index }) {
                positions.append(index)
            }
        }
        return positions
    }
}

public class Square: ObservableObject {
    @Published public var squareStatus: SquareStatus

    public init(status: SquareStatus) {
        squareStatus = status
    }
}

public enum TimerMode {
    case running
    case stopped
    case paused
}

public final class TimerManager: ObservableObject {
    @Published var mode: TimerMode = .stopped
    @Published var secondsElapsed = 0.0
    var timer = Timer()

    public func start() {
        mode = .running
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.secondsElapsed = self.secondsElapsed + 0.1
        }
    }

    public func pause() {
        timer.invalidate()
        mode = .paused
    }

    public func stop() {
        timer.invalidate()
        secondsElapsed = 0
        mode = .stopped
    }
}
