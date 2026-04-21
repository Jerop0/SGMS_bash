#! /usr/bin/bash
shopt -s extglob

std_data_dir="sgms_data/students"
grade_data_dir="sgms_data/grades"
subjects_data_dir="sgms_data/subjects"




#-----------------------------------

StudentTranscript()
{ 
	while true; do

		read -p "Enter your student id: " std_id
	
		case $std_id in
			 +([0-9]))
			if [[ ${#std_id} -gt 10 ]]; then
				 echo "Error: Must enter up to 10 digits only."
				continue;
			fi;;
			*)  echo "Error: Must enter up to 10 digits only."; continue   ;;
		esac
		if [[ -f "$std_data_dir/$std_id.stu" ]]; then
			file="$std_data_dir/$std_id.stu"
			old_id=$(sed -n '1p' $file)
			old_name=$(sed -n '2p' $file)
			old_email=$(sed -n '3p' $file)
			old_year=$(sed -n '4p' $file)

			echo "stdid=$old_id";echo "studentName:$old_name" ;echo "Student-Email:$old_email";echo "Year:$old_year";
			echo "subject_name | CODE | Credits | score | grade | GPA"
			for file in $(ls $grade_data_dir) 
			do

				degree=$(sed -n "/^${old_id}:/p" "$grade_data_dir/$file")

				if [[ "$degree" ]]; then
					score=$(echo "$degree" | cut -d: -f2)
					std_id=$(echo "$degree" | cut -d: -f1)
					GPA=$(getGPA "$score")
					letter=`getletter $score $sub_code`
					sub_code=${file::-4}
					sub_name=$(sed -n '2p' $subjects_data_dir/$sub_code.sub)
					sub_hours=$(sed -n '3p' $subjects_data_dir/$sub_code.sub)
					echo " $sub_name | $sub_code | $sub_hours | $score | ${letter:0:2} | $GPA"
					
				fi
				
			done
			break;
		else
			echo "Error: Student with ID '$std_id' doesn't already exists.";
			continue
		fi;
	done;
	
}


TotalGPA(){

	old_id=$(sed -n '1p' $1)
	old_name=$(sed -n '2p' $1)
	old_email=$(sed -n '3p' $1)
	old_year=$(sed -n '4p' $1)
	local  totalGPA=0
	local  totalsubs=0
	for file in $(ls $grade_data_dir) 
	do
		degree=$(sed -n "/^${old_id}:/p" "$grade_data_dir/$file")

		if [[ -n "$degree" ]]; then
			totalsubs=$(($totalsubs + 1))

			score=$(echo "$degree" | cut -d: -f2)
			std_id=$(echo "$degree" | cut -d: -f1)
			GPA=$(getGPA $score)
			

			totalGPA=$(awk -v total="$totalGPA" -v GP="$GPA" 'BEGIN {total= GP + total;print total} ')

			letter=`getletter $score $sub_code`
			sub_code=${file::-4}
			sub_name=$(sed -n '2p' $subjects_data_dir/$sub_code.sub)
			sub_hours=$(sed -n '3p' $subjects_data_dir/$sub_code.sub)

		fi
	
		
	done
	if [[ $totalsubs -gt 0 ]];then
		##x=$( awk -v total="$totalGPA" -v hours="$totalsubs" 'BEGIN { print total} ')
		echo "$totalGPA"
	else
		echo "0.0"
	fi
}

SubjectStatistics(){
while true;do
		read -p "Enter your subject code: " sub_code
		if [[ ! $sub_code =~ ^[A-Za-z]{2,5}[0-9]{2,4}$ ]]; then 
			echo "Enter your subject 2–5 letters + 2–4 digits e.g .CS101,MATH203";
			continue
		fi
		if [[ -f "$subjects_data_dir/$sub_code.sub" ]]; then
			break;
		else
			echo "Error: Subject with Code '$sub_code' already exists.";
			continue
		fi
	done;
	if [[ -f "$subjects_data_dir/$sub_code.sub" ]]; then
			file="$grade_data_dir/$sub_code.grd"
			echo "NumOfstudents:Grade (A+): $( sed -n "/:A+$/p" $file  | wc -l) "
			echo "NumOfstudents:Grade (A ): $( sed -n "/:A $/p" $file  | wc -l) "
			echo "NumOfstudents:Grade (A-): $( sed -n "/:A-$/p" $file  | wc -l) "
			echo "NumOfstudents:Grade (B+): $( sed -n "/:B+$/p" $file  | wc -l) "
			echo "NumOfstudents:Grade (B ): $( sed -n "/:B $/p" $file  | wc -l) "
			echo "NumOfstudents:Grade (B-): $( sed -n "/:B-$/p" $file  | wc -l) "
			echo "NumOfstudents:Grade (C+): $( sed -n "/:C+$/p" $file  | wc -l) "
			echo "NumOfstudents:Grade (C ): $( sed -n "/:C $/p" $file  | wc -l) "
			echo "NumOfstudents:Grade (C-): $( sed -n "/:C-$/p" $file  | wc -l) "
			echo "NumOfstudents:Grade (D ): $( sed -n "/:D $/p" $file  | wc -l) "
			echo "NumOfstudents:Grade (F ): $( sed -n "/:F $/p" $file  | wc -l) "
		fi


}
## stdid.stuc  1 code 2 name 
### subid.sub  1 code 2 name 
### subid.grd 1 code 2 score 3 letter. 
### 
TopStudentsbyGPA() {
    local tmp="/tmp/topstudents.$$"
    : > "$tmp"   

    local file sid sname gpa line_no

    for file in "$std_data_dir"/*.stu; do
        [[ -f "$file" ]] || continue
        sid=$(sed -n '1p' "$file")
        sname=$(sed -n '2p' "$file")
        gpa=$(TotalGPA "$file")

        line_no=$(awk -F: -v g="$gpa" '$3 < g { print NR; exit }' "$tmp")

        if [[ -z "$line_no" ]]; then

            echo "${sname}:${sid}:${gpa}" >> "$tmp"
        else

            sed -i "${line_no}i ${sname}:${sid}:${gpa}" "$tmp"
        fi
    done

    echo "Rank | Name | ID | GPA"
    awk -F: '{ printf "%4d | %s | %s | %s\n", NR, $1, $2, $3 }' "$tmp"

    rm -f "$tmp"
}

FailingStudentsReport(){
	for file in $(ls $grade_data_dir) 
	do
		failstds=$(sed -n "/:F $/p" "$grade_data_dir/$file") 
		if [[ ${#failstds} > 1 ]]; then 
		for degree in $failstds
		do		
		if [[  "$degree" ]]; then
					score=$(echo "$degree" | cut -d: -f2)
					std_id=$(echo "$degree" | cut -d: -f1)
					GPA=$(getGPA $score)
			
			sub_code=${file::-4}
			letter=`getletter $score $sub_code`
			sub_name=$(sed -n '2p' $subjects_data_dir/$sub_code.sub)
			std_name=$(sed -n '2p' "$std_data_dir/$std_id.stu")
			
				if [[ ${letter:3} -gt 0 ]] ; then
					sed -i "${letter:3}i ${std_id}:${score}:${letter:0:2}" "$grade_data_dir/$sub_code.grd"
				else
					sed -i "1i ${std_id}:${score}:${letter:0:2}" "$grade_data_dir/$sub_code.grd"
				fi

		fi
		done
		fi
	done
	
}
FullGradeMatrix(){
	row="ID | STD_NAME | STd_YEAR "
	for file in $(ls $subjects_data_dir/*) 
	do
		sub_name=$(sed -n '2p' $file)

		row="$row | $sub_name"
	done;
	echo $row;
	for file in $(ls $std_data_dir/*) 
	do
	STD_id=$(sed -n '1p' $file)
	STD_name=$(sed -n '2p' $file)
	STD_email=$(sed -n '3p' $file)
	STD_year=$(sed -n '4p' $file)
	

	sub_row="$STD_id | $STD_name | $STD_year"
	for file in $(ls $grade_data_dir) 
	do
		degree=$(sed -n "/^${std_id}:/p" "$grade_data_dir/$file")
		
		if [[ $degree ]]; then

			score=$(echo "$degree" | cut -d: -f2)
			std_id=$(echo "$degree" | cut -d: -f1)
			GPA=$(getGPA $score)
	
			local letter=`getletter $score $sub_code`

			sub_code=${file::-4}
			sub_name=$(sed -n '2p' $subjects_data_dir/$sub_code.sub)
			sub_hours=$(sed -n '3p' $subjects_data_dir/$sub_code.sub)
			sub_row="$sub_row | ${letter:0:2}  "
		else 
		 sub_row="$sub_row |  "
		fi
	done
		
	echo $sub_row;	
		
		
	done
	
}

#------------------
AssignGradetoStudent() {
	while true; do
		read -p "Enter your student id: " std_id
		case $std_id in
			 +([0-9]))
			if [[ ${#std_id} -gt 10 ]]; then
				 echo "Error: Must enter up to 10 digits only.";
				continue
			fi;;
			*)  echo "Error: Must enter up to 10 digits only."; continue   ;;
		esac
		if [[ -f "$std_data_dir/$std_id.stu" ]]; then
			break;  
		else
			echo "Error: Student with ID '$std_id' already exists.";
			continue
		fi;
	done;
	while true;do
		read -p "Enter your subject code: " sub_code
		if [[ ! $sub_code =~ ^[A-Za-z]{2,5}[0-9]{2,4}$ ]]; then 
			echo "Enter your subject 2–5 letters + 2–4 digits e.g .CS101,MATH203";
			continue
		fi
		if [[ -f "$subjects_data_dir/$sub_code.sub" ]]; then
			break;
		else
			echo "Error: Subject with Code '$sub_code' already exists.";
			continue
		fi
	done;
		if [[ $(sed -n "/^$std_id/p" "$grade_data_dir/$sub_code.grd") ]]; then
			echo "Error: There is a Grade for this STD.";
			return;
		else
			while true; do
			read -p "Enter your score: " score
			if [[  ! $score =~ ^[0-9]{1,3}[.][0-9]$  ]]; then 
				echo "Enter your score in range of 0.0 |  100.0" ; 
				continue;
			else
			
				if [[ ${#score} -eq 5 && ${score:0:3} -gt 100 ]]; then 
					echo "Enter your score in range of 0.0 |  100.0" ;  
				continue;
				fi 
				local letter=`getletter "$score" "$sub_code"`;
				if [[ ${letter:3} -gt 0 ]] ; then
					sed -i "${letter:3}i ${std_id}:${score}:${letter:0:2}" "$grade_data_dir/$sub_code.grd"
				else
					echo "${std_id}:${score}:${letter:0:2}"  >>"$grade_data_dir/$sub_code.grd"
				fi
				break;
			fi
			done;
		fi;
}
DeleteaGrade(){
	while true; do
		read -p "Enter your student id: " std_id
		case $std_id in
			 +([0-9]))
			if [[ ${#std_id} -gt 10 ]]; then
				 echo "Error: Must enter up to 10 digits only.";

			fi;;
			*)  echo "Error: Must enter up to 10 digits only."; continue   ;;
		esac
		if [[ -f "$std_data_dir/$std_id.stu" ]]; then
			break;  
		else
			echo "Error: Student with ID '$std_id' already exists.";

		fi;
	done;
	while true;do
		read -p "Enter your subject code: " sub_code
		if [[ ! $sub_code =~ ^[A-Za-z]{2,5}[0-9]{2,4}$ ]]; then 
			echo "Enter your subject 2–5 letters + 2–4 digits e.g .CS101,MATH203";
			continue
		fi
		if [[ -f "$subjects_data_dir/$sub_code.sub" ]]; then
			break;
		else
			echo "Error: Subject with Code '$sub_code' already exists.";
		fi
	done;
	if [[ $(sed -n "/^$std_id/p" "$grade_data_dir/$sub_code.grd") ]]; then
			sed -i "/^$std_id/d" "$grade_data_dir/$sub_code.grd"
			echo "Deleted sucessfully"
			
		else
			echo "Error: There is a Grade for this STD.";
			return;
	fi
	
}
UpdateExistingGrade(){
	while true; do
		read -p "Enter your student id: " std_id
		case $std_id in
			 +([0-9]))
			if [[ ${#std_id} -gt 10 ]]; then
				 echo "Error: Must enter up to 10 digits only.";
				continue
			fi;;
			*)  echo "Error: Must enter up to 10 digits only."; continue   ;;
		esac
		if [[ -f "$std_data_dir/$std_id.stu" ]]; then
			break;  
		else
			echo "Error: Student with ID '$std_id' already exists.";
			continue	
		fi;
	done;
	while true;do
		read -p "Enter your subject code: " sub_code
		if [[ ! $sub_code =~ ^[A-Za-z]{2,5}[0-9]{2,4}$ ]]; then 
			echo "Enter your subject 2–5 letters + 2–4 digits e.g .CS101,MATH203";
			continue
		fi
		if [[ -f "$subjects_data_dir/$sub_code.sub" ]]; then
			break;
		else
			echo "Error: Subject with Code '$sub_code' already exists.";
			continue
		fi
	done;
	
		if [[ ! $(sed -n "/^$std_id:/p" "$grade_data_dir/$sub_code.grd") ]]; then
			echo "Error: There is a Grade for this STD.";
			return;
		else
			while true; do
			read -p "Enter your new score: " new_score
			if [[  ! $new_score =~ ^[0-9]{1,3}[.][0-9]$  ]]; then 
				echo "Enter your score in range of 0.0 |  100.0" ; 
				continue;
			else
			
				if [[ ${#new_score} -eq 5 && ${new_score:0:3} -gt 100 ]]; then 
					echo "Enter your score in range of 0.0 |  100.0" ;  
					continue;
				fi 
				sed -i "/^$std_id:/d" "$grade_data_dir/$sub_code.grd"
				local letter=`getletter "${new_score}" "$sub_code"`;
				cat "$grade_data_dir/$sub_code.grd";
				echo $letter;
				if [[ ${letter:3} -gt 0 ]] ; then
					sed -i "${letter:3}i ${std_id}:${new_score}:${letter:0:2}" "$grade_data_dir/$sub_code.grd"
				else
					sed -i "1i ${std_id}:${new_score}:${letter:0:2}" "$grade_data_dir/$sub_code.grd"
				fi

				break;
			fi
			

			
			done;
		fi;

	
}
ViewGradesbySubject(){
	while true;do
		read -p "Enter your subject code: " sub_code
		if [[ ! $sub_code =~ ^[A-Za-z]{2,5}[0-9]{2,4}$ ]]; then 
			echo "Enter your subject 2–5 letters + 2–4 digits e.g .CS101,MATH203";
			continue;
		fi
		if [[ -f "$subjects_data_dir/$sub_code.sub" ]]; then
			break
		else
			echo "Error: Subject with Code '$sub_code' already exists.";
			continue
		fi
	done;
	
	awk -F : 'BEGIN{print ("Std:Score:Grade")} {print $0}' "$grade_data_dir/$sub_code.grd"
}
ViewGradesbyStudent(){
	while true; do
		read -p "Enter your student id: " std_id
		case $std_id in
			 +([0-9]))
			if [[ ${#std_id} -gt 10 ]]; then
				 echo "Error: Must enter up to 10 digits only.";
				continue;
			fi;;
			*)  echo "Error: Must enter up to 10 digits only."; continue   ;;
		esac
		if [[ -f "$std_data_dir/$std_id.stu" ]]; then
			file="$std_data_dir/$std_id.stu"
			old_id=$(sed -n '1p' $file)
			old_name=$(sed -n '2p' $file)
			old_email=$(sed -n '3p' $file)
			old_year=$(sed -n '4p' $file)

			echo "stdid=$old_id";echo "studentName:$old_name" ;echo "Student-Email:$old_email";echo "Year:$old_year";
			echo "subject_name | CODE | Credits | score | grade | GPA"
			for file in $(ls $grade_data_dir) 
			do

				degree=$(sed -n "/^${old_id}:/p" "$grade_data_dir/$file")

				if [[ "$degree" ]]; then
					score=$(echo "$degree" | cut -d: -f2)
					std_id=$(echo "$degree" | cut -d: -f1)
					GPA=$(getGPA $score)
					
					letter=`getletter $score $sub_code`
					sub_code=${file::-4}
					sub_name=$(sed -n '2p' $subjects_data_dir/$sub_code.sub)
					sub_hours=$(sed -n '3p' $subjects_data_dir/$sub_code.sub)
					echo " $sub_name | $sub_code | $sub_hours | $score | ${letter:0:2} | $GPA"
					
				fi
				
			done
			break;
		else
			echo "Error: Student with ID '$std_id' doesn't already exists.";
			continue
		fi;
	done;
	

			
}

getletter(){
	x=$1
	
	if [[ ${#x} == 5 ]]; then 
		echo "A+|1"
	elif [[ ${#x} == 4 ]]; then 
		score=${x:0:2}

		if [[ $score -ge 90  ]]; then 
			linenumber=`getline $score $2`	
			echo "A+|$linenumber"
		elif [[ $score -ge 85  ]]; then 
			linenumber=`getline $score $2`	
			echo "A |$linenumber"
		elif [[ $score -ge 80  ]]; then 
			linenumber=`getline $score $2`	
			echo "A-|$linenumber"
		elif [[ $score -ge 75  ]]; then 
			linenumber=`getline $score $2`	
			echo "B+|$linenumber"
		elif [[ $score -ge 70  ]]; then 
			linenumber=`getline $score $2`	
			echo "B |$linenumber"
		elif [[ $score -ge 65  ]]; then 
			linenumber=`getline $score $2`	
			echo "B-|$linenumber"
		elif [[ $score -ge 60  ]]; then 
			linenumber=`getline $score $2`	
			echo "C+|$linenumber"
		elif [[ $score -ge 55  ]]; then 
			linenumber=`getline $score $2`	
			echo "C |$linenumber"
		elif [[ $score -ge 50  ]]; then 
			linenumber=`getline $score $2`	
			echo "C-|$linenumber"
		elif [[ $score -ge 45  ]]; then 
			linenumber=`getline $score $2`	
			echo "D |$linenumber"
		elif [[ $score -lt 45  ]]; then 

			linenumber=`getline $score $2`	
			
			echo "F |$linenumber"
		fi
	else 
		echo "F |$";
	fi
}

getGPA(){
	x=$1
	
	if [[ ${#x} == 5 ]]; then 
		echo "4.0"
	elif [[ ${#x} == 4 ]]; then 
		score=${x:0:2}

		if [[ $score -ge 90  ]]; then 
			echo "4.0"
		elif [[ $score -ge 85  ]]; then 
			echo "3.7"
		elif [[ score -ge 80  ]]; then 
			echo "3.7"
		elif [[ $score -ge 75  ]]; then 
			echo "3.3"
		elif [[ $score -ge 70  ]]; then 
			echo "3.0"
		elif [[ $score -ge 65  ]]; then 
			echo "2.7"
		elif [[ $score -ge 60  ]]; then 
			echo "2.3"
		elif [[ $score -ge 55  ]]; then 
			echo "2"
		elif [[ $score -ge 50  ]]; then 
			echo "1.7"
		elif [[ $score -ge 45  ]]; then 
			echo "1.0"
		elif [[ $score -lt 45  ]]; then 
			echo "0.0"
		fi
	else 
		echo "0.0"
	fi
}

getline(){
	
	awk -F : -v x="$1" 'BEGIN{found=0}{if ( x > $2 ) {found=NR}} END {
if (found==0) print NF+2 
else  print found }' "$grade_data_dir/$2.grd"  ;
} 
##Refix.
UpdateSubject() {
	read -p "Enter your subject code: " sub_code
	if [[ ! $sub_code =~ ^[A-Za-z]{2,5}[0-9]{2,4}$ ]]; then 
		echo "Enter your subject 2–5 letters + 2–4 digits e.g .CS101,MATH203";
		return
	fi
	file="$subjects_data_dir/$sub_code.sub"
	if [[ ! -f "$file" ]]
	then
		echo "Subject code doesn't exist"
		return
	fi
	old_code=$(sed -n '1p' $file)
	old_name=$(sed -n '2p' $file)
	old_hours=$(sed -n '3p' $file)
	echo "Choose What you want to update?";
	echo "$old_code         $old_name           $old_hours"
	select choice in \
	"▸code" \
	"▸Name" \
	"▸Hours" \
	"▸Exit"
	do
		case $REPLY in
		1) 	while true 
			do
			read -p "Enter New code " new_code
			
			if [[ ! $new_code =~ ^[A-Za-z]{2,5}[0-9]{2,4}$ ]]; then 
				echo "Enter your subject 2–5 letters + 2–4 digits e.g .CS101,MATH203";
			else
				sed -i "1s/$old_code/$new_code/" $file;
				mv $subjects_data_dir/$old_code.sub $subjects_data_dir/$new_code.sub;
				mv $grade_data_dir/$old_code.grd $grade_data_dir/$new_code.grd;
				
				old_code=$new_code
				break;			
			fi
			 
			done;;
		2)
			while true
			do
				read -p "Enter new name: " new_name
				case $new_name in 
				[A-z]+([A-z -_.]))
				 if [[ ${#new_name} -gt 20 ]]; then
						 echo "Error: Must enter up to 20 letter with -_. only."
						 continue
					 fi;;
				*) break;;
				esac
	
			done
			sed -i "2s/$old_name/$new_name/" $file;;
		3)
			while true
			do
				read -p "Enter new hours (1-6): " new_hours
				case $new_hours in
					@([1-6])) break ;;
					*) echo "Hours must be 1 to 6." ;;
				esac
			done
			sed -i "3s/$old_hours/$new_hours/" $subjects_data_dir/$sub_id.sub;;
		4) return ;;
		*) echo "Invalid option" ;;
		esac
		break
	done
}

ListSubjects() {
	echo "Code         Name         Credits"
	for file in $(ls $subjects_data_dir/*)
	do
		code=$(sed -n '1p' $file)
		name=$(sed -n '2p' $file)
		cred=$(sed -n '3p' $file)
		echo "$code         $name         $cred"
	done
}

	
AddSubject() {
	while true;do
	read -p "Enter your subject code: " sub_code
	if [[ ! $sub_code =~ ^[A-Za-z]{2,5}[0-9]{2,4}$ ]]; then 
		echo "Enter your subject 2–5 letters + 2–4 digits e.g .CS101,MATH203";
		continue;
	fi
	if [[ -f "$subjects_data_dir/$sub_code.sub" ]]; then
		echo "Error: Subject with Code '$sub_code' already exists."
		continue;
	else
		break;
	fi
	done
	read -p "Enter Your Subject Name: " sub_name
	case $sub_name in 
		[A-z]+([A-z -_.]))
		 if [[ ${#sub_name} -gt 20 ]]; then
		     	 echo "Error: Must enter up to 20 letter with -_. only."
		     	 return
	     	 fi;;
		*) echo "Error: Must start Letters only up to 20 only."; return ;;
    	esac
 
	
	read -p "Enter your Subject credit[1-6]: " sub_credit
	case $sub_credit in
		@([1-6])) ;;
		*) echo "Error: Must enter integer from 1 to 6  only."; return ;;
	esac
	echo "Subject $sub_name has been Created with CODE $sub_code.";
	echo "" >> "$grade_data_dir/$sub_code.grd";
	local newfile="$subjects_data_dir/$sub_code.sub";
	
	echo $sub_code >> $newfile;echo $sub_name >> $newfile;echo $sub_credit >> $newfile


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


	while true; do
  	read -p "Enter your student id: " std_id
	case $std_id in
     	 +([0-9]))
	 if [[ ${#std_id} -gt 10 ]]; then
	     	 echo "Error: Must enter up to 10 digits only.";
	     	 continue ;
	     
     	 fi
     	
     	 ;;
        *)  echo "Error: Must enter up to 10 digits only."; continue   ;;
    esac

  
	if [[ -f "$std_data_dir/$std_id.stu" ]]; then
		echo "Error: Student with ID '$std_id' already exists.";
		continue  
	else
		break;
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
	 newfile="$std_data_dir/$std_id.stu";
	echo $std_id >> $newfile;echo $std_name >> $newfile;echo $std_Email >> $newfile; echo $std_year >> $newfile; 


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
			echo "Student with id $std_id has been deleted"; 
			for file in $(ls "$grade_data_dir/*") 
			do
				sed -i "/^$std_id/d" $file
			done
			;;
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
					echo "invalid_id";	 continue
				else
					break
				fi
				;;
			*) echo "Error: Must enter digits  only." ;;
		esac
	done
	file="$std_data_dir/$std_id.stu"
	old_id=$(sed -n '1p' $file)
	old_name=$(sed -n '2p' $file)
	old_email=$(sed -n '3p' $file)
	old_year=$(sed -n '4p' $file)
	echo "$old_id $old_name | $old_email | $old_year"
	select choice in \
		"▸id" \
		"▸Name" \
		"▸Email" \
		"▸Year" \
		"▸Exit"
	do
		case $REPLY in
		1) 
		while true; do
		read -p "Enter your student id: " new_id
			case $new_id in
				 +([0-9]))
			 if [[ ${#new_id} -gt 10 ]]; then
				
				 
					 echo "Error: Must enter up to 10 digits only.";
					 continue ;
				 fi
				 ;;
				*)  echo "Error: Must enter up to 10 digits only."; continue   ;;
			esac

     echo ${new_id};
	if [[ -f "$std_data_dir/$new_id.stu" ]]; then
		
		echo "Error: Student update to ID '$new_id' already exists.";
		continue  
	else
		mv $file "$std_data_dir/$new_id.stu"
			for file in $(ls $grade_data_dir/*)
			do
				sed -i "s/^$old_id/$new_id/" $file;
			done
		
	break;
	fi
		done;;
		2)
			while true
			do
				read -p "Enter new name: " new_name
				case $new_name in 
					"") echo "Error: Name cannot be empty." ;;
					*) break ;;
				esac
			done
			sed -i "2s/$old_name/$new_name/" $std_data_dir/$std_id.stu;;
		3)
			while true
			do
				read -p "Enter new email: " new_email
				case $new_email in 
					[A-z]+([A-z0-9-_.])@([@])+([A-z])@([.])+([A-z])) break;;
					*) echo "Error: Must be user@domain.ext format.";;
				esac
			done
			sed -i "3s/$old_email/$new_email/" $std_data_dir/$std_id.stu;;
		4)
			while true
			do
				read -p "Enter new year: " new_year
				case $new_year in
					+([1-6])) break ;;
					*) echo "Error: Year must be 1 to 6." ;;
				esac
			done
			sed -i "4s/$old_year/$new_year/" $std_data_dir/$std_id.stu ;;
			
		5) return ;;
		*) echo "Invalid option" ;;
		esac
		break
	done
}

ListStudents() {

	echo "ID | Name | Email | Year"

	for file in $(ls $std_data_dir/*) 
	do
		sid=$(sed -n '1p' $file)
		sname=$(sed -n '2p' $file)
		semail=$(sed -n '3p' $file)
		syear=$(sed -n '4p' $file)
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
	1)	 ManageStudents ;;
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
