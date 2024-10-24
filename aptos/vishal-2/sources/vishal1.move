module MyModule::CourseBadges {
    use aptos_framework::signer;
    use std::string::String;
   
    /// Struct representing a course completion badge
    struct Badge has store, key {
        id: u64,
        course_name: String,
        issued_by: address,
        issue_date: u64,
    }

    /// Struct to track instructor status
    struct Instructor has key {
        is_active: bool
    }

    /// Error codes
    const E_NOT_INSTRUCTOR: u64 = 1;
    const E_ALREADY_HAS_BADGE: u64 = 2;

    /// Function to register a new instructor
    public fun register_instructor(account: &signer) {
        let instructor = Instructor {
            is_active: true
        };
        move_to(account, instructor);
    }

    /// Function for instructors to issue badges to students
    public fun issue_badge(
        instructor: &signer,
        student: address,
        course_name: String,
        timestamp: u64,
        badge_id: u64
    ) acquires Instructor {
        // Verify instructor status
        let instructor_addr = signer::address_of(instructor);
        assert!(exists<Instructor>(instructor_addr), E_NOT_INSTRUCTOR);
       
        // Check if student already has badge
        assert!(!exists<Badge>(student), E_ALREADY_HAS_BADGE);

        // Create and issue new badge
        let badge = Badge {
            id: badge_id,
            course_name,
            issued_by: instructor_addr,
            issue_date: timestamp,
        };
        move_to(student, badge);  // Move badge to the student's account
    }

    /// Function to retrieve a student's badge
    public fun get_badge(student: address): Option<Badge> {
        if (exists<Badge>(student)) {
            return Some(borrow_global<Badge>(student));
        } else {
            return None;
        }
    }
}
