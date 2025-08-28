//
//  Gym_Management_AppTests.swift
//  Gym_Management_AppTests
//
//  Created by Waseem Abbas on 07/08/2025.
//

import XCTest
@testable import Gym_Management_App
import CoreData

final class Gym_Management_AppTests: XCTestCase {
    var vm : MemberViewModel!   // System under test
    var context: NSManagedObjectContext!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Create in-memory Core Data container
        let container = NSPersistentContainer(name: "Gym_Management_App") // must match your .xcdatamodeld file name
        let description = NSPersistentStoreDescription()
        description.url = URL(fileURLWithPath: "/dev/null") // in-memory
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { _, error in
            XCTAssertNil(error)
        }
        
        context = container.viewContext
        vm = MemberViewModel(context: context)
    }
    
    override func tearDownWithError() throws {
        vm = nil
        context = nil
        try super.tearDownWithError()
    }
    
    func testFetchMembers_whenEmpty_shouldReturnZero() {
        vm.fetchMembers()
        XCTAssertEqual(vm.members.count, 0)
    }
    func testFetchMembers_withOneMember_shouldReturnOne() {
//        Given
        let member = MemberEntity(context: context)
        member.id = UUID()
        member.age = "22"
        member.isPaid = false
        member.name = "waseem"
        member.membershipType = "basics"
        member.profileImagePath = nil
//        when
        vm.fetchMembers()
//        Then
        XCTAssertEqual(vm.members.count, 1)
        XCTAssertNotEqual(vm.members.count, 0)
        XCTAssertNotNil(vm.members)
    }
    func testDeleteMember_fromDatabse_shouldReturnZero() {
        //        Given
                let member = MemberEntity(context: context)
                member.id = UUID()
                member.age = "22"
                member.isPaid = false
                member.name = "waseem"
                member.membershipType = "basics"
                member.profileImagePath = nil
        //        when
                vm.fetchMembers()
        vm.deleteMember(member: member)
//        Then
        XCTAssertEqual(vm.members.count, 0)
    }
    func testAddmember_toCoreData_shouldReturnOne () {
//        Given
        vm.members = []
        vm.fetchMembers()
        XCTAssertEqual(vm.members.count, 0)
//        when
        let member = MemberEntity(context: context)
        member.id = UUID()
        member.age = "22"
        member.isPaid = false
        member.name = "waseem"
        member.membershipType = "basics"
        member.profileImagePath = nil
        try? context.save()
        vm.fetchMembers()
//        Then
        XCTAssertEqual(vm.members.count, 1)
        XCTAssertEqual(vm.members.first?.name, "waseem")
    }
}

