#! /usr/bin/bash
shopt -s extglob

std_data_dir="sgms_data/students"
grade_data_dir="sgms_data/grades"
subjects_data_dir="sgms_data/subjects"


UpdateSubject() {
	read -p "Enter subject code to update: " sub_id
	if [[ ! -f "$subjects_data_dir/$sub_id.sub" ]]
	then
		echo "Subject code doesn't exist"
		return
	fi
	old_name=$(sed -n '2p' $subjects_data_dir/$sub_id.sub)
	old_hours=$(sed -n '3p' $subjects_data_dir/$sub_id.sub)
	echo "Current: $old_name | $old_hours"
	select choice in \
	"▸Name" \
	"▸Hours" \
	"▸Exit"
	do
		case $REPLY in
		1)
			while true
			do
				read -p "Enter new name: " new_name
				case $new_name in 
					#addname validation
					*) break ;;
				esac
			done
			sed -i "2s/.*/$new_name/" $subjects_data_dir/$sub_id.sub;;
		2)
			while true
			do
				read -p "Enter new hours (1-6): " new_hours
				case $new_hours in
					+([1-6])) break ;;
					*) echo "Hours must be 1 to 6." ;;
				esac
			done
			sed -i "3s/.*/$new_hours/" $subjects_data_dir/$sub_id.sub;;
		3) return ;;
		*) echo "Invalid option" ;;
		esac
		break
	done
}

ListSubjects() {
	echo "Code | Name | Credits"
	for f in $(ls $subjects_data_dir)
	do
		code=$(sed -n '1p' $subjects_data_dir/$f)
		name=$(sed -n '2p' $subjects_data_dir/$f)
		cred=$(sed -n '3p' $subjects_data_dir/$f)
		echo "$code | $name | $cred"
	done
}

	
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


UpdateStudent() {
	while true
	do
		read -p "Enter student id to update: " std_id
		case $std_id in
			+([0-9]))
				if [[ ! -f "$std_data_dir/$std_id.stu" ]]
				then
					echo "";
					return
				else
					break
				fi
				;;
			*) echo "Error: Must enter digits  only." ;;
		esac
	done
	old_name=$(sed -n '2p' $std_data_dir/$std_id.stu)
	old_email=$(sed -n '3p' $std_data_dir/$std_id.stu)
	old_year=$(sed -n '4p' $std_data_dir/$std_id.stu)
	echo "Current: $old_name | $old_email | $old_year"
	select choice in \
		"▸Name" \
		"▸Email" \
		"▸Year" \
		"▸Exit"
	do
		case $REPLY in
		1)
			while true
			do
				read -p "Enter new name: " new_name
				case $new_name in 
					"") echo "Error: Name cannot be empty." ;;
					*) break ;;
				esac
			done
			sed -i "2s/.*/$new_name/" $std_data_dir/$std_id.stu;;
		2)
			while true
			do
				read -p "Enter new email: " new_email
				case $new_email in 
					[A-z]+([A-z0-9-_.])@([@])+([A-z])@([.])+([A-z])) break;;
					*) echo "Error: Must be user@domain.ext format.";;
				esac
			done
			sed -i "3s/.*/$new_email/" $std_data_dir/$std_id.stu;;
		3)
			while true
			do
				read -p "Enter new year: " new_year
				case $new_year in
					+([1-6])) break ;;
					*) echo "Error: Year must be 1 to 6." ;;
				esac
			done
			sed -i "4s/.*/$new_year/" $std_data_dir/$std_id.stu ;;
		4) return ;;
		*) echo "Invalid option" ;;
		esac
		break
	done
}

ListStudents() {

	echo "ID | Name | Email | Year"

	for f in $(ls $std_data_dir) do
		sid=$(sed -n '1p' $std_data_dir/$f)
		sname=$(sed -n '2p' $std_data_dir/$f)
		semail=$(sed -n '3p' $std_data_dir/$f)
		syear=$(sed -n '4p' $std_data_dir/$f)
		echo "$sid | $sname | $semail | $syear"
	done
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
