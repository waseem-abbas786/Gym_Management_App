//
//  Gym_management_AppText_AdminViewModel.swift
//  Gym_Management_AppTests
//
//  Created by Waseem Abbas on 28/08/2025.
//

import XCTest
@testable import Gym_Management_App
import CoreData

final class Gym_management_AppText_AdminViewModel: XCTestCase {

    var vm : AdminViewModel!
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
        vm = AdminViewModel(context: context)
    }
    
    override func tearDownWithError() throws {
        vm = nil
        context = nil
        try super.tearDownWithError()
    }
    func testFetchRequest_shouldBezero () {
        vm.fetchAdmins()
        
        XCTAssertEqual(vm.admins.count, 0)
    }
    func testAddAdmin_ShouldReturnOne () {
//        Given
        vm.admins = []
        XCTAssertEqual(vm.admins.count, 0)
//        When
       let admin = AdminEntity(context: context)
        admin.name = "Flex"
        admin.gymAddress = "khanpur"
        admin.gymName = "gym"
        admin.profileImagePath = nil
        admin.id = UUID()
        try? context.save()
        vm.fetchAdmins()
//        Then
        XCTAssertEqual(vm.admins.count, 1)
        XCTAssertNotEqual(vm.admins.count, 0)
        XCTAssertEqual(vm.admins.first?.name, "Flex")
    }
}
