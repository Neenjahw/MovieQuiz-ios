//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Pavel Popov on 27.01.2024.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    // -MARK: Properties
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewControllerProtocol?
    private let statisticService: StatisticService!
    
    
    init(viewController: MovieQuizViewControllerProtocol)  {
        self.viewController = viewController
        
        statisticService = StatisticServiceImplementation()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var currentQuestion: QuizQuestion?
    private var correctAnswers: Int = 0
    
    // -MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    
    // -MARK: public func
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
        //viewController?.enebleButtons()
    }
    
    //если нажал кнопку да
    func yesButtonClicked() {
        didAnswer(isYes: true)
        viewController?.disableButtons()
    }
    
    //действие кнопки нет
    func noButtonClicked()  {
        didAnswer(isYes: false)
        viewController?.disableButtons()
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    
    func makeResultMessage() -> String {
        
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        guard let bestGame = statisticService.bestGame else {return "error"}
        
        let totalPlayesCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let currentGameResultLine = "Ваш результат: \(correctAnswers)\\\(questionsAmount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)\\\(bestGame.total)" + "(\(bestGame.date.dateTimeString))"
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        let resultMessage = [currentGameResultLine, totalPlayesCountLine, bestGameInfoLine, averageAccuracyLine].joined(separator: "\n")
        
        return resultMessage
    }

    
    // -MARK: private func
    //действие кнопок да/нет
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    private func didAnswer(isYes: Bool) {
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = isYes
        
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        
    }
 
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    private func didAnswer(isCorrect: Bool) {
        if (isCorrect) { correctAnswers += 1}
    }
    
    
    // приватный метод, который содержит логику перехода в один из сценариев
    // метод ничего не принимает и ничего не возвращает
    private func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            
            viewController?.showFinalResults()
            
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
            //viewController?.enableButtons()
        }
    }
   
    private func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrect: isCorrect)
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        //запускаем следующую задачу через 1 секунду
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {return}
            viewController?.noImageBorder()
            self.correctAnswers = correctAnswers
            self.proceedToNextQuestionOrResults()
            viewController?.enableButtons()
        }
    }
}
