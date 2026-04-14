#! /usr/bin/bash
shopt -s extglob

std_data_dir="sgms_data/students"
grade_data_dir="sgms_data/grades"
subjects_data_dir="sgms_data/subjects"

	
AddSubject() {
    read -p "Enter your subject code: " sub_code
	if [[ ! $sub_code =~ ^[A-Za-z]{2,5}[0-9]{2,4}$ ]]; then 
		echo "Enter your subject 2–5 letters + 2–4 digits e.g .CS101,MATH203";
		return
	fi


	if [[ -f "$subjects_data_dir/$sub_code.sub" ]]; then
		echo "Error: Subject with Code '$sub_code' already exists."
		return
	fi
	read -p "Enter Your Subject Name: " sub_name
	case $sub_name in 
		[A-z]+([A-z -_.]))
		 if [[ ${#sub_name} -gt 20 ]]; then
		     	 echo "Error: Must enter up to 20 letter with -_. only."
		     	 return
	     	 fi
		 ;;
		*) echo "Error: Must start Letters only up to 20 only."; return ;;
    	esac
 
	
	read -p "Enter your Subject credit[1-6]: " sub_credit
	case $sub_credit in
		@([1-6])) ;;
		*) echo "Error: Must enter integer from 1 to 6  only."; return ;;
	esac
	echo "Subject $sub_name has been Created with CODE $sub_code.";
	local newfile="$subjects_data_dir/$sub_code.sub";
	echo $sub_code >> $newfile;echo $sub_name >> $newfile;echo $std_Email >> $sub_credit


}

DeleteSubject(){
 	read -p "Enter your Subject code: " sub_code
 	
	if [[ ! $sub_code =~ ^[A-Za-z]{2,5}[0-9]{2,4}$ ]]; then 
		echo "Enter your subject 2–5 letters + 2–4 digits e.g .CS101,MATH203";
		return
	fi
    	if [[ -f "$subjects_data_dir/$sub_code.sub" ]]; then
		read -p "Are you sure you want to delete Subject with code = $sub_code (y/n): " accept
		case $accept in 
		[Yy])
			rm -r "$subjects_data_dir/$sub_code.sub";
			rm -r "$grade_data_dir/$sub_code.grd";
			echo "Subject with code $sub_code has been with it's grades deleted"; ;;

		[Nn]) echo "Thanks"; return ;; 
		*) echo "invalid option" ;;
		esac
        else
	  echo "Error: Student with ID '$std_id' already exists."
        fi
}
#****************************************************************************************************************************************

AddStudent() {

	std_id="-1";
	while [ ${std_id} == "-1" ]; do
  	read -p "Enter your student id: " std_id
	case $std_id in
     	 +([0-9]))
	 if [[ ${#std_id} -gt 10 ]]; then
	 	std_id="-1";
	 	 
	     	 echo "Error: Must enter up to 10 digits only.";
	     	 continue ;
     	 fi
     	 ;;
        *)  echo "Error: Must enter up to 10 digits only.";std_id="-1"; continue   ;;
    esac

     echo ${std_id};
	if [[ -f "$std_data_dir/$std_id.stu" ]]; then
		
		echo "Error: Student with ID '$std_id' already exists.";std_id="-1";
		continue  
	fi
	done;
	read -p "Enter Your Student Name: " std_name
	case $std_name in 
		[A-z]+([A-z -_.]))
		 if [[ ${#std_name} -gt 20 ]]; then
		     	 echo "Error: Must enter up to 20 letter with-_. only."
		     	 return
	     	 fi
		 ;;
		*) echo "Error: Must start Letters only up to 20 only."; return ;;
    	esac
 
	read -p "Enter Your Student Email: " std_Email
	case $std_Email in 
		[A-z]+([A-z0-9-_.])@([@])+([A-z])@([.])+([A-z])) ;;
		*) echo "Error: Must Start with letter then @ mail . Domain letters only."; return ;;
	esac
	read -p "Enter your student year[1-6]: " std_year
	case $std_year in
		@([1-6])) ;;
		*) echo "Error: Must enter from 1 to 6   only."; return ;;
	esac
	echo "Student $std_name has been Created with ID $std_id.";
	local newfile="$std_data_dir/$std_id.stu";
	echo $std_id >> $newfile;echo $std_name >> $newfile;echo $std_Email >> $newfile; echo $std_year > $newfile; 


}
DeleteStudent(){
 	read -p "Enter your student id: " std_id
 	
	case $std_id in
     	 +([0-9])) ;;
      	  *) echo "Error: Must enter digits  only."; return ;;
    	esac
    	if [[ -f "$std_data_dir/$std_id.stu" ]]; then
		read -p "Are you sure you want to delete student with id = $std_id (y/n): " accept
		case $accept in 
		[Yy])
			rm -r "$std_data_dir/$std_id.stu";
			echo "Student with id $std_id has been deleted"; ;;
			#still more delete for grades later.
		[Nn]) echo "Thanks"; return ;; 
		*) echo "invalid option" ;;
		esac
        else
	  echo "Error: Student with ID '$std_id' already exists."
        fi
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
