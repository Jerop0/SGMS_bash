#! /usr/bin/bash
shopt -s extglob



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

ManageGrades() {
    while true; do
        echo ""
        echo "*** ManageGrades ***"

        select choice in \
		"▸AssignGradetoStudent" \
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
