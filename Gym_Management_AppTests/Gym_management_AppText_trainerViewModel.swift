//
//  Gym_management_AppText_trainerViewModel.swift
//  Gym_Management_AppTests
//
//  Created by Waseem Abbas on 28/08/2025.
//

import XCTest
import CoreData
@testable import Gym_Management_App

final class Gym_management_AppText_trainerViewModel: XCTestCase {

    var vm : TrainerViewModel!
    var context: NSManagedObjectContext!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Create in-memory Core Data container
        let container = NSPersistentContainer(name: "Gym_Management_App")
        let description = NSPersistentStoreDescription()
        description.url = URL(fileURLWithPath: "/dev/null") // in-memory
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { _, error in
            XCTAssertNil(error)
        }
        
        context = container.viewContext
        vm = TrainerViewModel(context: context)
    }
    
    override func tearDownWithError() throws {
        vm = nil
        context = nil
        try super.tearDownWithError()
    }
    func testFetchTrainers_whenEmpty_shouldReturnZero () {
//        Given
        vm.fetchTrainers()
//        Then
        XCTAssertEqual(vm.trainers.count, 0)
        
    }
    func testAddonetrainer_shouldReturnOne () {
//      Given
        vm.trainers = []
        vm.fetchTrainers()
        XCTAssertEqual(vm.trainers.count, 0)
        let trainer = TrainerEntity(context: context)
        trainer.name = "Abbas"
        trainer.number = "0338922"
        trainer.profileImagePath = nil
        trainer.id = UUID()
        trainer.speciality = "strength"
//        when
        try? context.save()
        vm.fetchTrainers()
//        Then
        XCTAssertEqual(vm.trainers.count, 1)
        XCTAssertNotEqual(vm.trainers.count, 0)
    }
    func testDeleteTrainer_shouldReturnZero () {
//        Given
        vm.trainers = []
        vm.fetchTrainers()
        XCTAssertEqual(vm.trainers.count, 0)
        let trainer = TrainerEntity(context: context)
        trainer.name = "Abbas"
        trainer.number = "0338922"
        trainer.profileImagePath = nil
        trainer.id = UUID()
        trainer.speciality = "strength"
//        when
        try? context.save()
        vm.fetchTrainers()
        vm.deleteTrainer(trainer: trainer)
//        Then
        XCTAssertEqual(vm.trainers.count, 0)
    }
}
