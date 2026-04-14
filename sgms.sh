#! /usr/bin/bash
shopt -s extglob

std_data_dir="sgms_data/students/"
grade_data_dir="sgms_data/grades/"
subjects_data_dir="sgms_data/subjects/"

AddStudent() {
    read -p "Enter your student id: " std_id
	case $std_id in
     	 +([0-9])) ;;
        *) echo "Error: Must enter digits  only."; return ;;
    esac
    if [[ -f "$std_data_dir/$std_id.stu" ]]; then
        echo "Error: Student with ID '$std_id' already exists."
        return
    fi
	read -p "Enter Your Student Name: " std_name
	case $std_name in 
		[A-z]+([A-z -_.])) ;;
		*) echo "Error: Must start Letters only."; return ;;
    esac
	read -p "Enter Your Student Email: " std_Email
	case $std_Email in 
		[A-z]+([A-z0-9-_.])@([@])+([A-z])@([.])+([A-z])) ;;
		*) echo "Error: Must Start with letter then @ mail . Domain letters only."; return ;;
    esac
    read -p "Enter your student year: " std_year
    case $std_year in
       +([1-6])) ;;
        *) echo "Error: Must enter digits  only."; return ;;
esac
	echo "$std_name:$std_Email:$std_year" > "$std_data_dir/$std_id.stu"

}
ManageStudents() {
    while true; do
        echo ""
        echo "*** ManageStudents ***"

        select choice in \
		"▸AddStudent" \
		"▸ListStudents"\
		"▸UpdateStudent"\
		"▸DeleteStudent" \
		"▸Exit"
        do
            case $REPLY in
                1) AddStudent ;;
                2) ListStudents ;;
                3) UpdateStudent ;;
                4) DeleteStudent ;;
                5) mainmenu ;;
                *)
                    echo "Invalid option"
                    ;;
            esac
            break
        done
    done
}

ManageSubjects() {
    while true; do
        echo ""
        echo "*** ManageSubjects ***"

        select choice in \
		"▸AddSubject" \
		"▸ListSubjects" \
		"▸UpdateSubject" \
		"▸DeleteSubject" \
		"▸Exit"
        do
            case $REPLY in
                1) AddSubject ;;
                2) ListSubjects ;;
                3) UpdateSubject ;;
                4) DeleteSubject ;;
                5) mainmenu ;;
                *)
                    echo "Invalid option"
                    ;;
            esac
            break
        done
    done
}


ManageGrades() {
    while true; do
        echo ""
        echo "*** ManageGrades ***"

        select choice in \
		"▸AssignGradetoStudent"\
		"▸UpdateExistingGrade"\
		"▸DeleteaGrade"\
		"▸ViewGradesbySubject"\
		"▸ViewGradesbyStudent"\
		"▸Exit"
        do
            case $REPLY in
                1) AssignGradetoStudent ;;
                2) UpdateExistingGrade ;;
                3) DeleteaGrade ;;
                4) ViewGradesbySubject ;;
                5) ViewGradesbyStudent ;;
                6) mainmenu ;;
                *)
                    echo "Invalid option"
                    ;;
            esac
            break
        done
    done
}


Reports_Statistics() {
    while true; do
        echo ""
        echo "*** Reports&Statistics ***"

        select choice in \
		"▸StudentTranscript+GPA"\
		"▸SubjectStatistics"\
		"▸TopStudentsbyGPA"\
		"▸FailingStudentsReport"\
		"▸FullGradeMatrix"\
		"▸Exit"
        do
            case $REPLY in
                1) StudentTranscript ;;
                2) SubjectStatistics ;;
                3) TopStudentsbyGPA ;;
                4) FailingStudentsReport ;;
                5) FullGradeMatrix ;;
                6) mainmenu ;;
                *)
                    echo "Invalid option"
                    ;;
            esac
            break
        done
    done
}


mainmenu(){
while true; do
    echo ""
    echo " ---- Bash SGMS ----"

	select choice in \
		"▸ManageStudents" \
		"▸ManageSubjects" \
		"▸ManageGrades" \
		"▸Reports&Statistics" \
		"▸Exit"
	do
		case $REPLY in 
	1)  	 ManageStudents ;;
	2)	 ManageSubjects ;;
	3) 	 ManageGrades ;;
	4)	 Reports_Statistics ;;
	5)	 exit ;;
		
	*)
		echo "Invalid option"
	esac

	done

done
}
mainmenu
